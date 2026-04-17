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
