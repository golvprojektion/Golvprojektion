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
