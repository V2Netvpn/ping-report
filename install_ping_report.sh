#!/bin/bash

# Variables
GITHUB_REPO_URL="https://github.com/yourusername/V2Netvpn.git"  # Replace with your GitHub URL
CLONE_DIR="/home/ubuntu/V2Netvpn"
SCRIPT_PATH="$CLONE_DIR/ping_report.sh"
TARGET="172.16.1.2"  # Domain or IP to ping

# Step 1: Ask the user for the server ID
read -p "Please enter your server ID: " SERVER_ID

# Step 2: Clone the GitHub repository
if [ -d "$CLONE_DIR" ]; then
    echo "Repository already exists. Pulling latest changes..."
    cd $CLONE_DIR
    git pull
else
    echo "Cloning repository..."
    git clone $GITHUB_REPO_URL $CLONE_DIR
fi

# Step 3: Make the script executable
chmod +x $SCRIPT_PATH

# Step 4: Set up a cron job to run the script every minute
CRON_JOB="* * * * * $SCRIPT_PATH $TARGET $SERVER_ID >> /home/ubuntu/ping_report.log 2>&1"

# Check if the cron job already exists, if not, add it
(crontab -l | grep -F "$SCRIPT_PATH") || (crontab -l; echo "$CRON_JOB") | crontab -

echo "Cron job set up to run every minute."

# Step 5: Run the script in the background for the first time
nohup $SCRIPT_PATH $TARGET $SERVER_ID >> /home/ubuntu/ping_report.log 2>&1 &

echo "Ping report script is now running."
