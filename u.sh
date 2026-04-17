#!/usr/bin/env bash

echo "=== u.sh — Golvprojektion Magenta Blob Setup ==="

# 0. Ensure jq
if ! command -v jq &> /dev/null
then
  echo "→ Installing jq"
  sudo apt-get update && sudo apt-get install -y jq
fi

# 1. Clean node_modules and lock
echo "→ Cleaning node_modules and lockfile"
rm -rf node_modules package-lock.json

# 2. Normalize package.json for Vite + React 18 + TS5
echo "→ Updating package.json"
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

# 3. index.html
echo "→ Writing index.html"
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Golvprojektion Blob</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  </head>
  <body style="margin:0; padding:0; overflow:hidden; background:#000100;">
    <div id="root"></div>
    <script type="module" src="/src/index.tsx"></script>
  </body>
</html>
EOF

# 4. vite.config.ts
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

# 5. tsconfig.json (minimal, Vite-friendly)
echo "→ Writing tsconfig.json"
cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": "./",
    "paths": {
      "src/*": ["src/*"]
    }
  },
  "include": ["src"]
}
EOF

# 6. Ensure src structure
echo "→ Ensuring src structure"
mkdir -p src src/components src/theme

# 7. theme/index.ts
echo "→ Writing src/theme/index.ts"
cat << 'EOF' > src/theme/index.ts
export const Pink = {
  pure: "#F0F",
  alt: "#F0B",
  alt2: "#F2A"
};

export const Turquoise = {
  pure: "#00FAD0",
  strong: "#00D4A8"
};

export const Floor = {
  base: "#F5F2EB"
};

const Theme = { Pink, Turquoise, Floor };
export default Theme;
EOF

# 8. LiquidPinkBlob.tsx
echo "→ Writing src/components/LiquidPinkBlob.tsx"
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

      // Background: projection-friendly off-white
      ctx.fillStyle = Theme.Floor.base;
      ctx.fillRect(0, 0, w, h);

      const cx = w / 2;
      const cy = h / 2;

      ctx.beginPath();

      const waves = 11; // prime for nice irregularity
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
        display: "block"
      }}
    />
  );
}
EOF

# 9. App.tsx
echo "→ Writing src/App.tsx"
cat << 'EOF' > src/App.tsx
import LiquidPinkBlob from "src/components/LiquidPinkBlob";

export default function App() {
  return <LiquidPinkBlob />;
}
EOF

# 10. index.tsx
echo "→ Writing src/index.tsx"
cat << 'EOF' > src/index.tsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

const rootElement = document.getElementById("root") as HTMLElement;
const root = ReactDOM.createRoot(rootElement);

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# 11. Install deps
echo "→ Installing dependencies (forced)"
npm install --force

# 12. Git add/commit/push
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "→ Git repo detected — committing and pushing"
  git add .
  git commit -m "Magenta prime-wave blob setup via u.sh" || echo "→ Nothing to commit"
  git push || echo "→ Push failed (check remote)"
fi

# 13. Start dev server
echo "=== Starting dev server ==="
npm run dev
