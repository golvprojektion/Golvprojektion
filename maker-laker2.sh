#!/bin/bash
# setup-project.sh - Creates all project files locally

mkdir -p src/components docs public

# Create .gitignore
cat > .gitignore << 'EOF'
node_modules/
build/
dist/
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*

.DS_Store
*.swp
*.swo
*~

.vscode/
.idea/
*.sublime-project
*.sublime-workspace
EOF

# Create public/styles.css
cat > public/styles.css << 'EOF'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
        'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    background-color: #1a1a1a;
    color: #ffffff;
}

html, body, #root {
    width: 100%;
    height: 100%;
}
EOF

# Create public/index.html
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Floor Projection System</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div id="root"></div>
</body>
</html>
EOF

# Create src/index.tsx
cat > src/index.tsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import '../public/styles.css';

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);
EOF

# Create src/App.tsx
cat > src/App.tsx << 'EOF'
import React, { useState } from 'react';
import ProjectionCanvas from './components/ProjectionCanvas';
import ControlPanel from './components/ControlPanel';
import './App.css';

const App: React.FC = () => {
  const [isPlaying, setIsPlaying] = useState(true);
  const [brightness, setBrightness] = useState(100);
  const [color, setColor] = useState('#ff0000');
  const [speed, setSpeed] = useState(1);
  const [scale, setScale] = useState(1);

  return (
    <div className="app-container">
      <ProjectionCanvas 
        isPlaying={isPlaying}
        brightness={brightness}
        color={color}
        speed={speed}
        scale={scale}
      />
      <ControlPanel 
        isPlaying={isPlaying}
        brightness={brightness}
        color={color}
        speed={speed}
        scale={scale}
        onPlayToggle={() => setIsPlaying(!isPlaying)}
        onBrightnessChange={setBrightness}
        onColorChange={setColor}
        onSpeedChange={setSpeed}
        onScaleChange={setScale}
        onReset={() => {
          setIsPlaying(true);
          setBrightness(100);
          setColor('#ff0000');
          setSpeed(1);
          setScale(1);
        }}
      />
    </div>
  );
};

export default App;
EOF

# Create src/App.css
cat > src/App.css << 'EOF'
.app-container {
  display: flex;
  height: 100vh;
  width: 100vw;
  background-color: #0a0a0a;
}

.projection-canvas {
  flex: 1;
  position: relative;
}

.control-panel {
  width: 300px;
  background-color: #1a1a1a;
  border-left: 1px solid #333;
  padding: 20px;
  overflow-y: auto;
  box-shadow: -2px 0 10px rgba(0, 0, 0, 0.5);
}
EOF

# Create src/components/ProjectionCanvas.tsx
cat > src/components/ProjectionCanvas.tsx << 'EOF'
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
EOF

# Create src/components/ControlPanel.tsx
cat > src/components/ControlPanel.tsx << 'EOF'
import React from 'react';

interface ControlPanelProps {
  isPlaying: boolean;
  brightness: number;
  color: string;
  speed: number;
  scale: number;
  onPlayToggle: () => void;
  onBrightnessChange: (value: number) => void;
  onColorChange: (value: string) => void;
  onSpeedChange: (value: number) => void;
  onScaleChange: (value: number) => void;
  onReset: () => void;
}

const ControlPanel: React.FC<ControlPanelProps> = ({
  isPlaying,
  brightness,
  color,
  speed,
  scale,
  onPlayToggle,
  onBrightnessChange,
  onColorChange,
  onSpeedChange,
  onScaleChange,
  onReset
}) => {
  return (
    <div className="control-panel">
      <h2>Controls</h2>
      
      <button onClick={onPlayToggle} style={{ marginTop: '20px', padding: '10px 20px' }}>
        {isPlaying ? 'Pause' : 'Play'}
      </button>

      <div style={{ marginTop: '20px' }}>
        <label>Brightness: {brightness}%</label>
        <input
          type="range"
          min="0"
          max="100"
          value={brightness}
          onChange={(e) => onBrightnessChange(Number(e.target.value))}
          style={{ width: '100%' }}
        />
      </div>

      <div style={{ marginTop: '15px' }}>
        <label>Color</label>
        <input
          type="color"
          value={color}
          onChange={(e) => onColorChange(e.target.value)}
          style={{ width: '100%', height: '40px' }}
        />
      </div>

      <div style={{ marginTop: '15px' }}>
        <label>Speed: {speed.toFixed(1)}</label>
        <input
          type="range"
          min="0.1"
          max="3"
          step="0.1"
          value={speed}
          onChange={(e) => onSpeedChange(Number(e.target.value))}
          style={{ width: '100%' }}
        />
      </div>

      <div style={{ marginTop: '15px' }}>
        <label>Scale: {scale.toFixed(1)}</label>
        <input
          type="range"
          min="0.5"
          max="3"
          step="0.1"
          value={scale}
          onChange={(e) => onScaleChange(Number(e.target.value))}
          style={{ width: '100%' }}
        />
      </div>

      <button onClick={onReset} style={{ marginTop: '20px', padding: '10px 20px', width: '100%' }}>
        Reset
      </button>
    </div>
  );
};

export default ControlPanel;
EOF

# Create README.md
cat > README.md << 'EOF'
# Golvprojektion - Interactive Floor Projection System

A web-based interactive floor projection system for creating dynamic, real-time visual experiences.

## Features

- Real-time canvas rendering
- Interactive control panel
- Adjustable brightness, color, speed, and scale
- Play/Pause controls
- Built with React and TypeScript

## Quick Start

1. **Install Dependencies:**
   ```bash
   npm install
   ```

2. **Start Development Server:**
   ```bash
   npm start
   ```

3. **Open in Browser:**
   Navigate to `http://localhost:3000`

## Documentation

- [Setup Guide](docs/SETUP.md)
- [Calibration Guide](docs/CALIBRATION.md)
- [API Reference](docs/API.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

MIT License
EOF

# Create docs/SETUP.md
cat > docs/SETUP.md << 'EOF'
# Setup Guide

## Prerequisites

- Node.js 14+ 
- npm or yarn

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/golvprojektion/Golvprojektion.git
   cd Golvprojektion
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Open your browser to `http://localhost:3000`

## Project Structure

```
Golvprojektion/
├── public/
│   ├── index.html
│   └── styles.css
├── src/
│   ├── components/
│   │   ├── ProjectionCanvas.tsx
│   │   └── ControlPanel.tsx
│   ├── App.tsx
│   ├── App.css
│   └── index.tsx
├── docs/
├── package.json
└── README.md
```

## Development

For development, use `npm start` which will start the React development server with hot reload.

For production build, use `npm run build`.
EOF

# Create docs/CALIBRATION.md
cat > docs/CALIBRATION.md << 'EOF'
# Calibration Guide

## Projector Calibration

1. **Position the Projector:**
   - Mount the projector above the floor at the desired angle
   - Ensure the projection area is clear and clean

2. **Adjust Focus and Keystone:**
   - Use your projector's focus controls to sharpen the image
   - Adjust keystone to correct any distortion

3. **Calibrate in Software:**
   - Use the control panel to adjust brightness and colors
   - Test with different colors to ensure accurate projection

4. **Fine-tuning:**
   - Adjust speed and scale settings for your specific use case
   - Test interactive elements for responsiveness

## Touch Sensor Calibration

If using touch sensors, calibrate them according to your sensor manufacturer's specifications.

## Tips

- Test in a dark environment for best results
- Ensure adequate ventilation around the projector
- Regular cleaning of the projector lens improves image quality
EOF

echo "✅ All project files created successfully!"
echo ""
echo "Next steps:"
echo "1. git add ."
echo "2. git commit -m 'Initial project setup'"
echo "3. git push"
```

**How to use this:**

1. Save the script above as `setup-project.sh` in your repo
2. Run: `bash setup-project.sh`
3. Then just do:
   ```bash
   git add .
   git commit -m "Initial project setup"
   git push
   ```

