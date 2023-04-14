#!/bin/bash

# Generate config.sh with default values
cat > config.sh <<EOF
# Configuration file for agent.sh
# Update these values as needed

# Control panel URL
CONTROL_PANEL_URL="http://localhost:5000/receive_data"

# AWS region
AWS_REGION="us-east-1"

# AWS SSM document name for ping command
PING_DOCUMENT_NAME="AWS-RunShellScript"

# Additional parameters for ping command
PING_DOCUMENT_PARAMETERS=""

# Sleep interval in seconds
HEARTBEAT_INTERVAL=60
EOF

# Prompt user for AWS access key and secret access key
read -p "Enter AWS access key: " AWS_ACCESS_KEY
read -p "Enter AWS secret access key: " AWS_SECRET_ACCESS_KEY

# Set AWS access key and secret access key as environment variables
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

# Start app.py in background
python3 app.py &

# Run agent.sh
bash agent.sh
