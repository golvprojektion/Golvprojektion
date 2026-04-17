#!/bin/bash

# Step 1: Setup React Components and Utilities
echo "Setting up React components and utilities..."
mkdir src
cd src
mkdir components utils
# Example components
echo "import React from 'react';\n\nconst ExampleComponent = () => <div>Hello World</div>;\nexport default ExampleComponent;" > components/ExampleComponent.js
# Add more components as needed...

# Step 2: Create configuration files
echo "Creating configuration files..."
touch .env
echo "REACT_APP_API_URL=http://api.example.com" > .env

# Step 3: Setup Docker
echo "Creating Docker files..."
touch Dockerfile
echo "FROM node:14\nWORKDIR /app\nCOPY . .\nRUN npm install\nCMD ['npm', 'start']" > Dockerfile

# Step 4: Setting up CI/CD workflows
echo "Setting up CI/CD workflows..."
mkdir .github
mkdir .github/workflows
echo "name: CI\non: [push]\njobs:\n  build:\n    runs-on: ubuntu-latest\n    steps:\n      - name: Checkout code\n        uses: actions/checkout@v2\n      - name: Install dependencies\n        run: npm install\n      - name: Run tests\n        run: npm test" > .github/workflows/ci.yml

# Step 5: Documentation
echo "Generating documentation..."
mkdir docs
echo "# Project Documentation" > docs/README.md

# Step 6: Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Step 7: Git operations
echo "Adding files to git..."
git add .
git commit -m "Initial setup for interactive floor projection project"
git push origin main

echo "Setup complete!"