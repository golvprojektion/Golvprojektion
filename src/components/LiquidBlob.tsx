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
