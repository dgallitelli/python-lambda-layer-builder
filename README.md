# Lambda Layer Builder

A utility for building and deploying AWS Lambda Layers with Python dependencies.

## Overview

This repository contains scripts to help you:
1. Install Python dependencies in a virtual environment
2. Package them into a Lambda Layer compatible zip file
3. Upload the zip file to an S3 bucket
4. Publish the Lambda Layer to AWS

## Prerequisites

- AWS CLI configured with appropriate permissions
- Python 3.x installed
- Bash shell environment

## Directory Structure

```
lambda-layer-builder/
├── output/             # Output directory for generated zip files
├── src/                # Source directory containing dependencies
│   ├── python/         # Python packages for the Lambda Layer
│   └── requirements.txt # Python dependencies to install
├── install-dependencies.sh # Script to install dependencies
└── zip-and-upload.sh   # Script to create and upload Lambda Layer
```

## Usage

### Step 1: Install Dependencies

Run the installation script to set up the virtual environment and install dependencies:

```bash
./install-dependencies.sh
```

This script will:
- Create a Python virtual environment
- Install dependencies from `src/requirements.txt`
- Copy the installed packages to `src/python/lib/`

### Step 2: Create and Upload Lambda Layer

Use the zip-and-upload script to package and deploy your Lambda Layer:

```bash
./zip-and-upload.sh [layer_name] [bucket_name]
```

Parameters:
- `layer_name` (optional): Name of the Lambda layer (default: lambda-layer-DDMMYYYY)
- `bucket_name` (optional): S3 bucket to upload the layer to

Examples:
```bash
# Create zip file only
./zip-and-upload.sh my-lambda-layer

# Create zip file and upload to S3 bucket
./zip-and-upload.sh my-lambda-layer my-s3-bucket
```

The script will:
1. Create a zip file named `[layer_name].zip` containing the contents of the `src/` directory
2. Upload the zip file to the specified S3 bucket (if provided)
3. Publish a new Lambda Layer version using the uploaded zip file
4. Configure the layer to be compatible with the current Python runtime

## Notes

- The Lambda Layer will be compatible with the Python version used to create it
- The Lambda Layer will be published in your configured AWS region (falls back to us-east-1 if not configured)
- The layer will be configured for x86_64 architecture
