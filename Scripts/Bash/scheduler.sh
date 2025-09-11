#!/bin/bash

#Assigning the project root to a variable
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Passing the Path directory for the ETL script to be scheduled , and the log file to a Variable
ETL_SCRIPT="$PROJECT_DIR/Scripts/Bash/etl.sh"
LOG_FILE="$PROJECT_DIR/etl_job.log"

#Giving the execution permission
echo "----- Making ETL script executable -----"
chmod +x $ETL_SCRIPT

# Create a cron job entry that runs every day at 12:00 AM
#  The CRON_JOB uses the Format: minute hour day month weekday command
CRON_JOB="0 0 * * * $ETL_SCRIPT >> $LOG_FILE 2>&1"   # 0 0 * * * means: at 00:00 (midnight) every day # 2>&1 means redirect errors into standard output, so both normal messages and errors go into the same log file.

# Install the cron job if not already present
echo "----- Adding cron job -----"
# Get current crontab, add job if it doesn't exist, remove old job if it exists, and reload
(crontab -l | grep -v "$ETL_SCRIPT"; echo "$CRON_JOB") | crontab -

# Confirm cron job was added
echo "----- Current crontab -----"
crontab -l
