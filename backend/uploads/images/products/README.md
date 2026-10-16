## Completion: remaining service photos

service-thay-quan-can.jpg and service-sua-khung-vot.jpg were supplied, visually
checked and assigned to services 2 and 3 on sanvacau_test. Both are valid JPEG
files and returned HTTP 200 with matching file hashes. All three service image
URLs are present in the API and seed. Flutter mock service 2 now uses its local
photo; existing service 3 is represented in the mock list using its seeded
100000 VND reference price and 1 - 2 day duration. No existing service prices,
IDs or business records were changed. Image permission relies on the user's
previous attestation. No global seed, migration or Git push was run.

## Latest assignment: 2026-10-17

Nine of the eleven requested files were supplied and assigned on sanvacau_test:
- Products 143 and 148 and their two variants (25/25 products, 47/47 variants now have images).
- News 1, 3 and 5: news-luyen-phan-xa.jpg, news-uu-dai-san-pham.jpg, news-bao-quan-vot.jpg.
- Branches 133, 134 and 135: branch-quan-1.webp, branch-thu-duc.webp, branch-binh-thanh.jpg.
- Racket service 1: service-cang-day-vot.jpg.

The user supplied these files under the previously confirmed permission to use
and share them in the team repository. Branch/service photos are demo
illustrations; actual premises were not independently verified. Watermarks remain.
Three .jpg files were actually WebP and renamed without conversion:
yonex-nanoflare-001-ability.webp, branch-quan-1.webp, branch-thu-duc.webp.
Missing: service-thay-quan-can and service-sua-khung-vot (any valid image format).
All nine assigned URLs returned HTTP 200 with matching file hashes. Home, product,
news and branch APIs returned 200; home includes the 65Z and three local news photos.
All non-image fields were compared before/after and unchanged, including stock 517.
No global seed, migration or Git push was run. Existing seed files now contain
these paths; do not run the global seed solely to sync existing team databases.
Service Flutter mock data also uses the supplied stringing photo and AppImage
resolves its relative URL. News list/detail still use their pre-existing mock data;
this assignment updates actual news records and the home API, not that data source.

The following sections contain earlier checks and decisions.

# Product photographs shared with the team

Status on 2026-10-17: **23 photographs assigned, 2 uncertain skipped**.
The supplying user explicitly confirmed permission to use and share these files
in the team repository. This is a user attestation, not an independently obtained
license document. Exact filenames, SHA-256 and this permission record are stored
in src/database/seeds/product-images.ts and reused by both catalogs.
Original valid formats are kept. Only image_url was updated on 23 products and
45 variants in sanvacau_test. The previous 20 images and the three newly approved exception images returned
HTTP 200. The list API returned 25 products, 23 with images. Two products
retain null images and the Flutter placeholder.
The AC470 photo has a generic filename but a clearly readable Grip Powder 2 /
AC470 label and is now mapped in product-images.ts.

New AC414 Black, Astrox 100 ZZ and Kawasaki 525 Red photos were assigned.
AC414 Black.jpg was renamed to yonex-ac414-black.jpg for a portable URL.

Remaining blockers (do not change product data to match these files):
- 143: photo is 65Z VA Men Grayish Beige; legacy 65Z edition is unspecified.
- 148: photo says Nanoflare Ability, without enough evidence for 001 Ability.
Demo products 145 and 146 were removed from sanvacau_test after checking business
references inside the deletion transaction. The remaining 25 products and 47
variants were preserved, including prices, SKUs and stock.
Do not place a substitute product, generic sports photo or AI replica here.

This directory already falls outside the repository's .gitignore rules. Commit
approved WebP files and their permission evidence together with catalog paths.
Local upload files outside this curated directory are not needed for the catalog.
No commit or push has been performed by this task.

## Storage and approval

- Reuse backend /uploads/images/products/, no new storage service.
- After rights and exact model/version/color are verified, convert to WebP,
  preferably <= 150 KB and at most 1000 pixels on the longest edge. Keep enough
  detail to identify the product. Do not upscale or invent details.
- Use stable lowercase names, e.g. brand-model-version-color.webp. This is a
  naming convention, not a claim that an example file exists.
- Catalog URLs must be root-relative /uploads/images/products/<actual-file>.webp,
  never localhost, a developer's LAN IP, or an external hotlink.
- Existing imageEvidence fields hold the source URL, permission evidence and
  SHA-256 of the committed file. Permission must cover WebP conversion and sharing
  through the team's Git repository. Retain any required author/license credit.
- Report the cleared files for user approval BEFORE any database image update.
  Then update only image_url on matched products/variants in sanvacau_test, checking
  DATABASE_URL and current_database(); preserve ID/SKU/price/stock.
- Unmatched legacy and real-product catalog image URLs remain null.
  Never run the global seed to attach photographs.

## Sources checked, not downloaded

| Source | Decision |
| --- | --- |
| https://shopvnb.com/dieu-khoan-su-dung.html | Section 5.V requires prior written permission to collect material for reuse. No such permission available. Skip. |
| https://us.yonex.com/policies/terms-of-service | No suitable redistribution grant verified; collection/reuse restrictions require consent. Skip. |
| https://corp.mizuno.com/en/legal/terms_of_use | Reproduction/transmission outside permitted private use requires prior authorization. No authorization available. Skip. |
| Targeted open-license searches for Astrox/Arcsaber/Nanoflare | No exact-model licensed photograph verified. Skip. |

For example, https://commons.wikimedia.org/wiki/File:Arcsaber_6_from_Yonex_(10772847525).jpg
has a CC BY-SA licence but depicts Arcsaber 6, not the Arcsaber 7/11 models in our
catalog. It was NOT downloaded or substituted. A suitable licence alone is not
enough when the model is wrong.

The imprecisely named 65Z/Saga Lite also need exact-model evidence before
selecting a photo. A product-page URL alone is not a
photo licence. The team can supply its own exact-model photos or written permission
from the photographer/rights holder; do not infer permission from public access.

## Team setup

Run the backend from backend/ so its existing uploads directory is served.
Run Flutter with API_BASE_URL pointing at that backend's /api URL:

    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
    flutter run -d <android-id> --dart-define=API_BASE_URL=http://<backend-LAN-IP>:3000/api

Android emulator: use http://10.0.2.2:3000/api. Physical Android: use the backend
machine's reachable LAN address, not Android's localhost. Each teammate supplies
their own address; database/catalog values stay portable. Chrome on another
machine also needs that backend's LAN address. HTTPS frontends need HTTPS images.

Missing or failed images retain the existing neutral Flutter placeholder.

## Checks performed in this task

- TypeScript and 6 existing backend seed tests passed; no DB writes.
- 12 Flutter VM tests passed: emulator/LAN/localhost/HTTPS URL resolution,
  assets/absolute URL compatibility, placeholder and product price layout.
- Actual backend GET /uploads/images/products/README.md returned 200 with
  Access-Control-Allow-Origin: * and Cross-Origin-Resource-Policy: cross-origin.
  This checks serving/headers, not product photo decoding.
- git check-ignore confirmed a .webp path in this directory is not ignored.
  New files still require a normal team commit before another member can pull them.
- Chrome test runner stalled while loading the suite and was stopped; NOT a pass.
- Android SM T870 was detected; native image rendering has NOT been tested.
  Exact-model image rendering on Android/Chrome remains pending cleared photos.

User-approved mapping exceptions (2026-10-17): product 144 uses Saga 2 Lite
AYTT003-2; product 157 uses Wave Claw 3 Wide JP black; product 158 uses
TPM3430 White despite its TRM3751 name. These are explicit display exceptions,
not exact-model verification. Only image_url changed; product data is preserved.
