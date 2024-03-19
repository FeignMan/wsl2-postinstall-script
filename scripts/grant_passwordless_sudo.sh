#!/bin/bash

# Check if the script is being run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Check if a username argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

username="$1"

# Add a line to the sudoers file to allow passwordless sudo for the specified user
echo "$username ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

echo -e "\n$(tput setaf 2)Success!$(tput sgr0) Passwordless sudo access has been granted for $(tput setaf 3)$username.$(tput sgr0)"
