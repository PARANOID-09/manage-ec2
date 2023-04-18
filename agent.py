import subprocess
import json
import os
import requests
from time import sleep
from flask import Flask, render_template, request

app = Flask(__name__)

# Get all regions where EC2 instances are running
region_list = subprocess.check_output(["aws", "ec2", "describe-regions", "--output", "text"]).decode("utf-8").split()
region_list = [region.strip() for region in region_list]

# Define heartbeat check function
def check_heartbeat():
    # Ping a host (e.g., google.com) and check if it responds
    try:
        subprocess.run(["ping", "-c", "1", "-W", "1", "127.0.0.1"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

# Define connectivity check function using SSM Run Command
def check_connectivity(instance_id):
    ping_command = f"ping -c 1 -W 1 {instance_id}"
    result = subprocess.check_output(["aws", "ssm", "send-command", "--document-name", "AWS-RunShellScript", "--instance-ids", instance_id, "--parameters", f"commands={ping_command}", "--output", "text", "--query", "CommandInvocations[0].CommandPlugins[0].Output"]).decode("utf-8").strip()
    return result

# Gather data from current instance
def gather_data(instance_id, region):
    print(f"Gathering data for instance {instance_id} in {region}...")
    # Get instance details in a single describe-instances command to reduce calls to AWS API
    instance_data = subprocess.check_output(["aws", "ec2", "describe-instances", "--instance-ids", instance_id, "--region", region, "--output", "json"]).decode("utf-8")
    instance_data = json.loads(instance_data)["Reservations"][0]["Instances"][0]
    instance_type = instance_data["InstanceType"]
    instance_state = instance_data["State"]["Name"]
    ami_id = instance_data["ImageId"]
    ami_name = subprocess.check_output(["aws", "ec2", "describe-images", "--image-ids", ami_id, "--region", region, "--output", "text", "--query", "Images[0].Name"]).decode("utf-8").strip()
    private_ip = instance_data["PrivateIpAddress"]
    public_ip = instance_data["PublicIpAddress"]
    availability_zone = instance_data["Placement"]["AvailabilityZone"]
    vpc_id = instance_data["VpcId"]
    subnet_id = instance_data["SubnetId"]
    vpc_cidr_block = subprocess.check_output(["aws", "ec2", "describe-vpcs", "--vpc-ids", vpc_id, "--region", region, "--output", "text", "--query", "Vpcs[0].CidrBlock"]).decode("utf-8").strip()
    security_groups = [group["GroupName"] for group in instance_data["SecurityGroups"]]
    instance_profile = instance_data.get("IamInstanceProfile", {}).get("Arn")
    tags = [tag["Key"] + ": " + tag["Value"] for tag in instance_data.get("Tags", [])]
     # Get region name from region code
    region = availability_zone[:-1]  # Extract region code from availability zone
    region_name = get_region_name(region)  # Call custom function to get region name
     # Create instance data dictionary
    instance_data = {
        "InstanceId": instance_id,
        "Region": region_name,
        "InstanceType": instance_type,
        "InstanceState": instance_state,
        "AMI_Name": ami_name, 
        "PrivateIp": private_ip,
        "PublicIp": public_ip,
        "AvailabilityZone": availability_zone,
        "VpcId": vpc_id,
        "SubnetId": subnet_id,
        "Vpc_cidr": vpc_cidr_block,
        "SecurityGroups": security_groups,
        "InstanceProfile": instance_profile,
        "Tags": tags
        }
    instance_data_json = json.dumps(instance_data)

    # Send data to backend server
    url = 'http://localhost:5000/api/instance-data'
    headers = {'Content-Type': 'application/json'}
    response = requests.post(url, data=instance_data_json, headers=headers)

    # Check response status code
    if response.status_code == 200:
        print("Instance data sent to backend successfully.")
    else:
        print("Failed to send instance data to backend.")

    return instance_data

# Create an empty list to store instance data
data = []


# Add instance data to global data list
def add_instance_data(instance_id, region):
    instance_data = gather_data(instance_id, region)
    data.append(instance_data)

# Reguine mapping
def get_region_name(region_code):
    # Define region code to region name mapping
    region_mapping = {
        "us-east-1": "North Virginia",
        "us-east-2": "Ohio",
        "us-west-1": "North California",
        "us-west-2": "Oregon",
        "ca-central-1": "Canada Central",
        "sa-east-1": "Sao Paulo",
        "eu-central-1": "Frankfurt",
        "eu-west-1": "Ireland",
        "eu-west-2": "London",
        "eu-west-3": "Paris",
        "eu-north-1": "Stockholm",
        "me-south-1": "Bahrain",
        "ap-south-1": "Mumbai",
        "ap-northeast-1": "Tokyo",
        "ap-northeast-2": "Seoul",
        "ap-southeast-1": "Singapore",
        "ap-southeast-2": "Sydney",
        "ap-east-1": "Hong Kong",
        "cn-north-1": "Beijing",
        "cn-northwest-1": "Ningxia"
    }
    return region_mapping.get(region_code, region_code)

# Main function to gather data from all instances in all regions
def gather_all_data():
    for region in region_list:
        try:
            instances = subprocess.check_output(["aws", "ec2", "describe-instances", "--region", region, "--output", "json", "--query", "Reservations[*].Instances[*].InstanceId"]).decode("utf-8")
            instances = json.loads(instances)
            for instance_ids in instances:
                for instance_id in instance_ids:
                    add_instance_data(instance_id, region)
        except subprocess.CalledProcessError as e:
            print(f"Failed to get instances in region {region}: {e}")

if __name__ == "__main__":
    # Start gathering data from instances
    gather_all_data()
