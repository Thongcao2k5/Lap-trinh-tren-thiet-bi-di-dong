export function assertProductSeedDatabase(connectionString: string | undefined) {
  if (!connectionString) throw new Error("DATABASE_URL is required");
  const url = new URL(connectionString);
  const allowed = process.env.ALLOW_SEED_MAIN === "true"
    ? ["/sanvacau_test", "/sanvacau"]
    : ["/sanvacau_test"];
  if (!["postgres:", "postgresql:"].includes(url.protocol) ||
      !allowed.includes(decodeURIComponent(url.pathname)) ||
      [...url.searchParams.keys()].some((key) => ["dbname", "database", "options", "host", "port", "user", "service"].includes(key.toLowerCase()))) {
    throw new Error("Product seed is restricted to sanvacau_test (no connection overrides)");
  }
}

export function assertProductSeedIdentity(database: string) {
  const allowed = process.env.ALLOW_SEED_MAIN === "true"
    ? ["sanvacau_test", "sanvacau"]
    : ["sanvacau_test"];
  if (!allowed.includes(database)) throw new Error("Connected database must be sanvacau_test");
}

export function assertProductImagePolicy(
  imageUrl: string | null,
  evidence?: { sourceUrl: string; permissionEvidence: string; sha256: string },
) {
  if (imageUrl === null) {
    if (evidence) throw new Error("Image evidence requires an image file");
    return;
  }
  if (!/^\/uploads\/images\/products\/[a-zA-Z0-9_-]+\.(jpg|jpeg|png|webp)$/.test(imageUrl) ||
      !evidence?.permissionEvidence.trim() || !/^[a-f0-9]{64}$/.test(evidence.sha256) ||
      !["https:", "user-supplied:"].includes(new URL(evidence.sourceUrl).protocol)) {
    throw new Error("Product images require a local file and verified reuse evidence; null is allowed");
  }
}
