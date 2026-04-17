#!/usr/bin/env bash

echo "=== u.sh — Pure Magenta Blob Overhaul ==="

# Ensure jq
if ! command -v jq &> /dev/null
then
    sudo apt-get update && sudo apt-get install -y jq
fi

rm -rf node_modules package-lock.json

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

cat << 'EOF' > index.html
<!DOCTYPE html>
<html>
  <head><meta charset="UTF-8" /><title>Blob</title></head>
  <body style="margin:0; overflow:hidden; background:#000100;">
    <div id="root"></div>
    <script type="module" src="/src/index.tsx"></script>
  </body>
</html>
EOF

cat << 'EOF' > vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';
export default defineConfig({
  plugins: [react()],
  resolve: { alias: { src: '/src' } }
});
EOF

mkdir -p src/theme
cat << 'EOF' > src/theme/index.ts
export const Pink = { pure:"#F0F", alt:"#F0B", alt2:"#F2A" };
export const Turquoise = { pure:"#00FAD0", strong:"#00D4A8" };
export const Floor = { base:"#F5F2EB" };
export default { Pink, Turquoise, Floor };
EOF

mkdir -p src/components
cat << 'EOF' > src/components/LiquidPinkBlob.tsx
<PASTE THE NEW BLOB CODE HERE>
EOF

cat << 'EOF' > src/App.tsx
import LiquidPinkBlob from "src/components/LiquidPinkBlob";
export default function App() { return <LiquidPinkBlob />; }
EOF

npm install --force

if git rev-parse --git-dir > /dev/null 2>&1; then
  git add .
  git commit -m "Pure magenta blob overhaul" || true
  git push || true
fi

npm run dev
