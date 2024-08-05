#!/bin/bash

# Define log file for recording actions
LOG_FILE="/var/log/jenkins-install.log"

# Function to log messages
log() {
  local message="$1"
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" | tee -a $LOG_FILE
}

# Function to check command success
check_status() {
  local status="$?"
  local message="$1"
  if [ $status -ne 0 ]; then
    log "Error: $message failed with status $status"
    exit $status
  fi
}

log "Starting Jenkins installation..."

# Step 1: Install Git, Java 1.8.0, and Maven
log "Installing Git, Java 1.8.0, and Maven..."
yum install git java-1.8.0-openjdk maven -y >> $LOG_FILE 2>&1
check_status "Installing Git, Java, and Maven"

# Step 2: Add the Jenkins repository and import the GPG key
log "Adding Jenkins repository and importing GPG key..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo >> $LOG_FILE 2>&1
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key >> $LOG_FILE 2>&1
check_status "Adding Jenkins repository and importing GPG key"

# Step 3: Install Java 11 and Jenkins
log "Installing Java 11 and Jenkins..."
amazon-linux-extras install java-openjdk11 -y >> $LOG_FILE 2>&1
yum install jenkins -y >> $LOG_FILE 2>&1
check_status "Installing Java 11 and Jenkins"

# Configure default Java version (if needed)
update-alternatives --config java

# Step 4: Start Jenkins and verify the service status
log "Starting Jenkins service..."
systemctl start jenkins.service >> $LOG_FILE 2>&1
check_status "Starting Jenkins service"

log "Checking Jenkins service status..."
systemctl status jenkins.service >> $LOG_FILE 2>&1

log "Jenkins installation completed successfully."
