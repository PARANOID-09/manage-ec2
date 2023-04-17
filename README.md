# Manage-ec2

This Python script provides monitoring functionality for EC2 instances running in AWS. The script collects various data points from the EC2 instances and manages it.
## Requirements
Python 3.x
AWS CLI configured with appropriate permissions to access EC2 instances

##Installation

1. Clone this repository to your local machine.

 `git clone https://github.com/yourusername/your-repo.git`
 
2. Install the required Python packages by running `pip install -r requirements.txt`.
3. Configure your AWS CLI with appropriate credentials and permissions to access EC2 instances.

##Usage
1. Run `python app.py & agent.py &` to start the Flask application and the agent script in the background.
2. Run `./run_ec2_monitor.sh` in your terminal to start the EC2 instance monitoring script. The script will start the Flask application and the agent script in the background, and add the agent script as a cron job to run every 5 minutes..
3. The script will gather data from all the EC2 instances running in the AWS regions and display it in the console.
4. You can also access the monitoring information through a web-based interface by navigating to http://localhost:5000 in your web browser.
5. To stop the monitoring script, press Ctrl+C.

###Notes
1. The script uses the AWS CLI to gather data from EC2 instances, so make sure you have the AWS CLI installed and configured with appropriate permissions.
2. The script requires Python 3.x and the Python packages listed in `requirements.txt` to be installed.
3. The script uses Flask to display the monitoring information in a web-based interface, so make sure you have Flask installed if you want to use the web-based interface.
4. The `run.sh script` has been updated to start the Flask application and the agent script in the background, and add the agent script as a cron job with the correct path to the `agent.py` script using pwd which represents the current working directory.

## Contributing
Contributions to this project are welcome! Please see the CONTRIBUTING file for more information.


