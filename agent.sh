#!/bin/bash

# Load configuration from file
source config.sh

# Discover all regions where EC2 instances are running
discovered_regions=$(aws ec2 describe-regions --output text --query 'Regions[].RegionName')

# Loop through each discovered region
for region in $discovered_regions; do
  # List all EC2 instances in the region
  instance_ids=$(aws ec2 describe-instances --region "$region" --output text --query 'Reservations[].Instances[].InstanceId')

  # Loop through each instance ID
  for instance_id in $instance_ids; do
    # Define heartbeat check function
    check_heartbeat() {
      # Ping the instance and check if it responds
      ping -c 1 -W 1 "$(aws ec2 describe-instances --region "$region" --instance-ids "$instance_id" --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')" >/dev/null 2>&1
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
      local instance_data=''
      # Get instance type
      local instance_type=$(aws ec2 describe-instances --region "$region" --instance-ids "$instance_id" --output text --query 'Reservations[0].Instances[0].InstanceType')
      # Get instance state
      local instance_state=$(aws ec2 describe-instances --region "$region" --instance-ids "$instance_id" --output text --query 'Reservations[0].Instances[0].State.Name')
      # Get private IP address
      local private_ip=$(aws ec2 describe-instances --region "$region" --instance-ids "$instance_id" --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')
      # Get public IP address
      local public_ip=$(aws ec2 describe-instances --region "$region" --instance-ids "$instance_id" --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
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
      curl -s -X POST -d "$instance_data" "$CONTROL_PANEL_URL"
    }

    # Main logic
    main() {
      while true; do
        # Gather data from current instance
        local instance_data=$(gather_data)
        # Send instance data to control panel
        send_data_to_control_panel "$instance_data"
        # Sleep
        # Sleep for specified interval before checking again
        sleep "$HEARTBEAT_INTERVAL_SECONDS"
      done
    }

    # Run main logic
    main &

done