#!/bin/bash

echo -e "Running Pre-Provision Setup... \n"
echo "----------------------------------------------------"
echo "-----------------> System Update <------------------"
sudo apt-get -q update && sudo apt-get -yq upgrade && echo "Done! ✓"

## Create structure of folders
mkdir -p $HOME/projects
mkdir -p $HOME/.ssh

## Copy SSH key from windows
username=$(cmd.exe /C echo %USERNAME% | tr -d '\r')
cp /mnt/c/Users/$username/.ssh/id_rsa $HOME/.ssh/
chmod 600 $HOME/.ssh/id_rsa

# Install/Enable systemd using wsl-distrod
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod +x install.sh
sudo ./install.sh install && echo -e $(pwd)"/pre-provision.sh" >> $HOME/.pre-provision-done
rm -f install.sh

if [ -f $HOME/.pre-provision-done ]; then
    cp $HOME/.bashrc $HOME/.bashrc.bak
    echo -e "\ncd\nif [ -f ~/.pre-provision-done ]; then\n. $(pwd)/provision.sh\nexit 0\nfi\n" >> $HOME/.bashrc
else
    exit -1
fi

echo -e "\n\033[92mPre-provisioning complete! \033[0m"
echo -e "Press any key to shutdown..."
read choice
cmd.exe /C wsl --shutdown
