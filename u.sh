#!/usr/bin/env bash

echo "=== u.sh — Magenta PrimeWave Blob v3 (Stable Build) ==="

# Ensure jq
if ! command -v jq &> /dev/null
then
  echo "→ Installing jq"
  sudo apt-get update && sudo apt-get install -y jq
fi

# Clean
rm -rf node_modules package-lock.json

# Fix package.json
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
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Golvprojektion Blob</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  </head>
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

# tsconfig.json
cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "skipLibCheck": true,
    "esModuleInterop": true,
    "strict": false,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": "./",
    "paths": { "src/*": ["src/*"] }
  },
  "include": ["src"]
}
EOF

# Create folders
mkdir -p src src/components src/theme src/engine

# theme
cat << 'EOF' > src/theme/index.ts
export const Pink = { pure:"#F0F", alt:"#F0B", alt2:"#F2A" };
export const Turquoise = { pure:"#00FAD0", strong:"#00D4A8" };
export const Floor = { base:"#F5F2EB" };
const Theme = { Pink, Turquoise, Floor };
export default Theme;
EOF

# PrimeWaveEngine
cat << 'EOF' > src/engine/primeWave.ts
export function primeRadius(base: number, t: number, angle: number): number {
  return (
    base +
    Math.sin(angle * 11 + t * 3) * 12 +
    Math.sin(angle * 13 + t * 2) * 7 +
    Math.sin(angle * 17 + t * 4) * 5 +
    Math.sin(angle * 19 + t * 1.5) * 3
  );
}
EOF

# LiquidPinkBlob
cat << 'EOF' > src/components/LiquidPinkBlob.tsx
import { useRef, useEffect } from "react";
import Theme from "src/theme";
import { primeRadius } from "src/engine/primeWave";

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
    let mouseX: number | null = null;
    let mouseY: number | null = null;

    window.addEventListener("mousemove", e => {
      mouseX = e.clientX;
      mouseY = e.clientY;
    });

    const blob = {
      x: window.innerWidth / 2,
      y: window.innerHeight / 2,
      vx: 0,
      vy: 0,
      r: Math.min(window.innerWidth, window.innerHeight) * 0.22
    };

    const loop = () => {
      t += 0.012;

      const w = canvas.width;
      const h = canvas.height;

      ctx.clearRect(0, 0, w, h);
      ctx.fillStyle = Theme.Floor.base;
      ctx.fillRect(0, 0, w, h);

      // Physics
      const tx = mouseX ?? w / 2;
      const ty = mouseY ?? h / 2;

      blob.vx += (tx - blob.x) * 0.01;
      blob.vy += (ty - blob.y) * 0.01;

      blob.vx *= 0.92;
      blob.vy *= 0.92;

      blob.x += blob.vx;
      blob.y += blob.vy;

      // Draw blob
      ctx.beginPath();
      const waves = 11;
      for (let i = 0; i <= waves; i++) {
        const angle = (i / waves) * Math.PI * 2;
        const radius = primeRadius(blob.r, t, angle);
        const x = blob.x + Math.cos(angle) * radius;
        const y = blob.y + Math.sin(angle) * radius;
        if (i === 0) ctx.moveTo(x, y);
        else ctx.quadraticCurveTo(x, y, x, y);
      }

      // Internal stripes
      ctx.save();
      ctx.clip();
      ctx.globalAlpha = 0.08;
      ctx.strokeStyle = "#767";
      ctx.lineWidth = 1;
      for (let i = -h; i < w; i += 10) {
        ctx.beginPath();
        ctx.moveTo(i + (t * 40) % 10, 0);
        ctx.lineTo(i + h + (t * 40) % 10, h);
        ctx.stroke();
      }
      ctx.restore();

      // Fill
      ctx.fillStyle = Theme.Pink.pure;
      ctx.fill();

      // Outline
      ctx.strokeStyle = Theme.Turquoise.pure;
      ctx.lineWidth = 18;
      ctx.stroke();

      requestAnimationFrame(loop);
    };

    loop();
  }, []);

  return <canvas ref={canvasRef} style={{ position:"fixed", inset:0 }} />;
}
EOF

# App.tsx
cat << 'EOF' > src/App.tsx
import LiquidPinkBlob from "src/components/LiquidPinkBlob";
export default function App() { return <LiquidPinkBlob />; }
EOF

# index.tsx
cat << 'EOF' > src/index.tsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode><App /></React.StrictMode>
);
EOF

# Install
npm install --force

# Git
if git rev-parse --git-dir > /dev/null 2>&1; then
  git add .
  git commit -m "Stable Magenta PrimeWave Blob v3" || true
  git push || true
fi

npm run dev
