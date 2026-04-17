#!/usr/bin/env bash

echo "=== u.sh — Pure Magenta Blob Overhaul (Final) ==="

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

# index.html
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

# vite.config.ts
cat << 'EOF' > vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';
export default defineConfig({
  plugins: [react()],
  resolve: { alias: { src: '/src' } }
});
EOF

# theme
mkdir -p src/theme
cat << 'EOF' > src/theme/index.ts
export const Pink = { pure:"#F0F", alt:"#F0B", alt2:"#F2A" };
export const Turquoise = { pure:"#00FAD0", strong:"#00D4A8" };
export const Floor = { base:"#F5F2EB" };
export default { Pink, Turquoise, Floor };
EOF

# LiquidPinkBlob.tsx
mkdir -p src/components
cat << 'EOF' > src/components/LiquidPinkBlob.tsx
import { useRef, useEffect } from "react";
import Theme from "src/theme";

export default function LiquidPinkBlob() {
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
      t += 0.012;

      const w = canvas.width;
      const h = canvas.height;
      const r = Math.min(w, h) * 0.22;

      ctx.clearRect(0, 0, w, h);

      // Background
      ctx.fillStyle = Theme.Floor.base;
      ctx.fillRect(0, 0, w, h);

      const cx = w / 2;
      const cy = h / 2;

      ctx.beginPath();

      const waves = 11; // prime
      for (let i = 0; i <= waves; i++) {
        const angle = (i / waves) * Math.PI * 2;

        // multi-frequency wobble
        const w1 = Math.sin(angle * 11 + t * 3) * 12;
        const w2 = Math.sin(angle * 13 + t * 2) * 6;
        const w3 = Math.sin(angle * 17 + t * 4) * 4;

        const radius = r + w1 + w2 + w3;

        const x = cx + Math.cos(angle) * radius;
        const y = cy + Math.sin(angle) * radius;

        if (i === 0) ctx.moveTo(x, y);
        else ctx.quadraticCurveTo(x, y, x, y);
      }

      // Pure magenta fill
      ctx.fillStyle = Theme.Pink.pure;
      ctx.fill();

      // Thick turquoise outline
      ctx.strokeStyle = Theme.Turquoise.pure;
      ctx.lineWidth = 18;
      ctx.shadowBlur = 0;
      ctx.stroke();

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

# App.tsx
cat << 'EOF' > src/App.tsx
import LiquidPinkBlob from "src/components/LiquidPinkBlob";
export default function App() { return <LiquidPinkBlob />; }
EOF

npm install --force

# git commit + push
if git rev-parse --git-dir > /dev/null 2>&1; then
  git add .
  git commit -m "Final pure magenta blob implementation" || true
  git push || true
fi

npm run dev
