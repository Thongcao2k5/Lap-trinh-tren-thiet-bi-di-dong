import { Prisma } from "@prisma/client";
import { prisma } from "../../lib/prisma.js";
import { legacyApprovedProducts, productCatalog } from "./product-catalog.js";
import { readyProductCatalog } from "./product-targets.js";
import { assertProductSeedDatabase, assertProductSeedIdentity } from "./product-seed-safety.js";

export type ProductSeedItem = Omit<(typeof productCatalog)[number], "imageUrl"> & {
  imageUrl: string | null;
  description?: string;
  imageEvidence?: { sourceUrl: string; permissionEvidence: string; sha256: string };
};
type SeedOptions = { preserveExistingProducts?: boolean; createMissingRelations?: boolean };

export const fullProductCatalog: ProductSeedItem[] = [
  ...legacyApprovedProducts,
  ...readyProductCatalog,
];

// Shared by the transaction runner and in-memory repeatability tests.
export async function seedProductRows(
  tx: Prisma.TransactionClient, catalog: readonly ProductSeedItem[], options: SeedOptions = {},
) {
    const identity = await tx.$queryRaw<Array<{ database: string }>>`SELECT current_database() AS database`;
    assertProductSeedIdentity(identity[0]?.database ?? "");
    await tx.$queryRaw`SELECT 1 AS locked FROM pg_advisory_xact_lock(74042801)`;
    for (const item of catalog) {
      const matches = await tx.product.findMany({ where: { name: { equals: item.name, mode: "insensitive" } }, take: 2 });
      if (matches.length > 1) throw new Error(`Ambiguous product name: ${item.name}`);
      const legacy = await tx.product_variant.findUnique({
        where: { sku: item.sku }, include: { product: true },
      });
      if (legacy && (legacy.product.name.toLowerCase() !== item.name.toLowerCase() || (matches[0] && matches[0].id !== legacy.product_id))) {
        throw new Error(`SKU/product conflict: ${item.sku}`);
      }
      let product = legacy?.product ?? matches[0];
      // Check ALL SKUs before skipping an existing product or inserting rows.
      for (const variant of item.variants) {
        const existing = await tx.product_variant.findUnique({ where: { sku: variant.sku } });
        if (existing && existing.product_id !== product?.id) throw new Error(`SKU/product conflict: ${variant.sku}`);
      }
      if (product && options.preserveExistingProducts) continue;
      if (!product) {
        const categories = await tx.category.findMany({ where: {
          name: item.category, ...(options.createMissingRelations ? { parent_id: null } : {}),
        }, take: 2 });
        let brand = await tx.brand.findUnique({ where: { name: item.brand } });
        if (categories.length > 1) throw new Error(`Ambiguous category: ${item.category}`);
        let category = categories[0];
        if (options.createMissingRelations) {
          category ??= await tx.category.create({ data: { name: item.category, is_active: true } });
          brand ??= await tx.brand.create({ data: { name: item.brand, is_active: true } });
        }
        if (!category || !brand) throw new Error(`Missing category or brand: ${item.name}`);
        product = await tx.product.create({
          data: {
            name: item.name, category_id: category.id, brand_id: brand.id,
            description: item.description ?? `Sản phẩm demo ${item.name} cho SanVaCau.`,
            image_url: item.imageUrl, is_active: true, is_featured: item.featured,
          },
        });
      }
      for (const variant of item.variants) {
        const existing = await tx.product_variant.findUnique({ where: { sku: variant.sku } });
        if (existing) continue;
        await tx.product_variant.create({
          data: {
            product_id: product.id, sku: variant.sku, variant_name: variant.variantName,
            price: new Prisma.Decimal(variant.price), image_url: item.imageUrl,
            is_active: true, inventory: { create: { quantity: variant.quantity } },
          },
        });
      }
    }
}

export const seedProducts = async (
  catalog: readonly ProductSeedItem[] = fullProductCatalog,
  options: SeedOptions = {},
) => {
  assertProductSeedDatabase(process.env.DATABASE_URL);
  const skus = catalog.flatMap((item) => item.variants.map((variant) => variant.sku));
  if (new Set(skus).size !== skus.length || skus.some((sku) => sku.length > 80)) {
    throw new Error("Invalid or duplicate SKU in product catalog");
  }

  await prisma.$transaction((tx) => seedProductRows(tx, catalog, options), { maxWait: 10000, timeout: 30000 });
  console.log("[seed] products and variants done; existing data preserved");
};

// Compatibility with both entry points. New inventory is created atomically with
// its variant above; existing variants (even those without inventory) stay untouched.
export const seedInventory = async () => {
  console.log("[seed] DEMO inventory initialized with new variants; existing inventory preserved");
};
