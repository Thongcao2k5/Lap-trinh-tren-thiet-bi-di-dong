# Product-only seed: pre-apply review

## Result (2026-10-16, READ ONLY)

DATABASE_URL and current_database() were verified as sanvacau_test.
Both product.image_url and product_variant.image_url are nullable in the actual DB.
No apply, migration, global seed, database write or Git push was performed.

| Check | Current | Proposed additions | Projected after apply |
| --- | ---: | ---: | ---: |
| Products | 8 | 19 | 27 |
| Variants / inventory rows | 8 / 8 | 41 / 41 | 49 / 49 |
| Products without photos | 0 | 19 | 19 |
| Duplicate SKU groups | 0 | 0 catalog / existing conflicts | 0 expected |
| Invalid prices / negative stock | 0 / 0 | 0 / 0 | 0 / 0 expected |
| Missing variants / missing inventory | 0 / 0 | 0 / 0 | 0 / 0 expected |

Ready: 8 rackets (14 variants), 3 shoes (9), 3 shirts (9), 2 shorts (6),
1 bag (1), 2 accessories (2). Explicit configurations and previously verified
sources are in product-targets.ts. All new prices and stock are demo, disclosed
in each description. All new image URLs are null; no photo URL is fabricated.

23 targets remain deferred for unresolved exact model/color/size/packaging:
Axforce 20, Axforce 40, Thruster Ryuga II J; Cascade Drive, A170 III, A970CHP;
TPM3428 EASY7 White, TRM3474 ACT35 Navy Peony; TSM3335 ACT35 Black,
TSM3334 ACT35 Black, TSM3609 MYS26 Navy; Soft Case AC541, BAG324B0629,
BAG2329T03, BAG2329T02; BG65, BG66 Ultimax, Exbolt 65; Super Grap AC102,
Towel Grip AC402; Mavis 350, Aerosensa 10, Aerosensa 30.
Missing photographs alone no longer block a product.

## Commands (from backend)

    npm run typecheck
    npm run test:product-seed
    npm run seed:products -- --check
    # Only after user approval:
    npm run seed:products -- --apply

Default mode is check. It loads backend/.env.test without overriding an ambient
DATABASE_URL, rejects other DB targets and verifies server identity in a READ ONLY
transaction. It checks nullable photo columns, SKUs against current data and
reports proposed missing relations. The shared writer repeats the URL guard and
current_database() inside its write transaction, then obtains its existing lock.

Dedicated apply preserves entire existing products, including all legacy IDs,
SKUs, prices, stock, images and variants. The 30 catalog-only legacy demo variants
are excluded. New variants and inventory are created together in one transaction.
Existing categories/brands are reused without modification. This apply would add
three root categories (Quan cau long, Tui va bao vot, Phu kien khac, with Vietnamese
accents as stored in the catalog) and brand Mizuno. No account, booking, order or
payment operation is invoked.

Image verification is independent: null is valid. A non-null photo still requires
an exact-model local image, reuse evidence, allowed path, file signature and SHA-256.
No hotlink or unrelated asset is accepted by the dedicated runner.

## Validation

- TypeScript check passed.
- Backend tests use the same mutation routine with an in-memory adapter: safety,
  null-photo policy, unique catalog, repeatability, SKU conflicts and preservation.
- Flutter: three tests passed for null/empty ProductCard placeholders and parsing
  a variant with a null image. Production Flutter code already supports this;
  no UI change was needed. Product detail also has a null-photo icon branch.
- READ ONLY --check passed: 19 products / 41 variants planned, 23 deferred.
- Database repeat-apply and live API/end-to-end tests remain pending apply approval.

The no-duplicate repeat test is in memory, not a claim that the database seed was
run twice. No research was repeated and no unresolved variants were added.
