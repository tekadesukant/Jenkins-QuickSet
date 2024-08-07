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
apt-get install openjdk-8-jdk maven git -y >> $LOG_FILE 2>&1
check_status "Installing Git, Java, and Maven"

# Step 2: Add the Jenkins repository and import the GPG key
log "Adding Jenkins repository and importing GPG key..."
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key >> $LOG_FILE 2>&1
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null >> $LOG_FILE 2>&1
check_status "Adding Jenkins repository and importing GPG key"

# Step 3: Install Java 11 and Jenkins
log "Installing Java 11 and Jenkins..."
apt-get update -y >> $LOG_FILE 2>&1
apt-get install fontconfig openjdk-17-jre -y >> $LOG_FILE 2>&1
apt-get install jenkins -y >> $LOG_FILE 2>&1
check_status "Installing Java 11 and Jenkins"

# Configure default Java version (if needed)
update-alternatives --config java

# Step 4: Start Jenkins and verify the service status
log "Starting Jenkins service..."
systemctl start jenkins.service >> $LOG_FILE 2>&1
check_status "Starting Jenkins service"

log "Jenkins installation completed successfully."

log "Checking Jenkins service status..."
tput setaf 6 ;  systemctl status jenkins.service | grep -i Active ; tput setaf 7

log "jenkins Administrator password"
cat /var/lib/jenkins/secrets/initialAdminPassword
