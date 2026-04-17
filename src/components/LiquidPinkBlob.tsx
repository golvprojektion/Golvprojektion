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
