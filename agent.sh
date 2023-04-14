#!/bin/bash

# Load configuration from file
source config.sh

# Get all regions where EC2 instances are running
REGION_LIST=$(aws ec2 describe-regions --output text | awk '{print $NF}')

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

# Define connectivity check function using SSM Run Command
check_connectivity() {
    local instance_id="$1"
    local ping_command='ping -c 1 -W 1'
    local result=$(aws ssm send-command --document-name "AWS-RunShellScript" --instance-ids "$instance_id" \
                   --parameters "commands=$ping_command $instance_id" --output text --query 'CommandInvocations[0].CommandPlugins[0].Output')
    echo "$result"
}

# Gather data from current instance
gather_data() {
    local instance_id="$1"
    local instance_data=''
    # Get instance type
    local instance_type=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                          --region "$REGION" --output text --query 'Reservations[0].Instances[0].InstanceType')
    # Get instance state
    local instance_state=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                           --region "$REGION" --output text --query 'Reservations[0].Instances[0].State.Name')
    # Get private IP address
    local private_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                       --region "$REGION" --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')
    # Get public IP address
    local public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                      --region "$REGION" --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
    # Get availability zone
    local availability_zone=$(aws ec2 describe-instances --instance-ids "$instance_id" \
                             --region "$REGION" --output text --query 'Reservations[0].Instances[0].Placement.AvailabilityZone')
    # Call heartbeat check function
    local heartbeat_check=$(check_heartbeat)
    # Call connectivity check function
    local connectivity_check=$(check_connectivity "$instance_id")
    # Create instance data string
    instance_data="${instance_id},${instance_type},${instance_state},${private_ip},${public_ip},${availability_zone},${heartbeat_check},${connectivity_check}"
    echo "$instance_data"
}

# Send instance data to control panel
send_data_to_control_panel() {
    local instance_data="$1"
    # Send instance data to control panel using POST request
    curl -s -X POST -d "$instance_data" "$CONTROL_PANEL_URL"
}

# Main logic
main() {
    while true; do
        for region in $REGION_LIST; do
            # Get all EC2 instances in the current region
            INSTANCE_LIST=$(aws ec2 describe-instances --region "$region" --output text --query 'Reservations[].Instances[].InstanceId')
            # Loop through each instance and gather data
            for instance_id in $INSTANCE_LIST; do
                instance_data=$(gather_data "$instance_id")
                # Send instance data to control panel
                send_data_to_control_panel "$instance_data"
            done
        done

        # Sleep for specified interval before checking again
        sleep "$HEARTBEAT_INTERVAL"
    done
}

# Call the main logic
main
