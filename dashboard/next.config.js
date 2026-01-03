/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Allow Next/SWC to transpile TS files that live outside the dashboard directory (e.g., ../config)
  experimental: {
    externalDir: true,
  },
};

module.exports = nextConfig;