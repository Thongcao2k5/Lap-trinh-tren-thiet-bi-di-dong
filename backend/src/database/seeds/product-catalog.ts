import { productImages } from "./product-images.js";
// DEMO only: illustrative configurations, prices and stock, not commercial specifications.
export type DemoVariant = { sku: string; variantName: string; price: string; quantity: number };
const products = [
    {
      name: "Yonex Astrox 88D Game",
      category: "Vợt Yonex",
      brand: "Yonex",
      price: "2350000",
      sku: "DEMO-YONEX-AX88D-GAME",
      featured: true,
    },
    {
      name: "Yonex Nanoflare 700 Play",
      category: "Vợt Yonex",
      brand: "Yonex",
      price: "1490000",
      sku: "DEMO-YONEX-NF700-PLAY",
      featured: true,
    },
    {
      name: "Lining Axforce Cannon",
      category: "Vợt Lining",
      brand: "Lining",
      price: "1890000",
      sku: "DEMO-LINING-AXFORCE-CANNON",
      featured: true,
    },
    {
      name: "Victor Thruster Ryuga TD",
      category: "Vợt cầu lông",
      brand: "Victor",
      price: "2150000",
      sku: "DEMO-VICTOR-RYUGA-TD",
      featured: true,
    },
    {
      name: "Giày Yonex Power Cushion 65Z",
      category: "Giày cầu lông",
      brand: "Yonex",
      price: "2190000",
      sku: "DEMO-YONEX-SHOE-65Z",
      featured: true,
    },
    {
      name: "Giày Lining Saga Lite",
      category: "Giày cầu lông",
      brand: "Lining",
      price: "1390000",
      sku: "DEMO-LINING-SAGA-LITE",
      featured: false,
    },
  ];


export const productCatalog = products.map((item, index) => {
  const variants: DemoVariant[] = [];
  if (index < 4) {
    const options = index === 2 ? [["4U-G5", "Trọng lượng 4U / Cỡ cán G5"], ["5U-G6", "Trọng lượng 5U / Cỡ cán G6"]]
      : [["4U-G5", "Trọng lượng 4U / Cỡ cán G5"], ["4U-G6", "Trọng lượng 4U / Cỡ cán G6"]];
    for (const [suffix, label] of options) {
      variants.push({ sku: item.sku + "-" + suffix, variantName: label + " (DEMO)", price: item.price, quantity: 12 });
    }
  } else {
    const colors = index === 5 ? [["WHITE", "Trắng"], ["BLUE", "Xanh"]]
      : index === 4 ? [["WHITE", "Trắng"], ["BLACK", "Đen"]] : [["BLACK", "Đen"], ["WHITE", "Trắng"]];
    const sizes = index < 6 ? ["40", "41", "42"] : index === 6 ? ["M", "L", "XL"] : ["1", "3"];
    for (const [colorCode, color] of colors) {
      for (const size of sizes) {
        const label = index < 6 ? "Size EU " + size : index === 6 ? "Size " + size : "Gói " + size + " cuộn";
        variants.push({
          sku: item.sku + "-" + colorCode + "-" + (index === 7 ? "PACK" : "SIZE") + size,
          variantName: color + " / " + label + " (DEMO)",
          price: index === 7 && size === "3" ? "120000" : item.price,
          quantity: index < 6 ? 8 : index === 6 ? 15 : 25,
        });
      }
    }
  }
  // Exact-model photographs have not been cleared for redistribution.
  return { ...item, imageUrl: productImages[item.name]?.imageUrl ?? null, variants: [
    { sku: item.sku, variantName: "Tiêu chuẩn", price: item.price, quantity: 20 }, ...variants,
  ] };
});

export const legacyApprovedProducts = products.map((item) => ({
  name: item.name,
  category: item.category,
  brand: item.brand,
  price: item.price,
  sku: item.sku,
  featured: item.featured,
  imageUrl: productImages[item.name]?.imageUrl ?? null,
  imageEvidence: productImages[item.name]?.imageEvidence,
  description: `Sản phẩm demo ${item.name} cho SanVaCau. Giá bán và tồn kho là dữ liệu demo phục vụ đồ án, không phải báo giá hoặc tồn kho thực tế của hãng.`,
  variants: [
    {
      sku: item.sku,
      variantName: "Tiêu chuẩn",
      price: item.price,
      quantity: 20,
    },
  ],
}));
