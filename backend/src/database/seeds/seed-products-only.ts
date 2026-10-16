import dotenv from "dotenv";
import pg from "pg";
import { createHash } from "node:crypto";
import { readFile, realpath } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { productCatalog } from "./product-catalog.js";
import { deferredProductTargets, readyProductCatalog, productTargets } from "./product-targets.js";
import { assertProductImagePolicy, assertProductSeedDatabase, assertProductSeedIdentity } from "./product-seed-safety.js";

const backendDir = fileURLToPath(new URL("../../../", import.meta.url));
// Explicit test configuration; an ambient DATABASE_URL is never silently overridden.
dotenv.config({ path: path.join(backendDir, ".env.test"), quiet: true });
assertProductSeedDatabase(process.env.DATABASE_URL);
const args = process.argv.slice(2);
if (args.some((arg) => !["--apply", "--check"].includes(arg)) ||
    (args.includes("--apply") && args.includes("--check"))) {
  throw new Error("Usage: seed:products -- [--check | --apply]");
}

// No demo catalog fallback: its 30 additional legacy variants are not approved.
const legacyNames = new Set(productCatalog.map((item) => item.name));
const legacySkus = new Set(productCatalog.flatMap((item) => item.variants.map((v) => v.sku)));
const allSkus = new Set<string>();
const allNames = new Set<string>();
const targetNames = new Set(productTargets.map(([, brand, model]) => `${brand} ${model}`));
for (const item of readyProductCatalog) {
  if (!targetNames.has(item.name) || legacyNames.has(item.name) || allNames.has(item.name)) {
    throw new Error(`Unapproved/duplicate/legacy product: ${item.name}`);
  }
  allNames.add(item.name);
  if (!item.description?.includes("demo") || !item.variants.length ||
      !item.variants.some((v) => v.sku === item.sku)) {
    throw new Error(`Missing description, demo disclosure or variants: ${item.name}`);
  }
  for (const source of [item.sourceUrl, item.variantSourceUrl]) {
    if (new URL(source).protocol !== "https:") throw new Error(`Invalid evidence URL: ${item.name}`);
  }
  assertProductImagePolicy(item.imageUrl, item.imageEvidence);
  if (item.imageUrl !== null) {
  const imageDir = await realpath(path.join(backendDir, "uploads/images/products"));
  const imagePath = await realpath(path.join(backendDir, item.imageUrl.slice(1)));
  if (path.relative(imageDir, imagePath).startsWith("..") || path.isAbsolute(path.relative(imageDir, imagePath))) {
    throw new Error(`Image outside product directory: ${item.name}`);
  }
  const bytes = await readFile(imagePath);
  const isImage = bytes.subarray(0, 3).equals(Buffer.from([0xff, 0xd8, 0xff])) ||
    bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])) ||
    (bytes.toString("ascii", 0, 4) === "RIFF" && bytes.toString("ascii", 8, 12) === "WEBP");
  if (!isImage || createHash("sha256").update(bytes).digest("hex") !== item.imageEvidence!.sha256) {
    throw new Error(`Invalid or changed image: ${item.name}`);
  }
  }
  for (const variant of item.variants) {
    if (!variant.sku.trim() || variant.sku.length > 80 || legacySkus.has(variant.sku) || allSkus.has(variant.sku) ||
        !variant.variantName.trim() || !/^\d+(\.\d{1,2})?$/.test(variant.price) ||
        Number(variant.price) <= 0 || !Number.isSafeInteger(variant.quantity) || variant.quantity < 0) {
      throw new Error(`Invalid/duplicate variant: ${item.name}`);
    }
    allSkus.add(variant.sku);
  }
}

const client = new pg.Client({
  connectionString: process.env.DATABASE_URL,
  connectionTimeoutMillis: 5000,
  options: "-c default_transaction_read_only=on",
});
try {
  await client.connect();
  await client.query("BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY");
  assertProductSeedIdentity((await client.query("SELECT current_database() AS database")).rows[0].database);
  const imageColumns = (await client.query(`SELECT table_name FROM information_schema.columns
    WHERE table_schema='public' AND table_name IN ('product','product_variant')
    AND column_name='image_url' AND is_nullable='YES'`)).rows;
  if (imageColumns.length !== 2) throw new Error("Product and variant image_url must be nullable");
  const products = (await client.query("SELECT id::text, name FROM product")).rows as Array<{ id: string; name: string }>;
  const existingVariants = (await client.query("SELECT product_id::text, sku FROM product_variant")).rows as Array<{ product_id: string; sku: string }>;
  const categories = (await client.query("SELECT name FROM category WHERE parent_id IS NULL")).rows as Array<{ name: string }>;
  const brands = (await client.query("SELECT name FROM brand")).rows as Array<{ name: string }>;
  const newItems = readyProductCatalog.filter((item) => {
    const matches = products.filter((p) => p.name.toLowerCase() === item.name.toLowerCase());
    if (matches.length > 1) throw new Error(`Ambiguous product: ${item.name}`);
    for (const v of item.variants) {
      const conflict = existingVariants.find((old) => old.sku === v.sku);
      if (conflict && conflict.product_id !== matches[0]?.id) throw new Error(`SKU conflict: ${v.sku}`);
    }
    return matches.length === 0;
  });
  const counts = (await client.query(`SELECT
    (SELECT count(*)::int FROM product) AS products,
    (SELECT count(*)::int FROM product_variant) AS variants,
    (SELECT count(*)::int FROM inventory) AS inventory,
    (SELECT count(*)::int FROM (SELECT sku FROM product_variant GROUP BY sku HAVING count(*) > 1) d) AS duplicate_skus,
    (SELECT count(*)::int FROM product p WHERE NOT EXISTS (SELECT 1 FROM product_variant v WHERE v.product_id=p.id)) AS products_without_variants,
    (SELECT count(*)::int FROM product_variant v WHERE NOT EXISTS (SELECT 1 FROM inventory i WHERE i.product_variant_id=v.id)) AS variants_without_inventory,
    (SELECT count(*)::int FROM product_variant WHERE price IS NULL OR price <= 0) AS invalid_prices,
    (SELECT count(*)::int FROM inventory WHERE quantity < 0) AS negative_inventory,
    (SELECT count(*)::int FROM product WHERE image_url IS NULL OR btrim(image_url)='') AS products_without_images`)).rows[0];
  await client.query("ROLLBACK");
  console.log(JSON.stringify({
    database: "sanvacau_test", mode: args.includes("--apply") ? "apply" : "check",
    counts, legacyCatalogVariants: productCatalog.reduce((sum, p) => sum + p.variants.length, 0),
    readyProducts: readyProductCatalog.length, readyVariants: allSkus.size,
    productsToAdd: newItems.length, variantsToAdd: newItems.reduce((n, p) => n + p.variants.length, 0),
    projectedProducts: counts.products + newItems.length,
    projectedVariants: counts.variants + newItems.reduce((n, p) => n + p.variants.length, 0),
    productsWithoutImagesToAdd: newItems.filter((p) => p.imageUrl === null).length,
    categoriesToCreate: [...new Set(newItems.map((p) => p.category))].filter((name) => !categories.some((c) => c.name === name)),
    brandsToCreate: [...new Set(newItems.map((p) => p.brand))].filter((name) => !brands.some((b) => b.name === name)),
    ready: readyProductCatalog.map((p) => ({ name: p.name, variants: p.variants.length, imageUrl: p.imageUrl })),
    blockedProducts: deferredProductTargets.length, blocked: deferredProductTargets,
  }, null, 2));
  if (!readyProductCatalog.length) {
    console.log("No eligible products; no database writes. Legacy products and variants untouched.");
  } else if (args.includes("--apply")) {
    // Load the shared seeder only after all preflight checks; never import seed.ts.
    const { prisma } = await import("../../lib/prisma.js");
    try {
      const { seedProducts } = await import("./product-seeder.js");
      await seedProducts(readyProductCatalog, { preserveExistingProducts: true, createMissingRelations: true });
    } finally {
      await prisma.$disconnect();
    }
  } else {
    console.log("Check only; no database writes. Apply requires explicit --apply approval.");
  }
} finally {
  await client.end();
}
