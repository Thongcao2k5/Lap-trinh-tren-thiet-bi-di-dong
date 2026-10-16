export function assertProductSeedDatabase(connectionString: string | undefined) {
  if (!connectionString) throw new Error("DATABASE_URL is required");
  const url = new URL(connectionString);
  if (!["postgres:", "postgresql:"].includes(url.protocol) ||
      decodeURIComponent(url.pathname) !== "/sanvacau_test" ||
      [...url.searchParams.keys()].some((key) => ["dbname", "database", "options", "host", "port", "user", "service"].includes(key.toLowerCase()))) {
    throw new Error("Product seed is restricted to sanvacau_test (no connection overrides)");
  }
}

export function assertProductSeedIdentity(database: string) {
  if (database !== "sanvacau_test") throw new Error("Connected database must be sanvacau_test");
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
