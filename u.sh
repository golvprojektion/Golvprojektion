#!/usr/bin/env bash

echo "=== u.sh — Full Vite + React 18 + TS5 Upgrade ==="

# 0. Ensure jq exists
if ! command -v jq &> /dev/null
then
    echo "→ Installing jq"
    sudo apt-get update && sudo apt-get install -y jq
fi

# 1. Remove CRA artifacts
echo "→ Cleaning old CRA files"
rm -rf node_modules package-lock.json

# 2. Rewrite package.json cleanly (remove CRA, add Vite)
echo "→ Rewriting package.json"
tmpfile=$(mktemp)

jq '
  .dependencies |= (
    .react = "^18.3.1" |
    .["react-dom"] = "^18.3.1" |
    del(.["react-scripts"])
  ) |
  .scripts = {
    dev: "vite",
    build: "vite build",
    preview: "vite preview"
  } |
  .devDependencies |= (
    .vite = "^8.0.8" |
    .["@vitejs/plugin-react-swc"] = "^4.3.0" |
    .typescript = "^5.9.3"
  )
' package.json > "$tmpfile" && mv "$tmpfile" package.json

# 3. Move index.html if needed
if [ -f "public/index.html" ]; then
  echo "→ Moving index.html to project root"
  mv public/index.html ./index.html
fi

# 4. Fix index.html script tag
echo "→ Updating index.html script tag"
sed -i 's|/static/js/bundle.js|/src/index.tsx|g' index.html 2>/dev/null
sed -i 's|<script.*</script>|<script type="module" src="/src/index.tsx"></script>|g' index.html

# 5. Create vite.config.ts if missing
if [ ! -f "vite.config.ts" ]; then
  echo "→ Creating vite.config.ts"
  cat << 'EOF' > vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      src: '/src'
    }
  }
});
EOF
fi

# 6. Install dependencies (force because CRA is gone)
echo "→ Installing dependencies (forced)"
npm install --force

# 7. Optional: auto git commit + push
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "→ Git repo detected — committing changes"
  git add .
  git commit -m "Automated Vite upgrade via u.sh" || echo "→ Nothing to commit"
  git push || echo "→ Push failed (maybe no remote?)"
fi

echo "=== Done! Starting dev server ==="
npm run dev
