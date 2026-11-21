# LUMA — Cloudflare Workers & D1 Deployment Guide

1. Install Wrangler CLI (free Cloudflare tier, no payment card required for Workers & D1 free allowance):
   npm install -g wrangler
   wrangler login

2. Provision your free D1 SQLite database:
   npx wrangler d1 create luma_db

3. Copy the returned database_id into wrangler.toml and initialize tables:
   npx wrangler d1 execute luma_db --remote --file=worker/schema.sql

4. Deploy the Worker API:
   npx wrangler deploy

5. Build the Vite React frontend for Cloudflare Pages:
   npm run build
   npx wrangler pages deploy dist
