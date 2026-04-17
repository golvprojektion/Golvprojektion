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
