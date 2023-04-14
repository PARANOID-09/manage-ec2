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
SLEEP_INTERVAL=60
