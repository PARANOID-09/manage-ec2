#!/bin/bash

# Start the Flask application in the background
echo "Starting Flask application..."
nohup python app.py > flask.log 2>&1 &

# Start the agent script in the background
echo "Starting agent script..."
nohup python agent.py > agent.log 2>&1 &

# Add the agent.py script as a cron job
echo "Adding agent.py as a cron job..."
(crontab -l 2>/dev/null; echo "*/5 * * * * cd $(pwd) && /usr/bin/python agent.py > agent.log 2>&1") | crontab -

echo "Setup complete!"
