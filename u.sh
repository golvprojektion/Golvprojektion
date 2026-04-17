#!/usr/bin/env bash

echo "=== u.sh — Magenta PrimeWave Blob v2 (A+B+C+E+H) ==="

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

# 5. tsconfig.json
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
mkdir -p src src/components src/theme src/engine

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

# 8. PrimeWaveEngine
echo "→ Writing src/engine/primeWave.ts"
cat << 'EOF' > src/engine/primeWave.ts
// PrimeWaveEngine: generates organic multi-frequency motion using primes
export interface PrimeWaveConfig {
  baseRadius: number;
  t: number;
  angle: number;
}

const PRIMES = [11, 13, 17, 19];

export function primeRadius({ baseRadius, t, angle }: PrimeWaveConfig): number {
  let r = baseRadius;
  const amps = [12, 7, 5, 3];

  for (let i = 0; i < PRIMES.length; i++) {
    const p = PRIMES[i];
    const amp = amps[i];
    r += Math.sin(angle * p + t * (3 + i)) * amp;
  }

  return r;
}
EOF

# 9. LiquidPinkBlob with physics, split/merge, interaction, stripes
echo "→ Writing src/components/LiquidPinkBlob.tsx"
cat << 'EOF' > src/components/LiquidPinkBlob.tsx
import { useRef, useEffect } from "react";
import Theme from "src/theme";
import { primeRadius } from "src/engine/primeWave";

interface BlobState {
  x: number;
  y: number;
  vx: number;
  vy: number;
  radius: number;
  targetRadius: number;
}

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

    const w = () => canvas.width;
    const h = () => canvas.height;

    // Two blobs for split/merge
    const blobs: BlobState[] = [
      {
        x: w() / 2,
        y: h() / 2,
        vx: 0,
        vy: 0,
        radius: Math.min(w(), h()) * 0.18,
        targetRadius: Math.min(w(), h()) * 0.18
      },
      {
        x: w() / 2,
        y: h() / 2,
        vx: 0,
        vy: 0,
        radius: Math.min(w(), h()) * 0.18,
        targetRadius: Math.min(w(), h()) * 0.18
      }
    ];

    let splitPhase = 0; // 0 = merged, 1 = fully split
    let mouseX: number | null = null;
    let mouseY: number | null = null;

    const onMove = (e: MouseEvent | TouchEvent) => {
      if ("touches" in e) {
        if (e.touches.length > 0) {
          mouseX = e.touches[0].clientX;
          mouseY = e.touches[0].clientY;
        }
      } else {
        mouseX = e.clientX;
        mouseY = e.clientY;
      }
    };

    const onLeave = () => {
      mouseX = null;
      mouseY = null;
    };

    window.addEventListener("mousemove", onMove);
    window.addEventListener("touchmove", onMove, { passive: true });
    window.addEventListener("mouseleave", onLeave);
    window.addEventListener("touchend", onLeave);

    const loop = () => {
      t += 0.012;

      const width = w();
      const height = h();
      const baseR = Math.min(width, height) * 0.18;

      // Split/merge oscillation
      const splitTarget = (Math.sin(t * 0.25) + 1) / 2; // 0..1
      splitPhase += (splitTarget - splitPhase) * 0.02;

      // Physics update for each blob
      blobs.forEach((blob, index) => {
        // Target position: center, but offset when split
        const offset = baseR * 1.2 * splitPhase;
        const targetX = width / 2 + (index === 0 ? -offset : offset);
        const targetY = height / 2;

        // Mouse attraction
        let attractX = targetX;
        let attractY = targetY;
        if (mouseX !== null && mouseY !== null) {
          const mix = 0.35; // how much it follows the cursor
          attractX = targetX * (1 - mix) + mouseX * mix;
          attractY = targetY * (1 - mix) + mouseY * mix;
        }

        const ax = (attractX - blob.x) * 0.02;
        const ay = (attractY - blob.y) * 0.02;

        blob.vx += ax;
        blob.vy += ay;

        // Damping
        blob.vx *= 0.90;
        blob.vy *= 0.90;

        blob.x += blob.vx;
        blob.y += blob.vy;

        // Radius breathing
        const targetR = baseR * (0.9 + 0.1 * Math.sin(t * 1.7 + index));
        blob.targetRadius = targetR;
        blob.radius += (blob.targetRadius - blob.radius) * 0.12;
      });

      ctx.clearRect(0, 0, width, height);

      // Background
      ctx.fillStyle = Theme.Floor.base;
      ctx.fillRect(0, 0, width, height);

      // Draw each blob
      blobs.forEach((blob) => {
        const cx = blob.x;
        const cy = blob.y;
        const r = blob.radius;

        ctx.save();

        ctx.beginPath();
        const waves = 11; // prime
        for (let i = 0; i <= waves; i++) {
          const angle = (i / waves) * Math.PI * 2;
          const radius = primeRadius({ baseRadius: r, t, angle });

          const x = cx + Math.cos(angle) * radius;
          const y = cy + Math.sin(angle) * radius;

          if (i === 0) ctx.moveTo(x, y);
          else ctx.quadraticCurveTo(x, y, x, y);
        }

        // Clip to blob for internal stripes
        ctx.save();
        ctx.clip();

        // Internal diagonal micro-stripes
        ctx.globalAlpha = 0.08;
        ctx.strokeStyle = "#767";
        ctx.lineWidth = 1;
        const diagStep = 10;
        for (let i = -height; i < width; i += diagStep) {
          ctx.beginPath();
          ctx.moveTo(i + (t * 40) % diagStep, 0);
          ctx.lineTo(i + height + (t * 40) % diagStep, height);
          ctx.stroke();
        }
        ctx.globalAlpha = 1;

        // Fill blob with pure magenta
        ctx.fillStyle = Theme.Pink.pure;
        ctx.fill();

        ctx.restore();

        // Outline
        ctx.strokeStyle = Theme.Turquoise.pure;
        ctx.lineWidth = 18;
        ctx.shadowBlur = 0;
        ctx.stroke();

        ctx.restore();
      });

      requestAnimationFrame(loop);
    };

    loop();

    return () => {
      window.removeEventListener("resize", resize);
      window.removeEventListener("mousemove", onMove);
      window.removeEventListener("touchmove", onMove);
      window.removeEventListener("mouseleave", onLeave);
      window.removeEventListener("touchend", onLeave);
    };
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

# 10. App.tsx
echo "→ Writing src/App.tsx"
cat << 'EOF' > src/App.tsx
import LiquidPinkBlob from "src/components/LiquidPinkBlob";

export default function App() {
  return <LiquidPinkBlob />;
}
EOF

# 11. index.tsx
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

# 12. Install deps
echo "→ Installing dependencies (forced)"
npm install --force

# 13. Git add/commit/push
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "→ Git repo detected — committing and pushing"
  git add .
  git commit -m "Magenta PrimeWave Blob v2 (A+B+C+E+H)" || echo "→ Nothing to commit"
  git push || echo "→ Push failed (check remote)"
fi

# 14. Start dev server
echo "=== Starting dev server ==="
npm run dev
