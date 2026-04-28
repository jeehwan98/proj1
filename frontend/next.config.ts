import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Produces a minimal standalone server bundle for Docker — only includes
  // files actually needed to run, no devDependencies or source files
  output: "standalone",
};

export default nextConfig;
