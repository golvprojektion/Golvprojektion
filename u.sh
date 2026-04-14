#!/bin/bash

# Create project directories
mkdir -p src/components src/utils src/tests docs

# Create React components
cat <<EOF > src/components/ExampleComponent.tsx
import React from 'react';

const ExampleComponent: React.FC = () => {
    return <div>Hello, World!</div>;
};

export default ExampleComponent;
EOF

# Create utility functions
cat <<EOF > src/utils/util.ts
export const exampleUtil = (): string => {
    return 'Utility function';
};
EOF

# Create test file
cat <<EOF > src/tests/ExampleComponent.test.tsx
import { render } from '@testing-library/react';
import ExampleComponent from '../components/ExampleComponent';

test('renders without crashing', () => {
    render(<ExampleComponent />);
});
EOF

# Create configuration files
cat <<EOF > tsconfig.json
{
    "compilerOptions": {
        "target": "es5",
        "module": "commonjs",
        "jsx": "react",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true
    },
    "include": ["src"]
}
EOF

cat <<EOF > .eslintrc.json
{
    "extends": "react-app",
    "rules": {
        // Add your custom rules here
    }
}
EOF

# Create documentation files
cat <<EOF > docs/README.md
# Project Title

## Description
This project is an interactive floor projection based on React and TypeScript.

## Installation
Run `npm install` to install all dependencies.
EOF

# Commit and push changes
git add .
git commit -m "Initial project structure and files created on 2026-04-14"
git push

# Install npm packages
npm install
