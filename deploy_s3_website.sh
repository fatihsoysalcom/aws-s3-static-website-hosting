#!/bin/bash

# This script demonstrates how to set up a simple static website on AWS S3.
# It simulates the core concept of cloud hosting: storing and serving files remotely.

# --- Configuration ---
# Replace with your desired S3 bucket name (must be globally unique)
BUCKET_NAME="my-unique-devto-example-bucket-$(date +%s)"

# Replace with the path to your static website files (e.g., index.html, style.css)
# For this example, we'll create dummy files.
WEBSITE_DIR="./website_files"
INDEX_FILE="index.html"
ERROR_FILE="error.html"

# --- AWS CLI Commands ---

echo "Creating dummy website files..."
mkdir -p "$WEBSITE_DIR"
cat <<EOF > "$WEBSITE_DIR/$INDEX_FILE"
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to AWS S3!</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: #0077cc; }
    </style>
</head>
<body>
    <h1>Hello from your first AWS S3 hosted website!</h1>
    <p>This is a static website served directly from Amazon S3.</p>
</body>
</html>
EOF

cat <<EOF > "$WEBSITE_DIR/$ERROR_FILE"
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: red; }
    </style>
</head>
<body>
    <h1>Page Not Found</h1>
    <p>The requested page could not be found.</p>
</body>
</html>
EOF


echo "Creating S3 bucket: $BUCKET_NAME"
# Create an S3 bucket. The region can be specified if needed, e.g., --region us-east-1
aws s3 mb "s3://$BUCKET_NAME"

echo "Uploading website files to $BUCKET_NAME..."
# Upload all files from the website directory to the bucket.
aws s3 cp "$WEBSITE_DIR/" "s3://$BUCKET_NAME/" --recursive

echo "Configuring bucket for static website hosting..."
# Configure the bucket to serve static website content.
aws s3 website "s3://$BUCKET_NAME/" --index-document "$INDEX_FILE" --error-document "$ERROR_FILE"

echo "Making bucket contents publicly readable..."
# Apply a bucket policy to allow public read access. This is crucial for a website.
# Note: For production, consider more granular permissions or CloudFront.
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy '{ "Version": "2012-10-17", "Statement": [ { "Sid": "PublicReadGetObject", "Effect": "Allow", "Principal": "*", "Action": "s3:GetObject", "Resource": "arn:aws:s3:::'"$BUCKET_NAME"':/*" } ] }'

# Construct the website endpoint URL
# The region is needed for the endpoint. Default is us-east-1 if not specified.
# For other regions, the URL format might differ slightly.
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

echo "\n--------------------------------------------------"
echo "Successfully deployed static website!"
echo "Bucket Name: $BUCKET_NAME"
echo "Website URL: $WEBSITE_URL"
echo "--------------------------------------------------\n"

# Optional: Clean up dummy files
# echo "Cleaning up dummy website files..."
# rm -rf "$WEBSITE_DIR"

exit 0
