import { productImages } from "./product-images.js";
import type { ProductSeedItem } from "./product-seeder.js";

export type VerifiedProductSeedItem = ProductSeedItem & {
  sourceUrl: string;
  variantSourceUrl: string;
  imageEvidence?: { sourceUrl: string; permissionEvidence: string; sha256: string };
};

// Approved Phase 2 shortlist. Sources verify identity, NOT image reuse rights.
// Image permissions are recorded separately. Do not import this list through the demo seed.
export const productTargets = [
  ["Vợt cầu lông", "Yonex", "Astrox 01 Ability", "https://www.yonex.com/media/wysiwyg/2024-Yonex-Badminton-Catalog.pdf"],
  ["Vợt cầu lông", "Yonex", "Nanoflare 001 Ability", "https://www.yonex.com.tw/product/d/NANOFLARE%20001%20ABILITY/2050"],
  ["Vợt cầu lông", "Yonex", "Arcsaber 7 Play", "https://www.yonex.com/arcsaber"],
  ["Vợt cầu lông", "Yonex", "Astrox 77 Play", "https://www.yonex.com/badminton/astrox-77-play"],
  ["Vợt cầu lông", "Yonex", "Arcsaber 7 Tour", "https://www.yonex.com/badminton/arc7-t"],
  ["Vợt cầu lông", "Lining", "Axforce 20", "https://shopvnb.com/vot-cau-long-lining-axforce-20.html"],
  ["Vợt cầu lông", "Lining", "Axforce 40", "https://shopvnb.com/vot-cau-long-lining-axforce-40.html"],
  ["Vợt cầu lông", "Yonex", "Astrox 100 ZZ", "https://us.yonex.com/collections/badminton?page=2"],
  ["Vợt cầu lông", "Yonex", "Arcsaber 11 Pro", "https://www.yonex.com/arcsaber"],
  ["Vợt cầu lông", "Yonex", "Nanoflare 1000 Z", "https://www.yonex.com/nf-1000z"],
  ["Vợt cầu lông", "Victor", "Thruster Ryuga II J", "https://shop.au.victorsport.com/products/thruster-ryuga-ii-j"],
  ["Giày cầu lông", "Yonex", "Aerus Z2 Men", "https://shopvnb.com/giay-cau-long-yonex-aerus-z2-men.html"],
  ["Giày cầu lông", "Yonex", "Cascade Drive", "https://shopvnb.com/giay-cau-long-yonex-cascade-drive.html?cn=2"],
  ["Giày cầu lông", "Victor", "A170 III", "https://shopvnb.com/giay-cau-long-victor-a170-iii.html"],
  ["Giày cầu lông", "Victor", "A970CHP", "https://shopvnb.com/giay-cau-long-victor-a970chp.html"],
  ["Giày cầu lông", "Kawasaki", "525", "https://shopvnb.com/giay-cau-long-kawasaki-525.html?active=5739"],
  ["Giày cầu lông", "Mizuno", "Wave Claw 3", "https://shopvnb.com/giay-cau-long-mizuno-wave-claw-3.html?active=25964"],
  ["Áo cầu lông", "Yonex", "TRM3751 VNO White", "https://shopvnb.com/ao-cau-long-yonex-trm3751-vno-white-chinh-hang.html?cn=42"],
  ["Áo cầu lông", "Yonex", "TPM3430 EASY7 Black", "https://shopvnb.com/ao-cau-long-yonex-tpm3430-easy7-black-chinh-hang.html"],
  ["Áo cầu lông", "Yonex", "TPM3428 EASY7 White", "https://shopvnb.com/ao-cau-long-yonex-tpm3428-easy7-white-chinh-hang.html?cn=83"],
  ["Áo cầu lông", "Yonex", "TPM3429 EASY7 White", "https://shopvnb.com/ao-cau-long-yonex-tpm3429-easy7-white-chinh-hang.html?cn=108"],
  ["Áo cầu lông", "Yonex", "TRM3474 ACT35 Navy Peony", "https://shopvnb.com/ao-cau-long-yonex-trm3474-act35-navy-peony-chinh-hang.html?cn=11"],
  ["Quần cầu lông", "Yonex", "TSM3475 ACT35 Black", "https://shopvnb.com/quan-cau-long-yonex-tsm3475-act35-black-chinh-hang.html?cn=11"],
  ["Quần cầu lông", "Yonex", "TSM3336 ACT35 Black", "https://shopvnb.com/quan-cau-long-yonex-tsm3336-act35-black-chinh-hang.html?cn=59"],
  ["Quần cầu lông", "Yonex", "TSM3335 ACT35 Black", "https://shopvnb.com/quan-cau-long-yonex-tsm3335-act35-black-chinh-hang.html?cn=43"],
  ["Quần cầu lông", "Yonex", "TSM3334 ACT35 Black", "https://shopvnb.com/quan-cau-long.html"],
  ["Quần cầu lông", "Yonex", "TSM3609 MYS26 Navy", "https://shopvnb.com/quan-cau-long.html"],
  ["Túi và bao vợt", "Yonex", "Soft Case AC541", "https://yonexshop.jp/item/detail/1_1_AC541_1"],
  ["Túi và bao vợt", "Yonex", "BAG324B0129", "https://shopvnb.com/tui-cau-long-yonex-bag324b0129.html"],
  ["Túi và bao vợt", "Yonex", "BAG324B0629", "https://shopvnb.com/tim-kiem?tu_khoa=t%C3%BAi+c%E1%BA%A7u+l%C3%B4ng+yonex"],
  ["Túi và bao vợt", "Yonex", "BAG2329T03", "https://shopvnb.com/tim-kiem?tu_khoa=t%C3%BAi+c%E1%BA%A7u+l%C3%B4ng+yonex"],
  ["Túi và bao vợt", "Yonex", "BAG2329T02", "https://shopvnb.com/tim-kiem?tu_khoa=t%C3%BAi+c%E1%BA%A7u+l%C3%B4ng+yonex"],
  ["Cước cầu lông", "Yonex", "BG65", "https://us.yonex.com/collections/badminton-accessories"],
  ["Cước cầu lông", "Yonex", "BG66 Ultimax", "https://us.yonex.com/collections/badminton-accessories"],
  ["Cước cầu lông", "Yonex", "Exbolt 65", "https://us.yonex.com/collections/badminton-accessories"],
  ["Quấn cán", "Yonex", "Super Grap AC102", "https://www.yonex.com/media/wysiwyg/2021-Yonex-Badminton-Catalog.pdf"],
  ["Quấn cán", "Yonex", "Towel Grip AC402", "https://www.yonex.com/media/wysiwyg/2021-Yonex-Badminton-Catalog.pdf"],
  ["Quả cầu lông", "Yonex", "Mavis 350", "https://us.yonex.com/collections/badminton-accessories"],
  ["Quả cầu lông", "Yonex", "Aerosensa 10", "https://us.yonex.com/collections/badminton-accessories"],
  ["Quả cầu lông", "Yonex", "Aerosensa 30", "https://us.yonex.com/collections/badminton-accessories"],
  ["Phụ kiện khác", "Yonex", "Grip Powder 2 AC470", "https://yonexshop.jp/item/detail/1_1_AC470_1/011"],
  ["Phụ kiện khác", "Yonex", "Stencil Ink AC414", "https://www.yonexmall.com/m2/goods/view.php?category=001&goodsno=585"],
] as const;

// Reuse verified Phase 2 configurations only. Prices and stock below are demo.
// A missing photograph is represented by null, never by a substitute image.
const verifiedConfigurations: Array<{
  model: string; code: string; price: string; options: Array<[string, string]>; variantSourceUrl?: string;
}> = [
  { model: "Astrox 01 Ability", code: "AX01A", price: "850000", options: [["4UG5", "4U / G5"]] },
  { model: "Nanoflare 001 Ability", code: "NF001A", price: "750000", options: [["5UG5", "5U / G5"]] },
  { model: "Arcsaber 7 Play", code: "ARC7PL", price: "1050000", options: [["4UG5", "4U / G5"], ["4UG6", "4U / G6"]] },
  { model: "Astrox 77 Play", code: "AX77PL", price: "1200000", options: [["4UG5", "4U / G5"], ["4UG6", "4U / G6"]] },
  { model: "Arcsaber 7 Tour", code: "ARC7T", price: "2300000", options: [["4UG5", "4U / G5"], ["4UG6", "4U / G6"]] },
  { model: "Astrox 100 ZZ", code: "AX100ZZ", price: "4800000", options: [["3UG5", "3U / G5"], ["4UG5", "4U / G5"]],
    variantSourceUrl: "https://www.yonex.com/media/wysiwyg/2021-Yonex-Badminton-Catalog.pdf" },
  { model: "Arcsaber 11 Pro", code: "ARC11P", price: "4500000", options: [["3UG5", "3U / G5"], ["4UG5", "4U / G5"]] },
  { model: "Nanoflare 1000 Z", code: "NF1000Z", price: "4800000", options: [["3UG5", "3U / G5"], ["4UG5", "4U / G5"]] },
  { model: "Aerus Z2 Men", code: "AERUSZ2M", price: "2689000", options: [["GRAYBLUE-40", "Xám xanh / 40"], ["GRAYBLUE-41", "Xám xanh / 41"], ["GRAYBLUE-42", "Xám xanh / 42"]] },
  { model: "525", code: "KAW525", price: "1280000", options: [["RED-40", "Đỏ / 40"], ["RED-41", "Đỏ / 41"], ["RED-42", "Đỏ / 42"]] },
  { model: "Wave Claw 3", code: "71GA244335", price: "3200000", options: [["40", "71GA244335 / 40"], ["41", "71GA244335 / 41"], ["42", "71GA244335 / 42"]] },
  { model: "TRM3751 VNO White", code: "TRM3751-W", price: "179000", options: [["M", "White / M"], ["L", "White / L"], ["XL", "White / XL"]] },
  { model: "TPM3430 EASY7 Black", code: "TPM3430-BK", price: "319000", options: [["M", "Black / M"], ["L", "Black / L"], ["XL", "Black / XL"]] },
  { model: "TPM3429 EASY7 White", code: "TPM3429-W", price: "289000", options: [["M", "White / M"], ["L", "White / L"], ["XL", "White / XL"]] },
  { model: "TSM3475 ACT35 Black", code: "TSM3475-BK", price: "369000", options: [["M", "Black / M"], ["L", "Black / L"], ["XL", "Black / XL"]] },
  { model: "TSM3336 ACT35 Black", code: "TSM3336-BK", price: "389000", options: [["M", "Black / M"], ["L", "Black / L"], ["XL", "Black / XL"]] },
  { model: "BAG324B0129", code: "BAG324B0129", price: "889000", options: [["BKLIME", "Jet Black / Lime Punch"]] },
  { model: "Grip Powder 2 AC470", code: "AC470", price: "180000", options: [["20G", "20g"]] },
  { model: "Stencil Ink AC414", code: "AC414", price: "200000", options: [["BLACK", "Black"]] },
];

export const readyProductCatalog: VerifiedProductSeedItem[] = verifiedConfigurations.map((config) => {
  const target = productTargets.find(([, , model]) => model === config.model);
  if (!target) throw new Error(`Unknown approved product: ${config.model}`);
  const [category, brand, model, sourceUrl] = target;
  const variants = config.options.map(([code, variantName]) => ({
    sku: `SVC-${config.code}-${code}`, variantName, price: config.price,
    quantity: category === "Vợt cầu lông" ? 8 : 10,
  }));
  return {
    name: `${brand} ${model}`, category: category === "Áo cầu lông" ? "Áo thể thao" : category,
    brand, price: config.price, sku: variants[0]!.sku, featured: false,
    imageUrl: productImages[`${brand} ${model}`]?.imageUrl ?? null,
    imageEvidence: productImages[`${brand} ${model}`]?.imageEvidence, variants, sourceUrl, variantSourceUrl: config.variantSourceUrl ?? sourceUrl,
    description: `${category}: ${brand} ${model}. Các lựa chọn đã đối chiếu: ${config.options.map(([, label]) => label).join("; ")}. ` +
      "Giá bán và tồn kho là dữ liệu demo phục vụ đồ án, không phải báo giá hoặc tồn kho thực tế của hãng. Sản phẩm chưa có ảnh.",
  };
});

export const deferredProductTargets = productTargets
  .filter(([, brand, model]) => !readyProductCatalog.some((item) => item.name === `${brand} ${model}`))
  .map(([category, brand, model, sourceUrl]) => ({
    category, brand, model, sourceUrl,
    reason: "Chưa xác minh đầy đủ cấu hình cụ thể (đời/màu/cỡ/quy cách) trong Giai đoạn 2; thiếu ảnh không còn là điều kiện chặn.",
  }));
