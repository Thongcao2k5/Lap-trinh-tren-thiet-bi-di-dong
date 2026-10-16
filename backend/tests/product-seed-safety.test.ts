import assert from "node:assert/strict";
import { test } from "node:test";
import { assertProductImagePolicy, assertProductSeedDatabase, assertProductSeedIdentity } from "../src/database/seeds/product-seed-safety.js";
import { productCatalog } from "../src/database/seeds/product-catalog.js";
import { deferredProductTargets, productTargets, readyProductCatalog } from "../src/database/seeds/product-targets.js";

test("reject production, missing, suffix matches and connection overrides", () => {
  for (const url of [undefined, "postgresql://localhost/sanvacau", "postgresql://localhost/not_sanvacau_test",
    "postgresql://localhost/sanvacau_test?dbname=sanvacau", "postgresql://localhost/sanvacau_test?options=-csearch_path=other"]) {
    assert.throws(() => assertProductSeedDatabase(url));
  }
  assert.doesNotThrow(() => assertProductSeedDatabase("postgresql://localhost/sanvacau_test"));
  assert.throws(() => assertProductSeedIdentity("sanvacau"));
  assert.doesNotThrow(() => assertProductSeedIdentity("sanvacau_test"));
});

test("ready configurations belong to the approved shortlist; legacy demo variants are excluded", () => {
  assert.equal(productTargets.length, 42);
  assert.equal(new Set(productTargets.map(([, brand, model]) => `${brand} ${model}`)).size, 42);
  assert.equal(readyProductCatalog.length, 19);
  assert.equal(deferredProductTargets.length, 23);
  const variants = readyProductCatalog.flatMap((p) => p.variants);
  assert.equal(variants.length, 41);
  assert.equal(new Set(variants.map((v) => v.sku)).size, variants.length);
  const legacySkus = new Set(productCatalog.flatMap((p) => p.variants.map((v) => v.sku)));
  for (const p of readyProductCatalog) {
    assert.ok(productTargets.some(([, brand, model]) => p.name === `${brand} ${model}`));
    assert.doesNotThrow(() => assertProductImagePolicy(p.imageUrl, p.imageEvidence));
    assert.ok(p.description?.includes("dữ liệu demo"));
    assert.equal(new URL(p.variantSourceUrl).protocol, "https:");
    for (const v of p.variants) {
      assert.ok(!legacySkus.has(v.sku));
      assert.ok(Number(v.price) > 0 && Number.isSafeInteger(v.quantity) && v.quantity >= 0);
    }
  }
  assert.equal(productCatalog.length, 6);
  assert.ok(productCatalog.every((p) => p.brand !== "SanVaCau"));
  assert.equal(productCatalog.flatMap((p) => p.variants).length, 26);
});

test("null photos are allowed; hotlinks, placeholders and unlicensed local photos are rejected", () => {
  assert.doesNotThrow(() => assertProductImagePolicy(null));
  for (const url of ["", "https://example.com/photo.jpg", "assets/demo/product-shoes.jpg", "/uploads/images/products/photo.jpg"]) {
    assert.throws(() => assertProductImagePolicy(url));
  }
  assert.throws(() => assertProductImagePolicy(null, { sourceUrl: "https://example.com", permissionEvidence: "permission", sha256: "a".repeat(64) }));
});

async function memorySeed() {
  // No connection: exercise the SAME mutation routine using an in-memory adapter.
  process.env.JWT_SECRET ??= "product-seed-unit-test";
  process.env.DATABASE_URL = "postgresql://localhost/sanvacau_test";
  const { seedProductRows } = await import("../src/database/seeds/product-seeder.js");
  const products: any[] = [{ id: 1n, name: "Untouched legacy", image_url: "old.jpg" }];
  const variants: any[] = [{ id: 1n, product_id: 1n, sku: "LEGACY", price: "123.00", quantity: 7 }];
  const categories: any[] = [];
  const brands: any[] = [];
  let database = "sanvacau_test";
  const tx: any = {
    $queryRaw: async (sql: TemplateStringsArray) => sql.join("").includes("current_database") ? [{ database }] : [],
    product: {
      findMany: async ({ where }: any) => products.filter((p) => p.name.toLowerCase() === where.name.equals.toLowerCase()),
      create: async ({ data }: any) => { const row = { id: BigInt(products.length + 1), ...data }; products.push(row); return row; },
    },
    product_variant: {
      findUnique: async ({ where, include }: any) => {
        const v = variants.find((v) => v.sku === where.sku);
        return v ? { ...v, ...(include ? { product: products.find((p) => p.id === v.product_id) } : {}) } : null;
      },
      create: async ({ data }: any) => { const row = { ...data, quantity: data.inventory.create.quantity }; variants.push(row); return row; },
    },
    category: {
      findMany: async ({ where }: any) => categories.filter((c) => c.name === where.name),
      create: async ({ data }: any) => { const row = { id: BigInt(categories.length + 1), ...data }; categories.push(row); return row; },
    },
    brand: {
      findUnique: async ({ where }: any) => brands.find((b) => b.name === where.name) ?? null,
      create: async ({ data }: any) => { const row = { id: BigInt(brands.length + 1), ...data }; brands.push(row); return row; },
    },
  };
  return { products, variants, categories, brands, setDatabase: (value: string) => { database = value; },
    run: (items = readyProductCatalog) => seedProductRows(tx, items, { preserveExistingProducts: true, createMissingRelations: true }) };
}

test("repeat shared seed in memory: no duplicates or legacy changes, null photos and inventory retained", async () => {
  const db = await memorySeed();
  const legacy = structuredClone({ product: db.products[0], variant: db.variants[0] });
  await db.run();
  assert.equal(db.products.length, 20);
  assert.equal(db.variants.length, 42);
  const snapshot = () => JSON.parse(JSON.stringify({ products: db.products, variants: db.variants, categories: db.categories, brands: db.brands },
    (_, value) => typeof value === "bigint" ? value.toString() : value));
  const first = snapshot();
  await db.run();
  assert.deepEqual(snapshot(), first);
  assert.deepEqual({ product: db.products[0], variant: db.variants[0] }, legacy);
  assert.deepEqual(db.products.slice(1).map((p) => p.image_url), readyProductCatalog.map((p) => p.imageUrl));
  assert.deepEqual(db.variants.slice(1).map((v) => v.image_url), readyProductCatalog.flatMap((p) => p.variants.map(() => p.imageUrl)));
  assert.ok(db.variants.slice(1).every((v) => v.quantity > 0));
});

test("server identity mismatch and SKU conflicts abort before inserting products", async () => {
  const db = await memorySeed();
  db.setDatabase("sanvacau");
  await assert.rejects(db.run(), /Connected database/);
  assert.equal(db.products.length, 1);
  db.setDatabase("sanvacau_test");
  const candidate = readyProductCatalog[0]!;
  await assert.rejects(db.run([{ ...candidate, variants: [{ ...candidate.variants[0]!, sku: "LEGACY" }] }]), /SKU\/product conflict/);
  assert.equal(db.products.length, 1);
});

test("an existing product with different legacy SKU, price and stock is skipped entirely", async () => {
  const db = await memorySeed();
  db.products[0].name = readyProductCatalog[0]!.name.toUpperCase();
  const oldProduct = structuredClone(db.products[0]);
  const oldVariant = structuredClone(db.variants[0]);
  await db.run([readyProductCatalog[0]!]);
  assert.equal(db.products.length, 1);
  assert.equal(db.variants.length, 1);
  assert.deepEqual(db.products[0], oldProduct);
  assert.deepEqual(db.variants[0], oldVariant);
  assert.equal(db.categories.length, 0);
  assert.equal(db.brands.length, 0);
});
