# API Reference

## Overview
This document provides an overview of the API for Golvprojektion.

## Endpoints

### 1. Get User Data
- **Endpoint:** `/api/user`
- **Method:** GET
- **Description:** Retrieves the current user data.

### 2. Update User Data
- **Endpoint:** `/api/user`
- **Method:** PUT
- **Description:** Updates the current user data.
- **Request Body:**
    - `name`: string
    - `email`: string

### 3. Get Project Data
- **Endpoint:** `/api/projects`
- **Method:** GET
- **Description:** Retrieves a list of all projects associated with the user.

### 4. Create a New Project
- **Endpoint:** `/api/projects`
- **Method:** POST
- **Description:** Creates a new project.
- **Request Body:**
    - `title`: string
    - `description`: string

### 5. Delete a Project
- **Endpoint:** `/api/projects/{id}`
- **Method:** DELETE
- **Description:** Deletes a project by ID.

## Authentication
All requests require authentication via a bearer token in the `Authorization` header.

## Error Handling
Responses will include a status code and a message.