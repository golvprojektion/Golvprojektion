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
