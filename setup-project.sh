#!/bin/bash

# Create project directories
mkdir -p src/{controllers,models,views}
mkdir -p docs
mkdir -p config

# Create source files
touch src/controllers/controller.js
touch src/models/model.js
touch src/views/view.js

# Create documentation files
touch docs/README.md
touch docs/INSTALL.md

# Create configuration files
touch config/default.json
touch config/config.yml

# Output completion message
echo "Project setup is complete."