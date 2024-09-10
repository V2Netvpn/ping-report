#!/bin/bash

# Variables
TARGET=$1       # Target domain or IP to ping (passed as the first argument)
SERVER_ID=$2    # Server ID passed as the second argument
COUNT=60        # Number of pings (60 pings for 60 seconds)
API_URL="http://v2net.work/v2net/v2/api/report.php"
OUTPUT_FILE="/tmp/ping_output.txt"

# Step 1: Ping the target and check if the output file is created
echo "Pinging $TARGET..."
ping -c $COUNT -i 1 $TARGET > $OUTPUT_FILE

# Check if the ping command ran successfully
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Error: Ping output file not created!"
    exit 1
fi

# Step 2: Extract data from the output file
MIN_PING=$(grep 'min/' $OUTPUT_FILE | awk -F'/' '{print $4}')
AVG_PING=$(grep 'avg/' $OUTPUT_FILE | awk -F'/' '{print $5}')
MAX_PING=$(grep 'max/' $OUTPUT_FILE | awk -F'/' '{print $6}')
ERROR_COUNT=$(grep -c "100% packet loss" $OUTPUT_FILE)

# Step 3: Handle cases where ping data is unavailable
if [[ -z "$MIN_PING" ]]; then
  MIN_PING="null"
fi
if [[ -z "$AVG_PING" ]]; then
  AVG_PING="null"
fi
if [[ -z "$MAX_PING" ]]; then
  MAX_PING="null"
fi

# Debug output to verify variables
echo "Min: $MIN_PING, Avg: $AVG_PING, Max: $MAX_PING, Errors: $ERROR_COUNT"

# Step 4: Send the report to the API
curl -G "$API_URL" \
    --data-urlencode "serverid=$SERVER_ID" \
    --data-urlencode "min=$MIN_PING" \
    --data-urlencode "max=$MAX_PING" \
    --data-urlencode "avg=$AVG_PING" \
    --data-urlencode "error=$ERROR_COUNT"

# Step 5: Clean up
rm $OUTPUT_FILE
