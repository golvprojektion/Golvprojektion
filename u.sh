#!/usr/bin/env bash

echo "=== u.sh — Full Visual Overhaul + Vite + Blob ==="

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

# 4. Overwrite index.html
echo "→ Writing index.html"
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Golvprojektion</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  </head>
  <body style="margin:0; padding:0; overflow:hidden; background:#000100;">
    <div id="root"></div>
    <script type="module" src="/src/index.tsx"></script>
  </body>
</html>
EOF

# 5. Create vite.config.ts
echo "→ Writing vite.config.ts"
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
  base: "#F5F2EB",
  grainLight: "#E8E3D9",
  grainDark: "#D6D0C4",

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

# 7. Create LiquidBlob component
echo "→ Writing LiquidBlob.tsx"

mkdir -p src/components

cat << 'EOF' > src/components/LiquidBlob.tsx
import { useRef, useEffect } from "react";
import Theme from "src/theme";

export default function LiquidBlob() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current!;
    const ctx = canvas.getContext("2d")!;

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    resize();
    window.addEventListener("resize", resize);

    let t = 0;

    const loop = () => {
      t += 0.015;

      const w = canvas.width;
      const h = canvas.height;
      const r = Math.min(w, h) * 0.18;

      ctx.clearRect(0, 0, w, h);

      // Background
      ctx.fillStyle = Theme.Floor.base;
      ctx.fillRect(0, 0, w, h);

      // Micro diagonal stripes
      ctx.globalAlpha = 0.06;
      ctx.strokeStyle = "#767";
      ctx.lineWidth = 1;
      for (let i = -h; i < w; i += 12) {
        ctx.beginPath();
        ctx.moveTo(i, 0);
        ctx.lineTo(i + h, h);
        ctx.stroke();
      }
      ctx.globalAlpha = 1;

      const cx = w / 2;
      const cy = h / 2;

      ctx.beginPath();

      const waves = 48;
      for (let i = 0; i <= waves; i++) {
        const angle = (i / waves) * Math.PI * 2;
        const wave = Math.sin(angle * 3 + t * 2) * 14;
        const radius = r + wave;

        const x = cx + Math.cos(angle) * radius;
        const y = cy + Math.sin(angle) * radius;

        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }

      // Pink gradient fill
      const grad = ctx.createRadialGradient(cx, cy, r * 0.2, cx, cy, r * 1.2);
      grad.addColorStop(0, Theme.Pink.pinkSoft);
      grad.addColorStop(0.5, Theme.Pink.pink);
      grad.addColorStop(1, Theme.Pink.pinkHot);

      ctx.fillStyle = grad;
      ctx.fill();

      // Turquoise shimmer outline
      ctx.strokeStyle = Theme.Turquoise.accent;
      ctx.lineWidth = 4;
      ctx.shadowBlur = 25;
      ctx.shadowColor = Theme.Turquoise.accent;
      ctx.stroke();

      ctx.shadowBlur = 0;

      requestAnimationFrame(loop);
    };

    loop();

    return () => window.removeEventListener("resize", resize);
  }, []);

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: "fixed",
        inset: 0,
        width: "100vw",
        height: "100vh",
        display: "block",
      }}
    />
  );
}
EOF

# 8. Overwrite App.tsx
echo "→ Writing App.tsx"

cat << 'EOF' > src/App.tsx
import LiquidBlob from "src/components/LiquidBlob";

export default function App() {
  return <LiquidBlob />;
}
EOF

# 9. Install dependencies
echo "→ Installing dependencies (forced)"
npm install --force

# 10. Git auto commit + push
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "→ Git repo detected — committing changes"
  git add .
  git commit -m "Visual overhaul + LiquidBlob + theme system" || echo "→ Nothing to commit"
  git push || echo "→ Push failed (maybe no remote?)"
fi

echo "=== Done! Starting dev server ==="
npm run dev
