#!/bin/bash
# Default layer name with today's date
DEFAULT_LAYER_NAME="lambda-layer-$(date +%d%m%Y)"
LAYER_NAME=$1
BUCKET=$2

# Guidance on how to use this script
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: ./zip-and-upload.sh [layer_name] [bucket_name]"
  echo "Example: ./zip-and-upload.sh my-lambda-layer my-bucket"
  exit 0
fi

echo "🐍️ Getting current Python version for deployment"
PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
# Extract major.minor version for Lambda runtime compatibility
PYTHON_RUNTIME_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1"."$2}')
COMPATIBLE_RUNTIME="python$PYTHON_RUNTIME_VERSION"
echo "🐍️ Current Python version: $PYTHON_VERSION (Runtime: $COMPATIBLE_RUNTIME)"

# Parameters check
if [ -z "$LAYER_NAME" ]; then
  LAYER_NAME=$DEFAULT_LAYER_NAME
  echo "No layer name provided, using default: $LAYER_NAME"
fi
# Create zip file name from layer name
ZIP_FILE_NAME="${LAYER_NAME}.zip"
echo "Parameters verified ✅️"

echo "⏳️ Creating zip file ..."
# Delete the zip file if it exists
rm -f ./output/$ZIP_FILE_NAME
# Zip the content of the /src folder into a zip file
cd ./src
mkdir -p ../output/
if [ "$INCLUDE_CHROME" = true ]; then
  zip -qr9 ../output/$ZIP_FILE_NAME .
else
  zip -qr9 ../output/$ZIP_FILE_NAME . -x "chromedriver" "chrome"
fi
cd ..
echo "✅️ Zip file created successfully"
# If no bucket is provided, don't upload
if [ -z "$BUCKET" ]; then
  echo "ℹ️ No bucket provided, skipping upload"
  echo "✅️ Zip file created at: output/$ZIP_FILE_NAME"
  exit 0
fi
echo "⏳️ Uploading to AWS S3 bucket: $BUCKET ..."
# Upload the Lambda layer to AWS
aws s3 cp output/$ZIP_FILE_NAME s3://$BUCKET/$ZIP_FILE_NAME
# Create the Lambda layer
# Layer name is already defined, no need to extract from ZIP filename
# Get current AWS region from AWS CLI configuration
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
  echo "ℹ️ No AWS region found in configuration, using default: $AWS_REGION"
fi

echo "⏳️ Publishing Lambda layer: $LAYER_NAME in region: $AWS_REGION ..."
aws lambda publish-layer-version --layer-name $LAYER_NAME --content S3Bucket=$BUCKET,S3Key=$ZIP_FILE_NAME --compatible-runtimes $COMPATIBLE_RUNTIME --compatible-architectures x86_64 --region $AWS_REGION
echo "✅️ Lambda layer published successfully"
