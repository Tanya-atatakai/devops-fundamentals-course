#!/bin/bash

CLIENT_HOST_DIR=$(pwd)/fe-app
CLIENT_REMOTE_DIR=/var/www/lab2_client

check_remote_dir_exists() {
  echo "Check if remote directories exist"

  if ssh ubuntu-sshuser "[ ! -d $1 ]"; then
    echo "Creating: $1"
	ssh -t ubuntu-sshuser "sudo bash -c 'mkdir -p $1 && chown -R %your_ssh_user_name%: $1'"
  else
    echo "Clearing: $1"
    ssh ubuntu-sshuser "sudo -S rm -r $1/*"
  fi
}

cd $CLIENT_HOST_DIR

# Install and build
sh ../devops-fundamentals-course/lab_1/build-client.sh

# Quality checks
echo "---> Running quality checks - START <---"
sh ../devops-fundamentals-course/lab_3/quality-check-fe.sh
echo "---> Running quality checks - COMPLETE <---"


# Copy files to remote
check_remote_dir_exists $CLIENT_REMOTE_DIR
echo "Transfering client files - START"
scp -Cr $CLIENT_BUILD_DIR/* ubuntu-sshuser:$CLIENT_REMOTE_DIR
echo "Transfering client files - COMPLETE"