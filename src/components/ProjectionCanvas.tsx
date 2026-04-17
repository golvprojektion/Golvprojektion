import React, { useEffect, useRef } from 'react';

interface ProjectionCanvasProps {
  isPlaying: boolean;
  brightness: number;
  color: string;
  speed: number;
  scale: number;
}

const ProjectionCanvas: React.FC<ProjectionCanvasProps> = ({
  isPlaying,
  brightness,
  color,
  speed,
  scale
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const animationRef = useRef<number>();
  const timeRef = useRef(0);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const animate = () => {
      if (isPlaying) {
        timeRef.current += speed * 0.016;
      }

      ctx.fillStyle = '#0a0a0a';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.save();
      ctx.globalAlpha = brightness / 100;
      ctx.fillStyle = color;

      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;
      const baseRadius = 50 * scale;
      const radius = baseRadius + Math.sin(timeRef.current) * 20;

      ctx.beginPath();
      ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
      ctx.fill();

      ctx.restore();

      animationRef.current = requestAnimationFrame(animate);
    };

    animationRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [isPlaying, brightness, color, speed, scale]);

  return (
    <canvas
      ref={canvasRef}
      className="projection-canvas"
      style={{ flex: 1 }}
    />
  );
};

export default ProjectionCanvas;
