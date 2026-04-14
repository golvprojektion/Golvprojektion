import React, { useRef, useEffect } from 'react';

const ProjectionCanvas = () => {
    const canvasRef = useRef(null);

    useEffect(() => {
        const canvas = canvasRef.current;
        const context = canvas.getContext('2d');

        const draw = () => {
            // Clear the canvas
            context.clearRect(0, 0, canvas.width, canvas.height);

            // Your drawing logic goes here, e.g., rendering projections
            context.fillStyle = 'rgba(255, 0, 0, 0.5)'; // Example Projection
            context.fillRect(10, 10, 150, 100);
        };

        draw(); // Initial draw

        // Optionally handle window resizing
        const handleResize = () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            draw();
        };

        window.addEventListener('resize', handleResize);
        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);

    return <canvas ref={canvasRef} width={window.innerWidth} height={window.innerHeight} />;
};

export default ProjectionCanvas;