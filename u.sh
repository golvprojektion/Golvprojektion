#!/usr/bin/env bash

echo "=== u.sh — Full Vite + React 18 + TS5 + Theme System Upgrade ==="

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

# 6. Create theme folder + files
echo "→ Installing theme system"

mkdir -p src/theme

cat << 'EOF' > src/theme/pink.ts
export const Pink = {
  background: "#000100",
  backgroundSoft: "#1a0012",

  pink: "#FFAACC",
  pinkSoft: "#FFCCE0",
  pinkHot: "#FF00CC",
  pinkGlow: "#FF66DD",

  text: "#FFFFFF",
  textPink: "#FFAAEE",

  border: "#FF99CC",
  borderStrong: "#FF00AA",

  glow: "0 0 20px #FF66DD",
  glowStrong: "0 0 40px #FF00CC"
};
export default Pink;
EOF

cat << 'EOF' > src/theme/turquoise.ts
export const Turquoise = {
  accent: "#00F5FF",
  accentSoft: "#A0FFFF",
  accentDeep: "#00C4CC",
  accentGlow: "0 0 20px #00F5FF",

  line: "#00E0FF",
  lineStrong: "#00BBD4"
};
export default Turquoise;
EOF

cat << 'EOF' > src/theme/floor.ts
export const Floor = {
  // Matte off‑white wood‑ish tone for projection
  base: "#F5F2EB",
  grainLight: "#E8E3D9",
  grainDark: "#D6D0C4",

  // For UI overlays on floor backgrounds
  shadow: "rgba(0,0,0,0.15)",
  shadowStrong: "rgba(0,0,0,0.35)"
};
export default Floor;
EOF

cat << 'EOF' > src/theme/index.ts
import Pink from "./pink";
import Turquoise from "./turquoise";
import Floor from "./floor";

export const Theme = {
  Pink,
  Turquoise,
  Floor
};

export default Theme;
EOF

# 7. Install dependencies (force because CRA is gone)
echo "→ Installing dependencies (forced)"
npm install --force

# 8. Optional: auto git commit + push
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "→ Git repo detected — committing changes"
  git add .
  git commit -m "Automated Vite + Theme upgrade via u.sh" || echo "→ Nothing to commit"
  git push || echo "→ Push failed (maybe no remote?)"
fi

echo "=== Done! Starting dev server ==="
npm run dev
