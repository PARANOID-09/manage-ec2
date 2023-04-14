# manage-ec2

This project contains a script agent.sh, a configuration file config.sh, a Python script app.py, and a directory dir with an index.html file.

## Description

The agent.sh script is a Bash script that runs as an agent on a local system. It collects data from the current EC2 instance and sends it to a control panel using a POST request. It also uses AWS SSM Run Command to ping other discovered instances for connectivity checks.

The config.sh file is a configuration file that stores variables used by the agent.sh script, such as the control panel URL, heartbeat interval, and AWS region.

The app.py script is a Python script that serves as a Flask application. It provides a web page with an index.html template and has an endpoint /receive_data for receiving data via a POST request. The received data is appended to a list instances.

The dir directory contains an index.html file, which can be used for serving a web page or any other purpose related to the project.

## Usage

1. Make sure that the necessary dependencies and permissions are set up for running the agent.sh script.
2. Update the variables in the config.sh file to configure the agent behavior.
3. Run the agent.sh script on the local system using a Bash interpreter.
4. The agent.sh script will run in the background, collecting data from the current EC2 instance and sending it to the control panel.
5. The app.py script can be executed separately using a Python interpreter or by running python app.py in the command line. It will start the Flask application and serve the index.html file on the default port 5000.
6. Access the web page served by the Flask application in a web browser by navigating to http://localhost:5000/. The web page will display the data collected by the agent.sh script in the instances list.
7. The index.html file in the dir directory can be used for serving a web page or any other purpose as needed.

## Contributing
Contributions to this project are welcome! Please see the CONTRIBUTING file for more information.
