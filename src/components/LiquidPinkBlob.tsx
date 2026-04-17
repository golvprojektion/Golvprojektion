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
