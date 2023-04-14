#!/bin/bash

# Load configuration from file
source config.sh

# Get current instance ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Define heartbeat check function
check_heartbeat() {
    # Ping a host (e.g., google.com) and check if it responds
    ping -c 1 -W 1 127.0.0.1 >/dev/null 2>&1
        # Capture the exit code of the ping command
    local exit_code=$?
   # Return 0 if exit code is 0, indicating a successful ping (heartbeat detected), otherwise return 1
    if [ $exit_code -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Define connectivity check function
check_connectivity() {
    # Implement connectivity checking logic here
    # Example: Use AWS CloudTrail or other monitoring tools to check connections
    # Return connection information, such as source IP addresses, destination IP addresses, etc.
    return 0
}

# Gather data from current instance
gather_data() {
    local instance_id="$1"
    local instance_data=''
    # Get instance type
    local instance_type=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                          --region us-east-1 --output text --query 'Reservations[0].Instances[0].InstanceType')
    # Get instance state
    local instance_state=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                           --region us-east-1 --output text --query 'Reservations[0].Instances[0].State.Name')
    # Get private IP address
    local private_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                       --region us-east-1 --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')
    # Get public IP address
    local public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                      --region us-east-1 --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
    # Call heartbeat check function
    local heartbeat_check=$(check_heartbeat)
    # Call connectivity check function
    local connectivity_check=$(check_connectivity)
    # Create instance data string
    instance_data="${instance_id},${instance_type},${instance_state},${private_ip},${public_ip},${heartbeat_check},${connectivity_check}"
    echo "$instance_data"
}

# Send instance data to control panel
send_data_to_control_panel() {
    local instance_data="$1"
    # Send instance data to control panel using POST request
    #curl -s -X POST -d "$instance_data" "$CONTROL_PANEL_URL"
        # Generate HTML content with instances data
    local html_content=$(cat <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Control Panel</title>
    <style>
        /* CSS styles go here */
    </style>
</head>
<body>
    <h1>Instances</h1>
    <table>
        <tr>
            <th>Instance ID</th>
            <th>Instance Type</th>
            <th>Instance State</th>
            <th>Private IP</th>
            <th>Public IP</th>
            <th>Heartbeat</th>
            <th>Connectivity</th>
        </tr>
        $instance_data
    </table>
</body>
</html>
EOF
)
    # Save HTML content to a file
    echo "$html_content" > control_panel.html

}

# Main logic
main() {
    while true; do
        # Gather data from current instance
        local instance_data=$(gather_data "$INSTANCE_ID")
        # Send instance data to control panel
        send_data_to_control_panel "$instance_data"
        # Sleep for 60 seconds
        sleep 60
    done
}

# Start main logic
main
