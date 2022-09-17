#!/bin/bash

NVM_VERSION=v0.39.1
NODE_VERSION=16.17.0
NVM_DIR=/usr/local/nvm

# Called by the setup script?
if [ -f $HOME/.pre-provision-done ]; then
    rm -f $HOME/.pre-provision-done
    rm -f $HOME/.bashrc
    mv $HOME/.bashrc.bak $HOME/.bashrc
fi

echo
echo "-------------------------------------------------"
echo "------> Installing Utilities/Dependencies <------"
sudo apt-get -q install -y --fix-missing wget git vim python3-pip jq curl snapd tree htop apt-transport-https ca-certificates gnupg-agent software-properties-common libssl-dev unzip figlet lolcat bat
sudo pip3 install --upgrade pip yq
echo "Done! ✓"

echo
echo "-----------------------------------------------------"
echo "---------------> Installing Docker CE <--------------"
# Workaround to start docker service: revert to iptables-legacy: https://github.com/docker/for-linux/issues/1406
echo -e "\n\tSelect iptables-legacy below (https://github.com/docker/for-linux/issues/1406):\n"
sudo update-alternatives --config iptables
# https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -q update
sudo apt-get -q install -y docker-ce=5:20.10.17~3-0~ubuntu-$(lsb_release -cs) docker-ce-cli=5:20.10.17~3-0~ubuntu-$(lsb_release -cs) containerd.io
# enable the docker service at startup (and start right now)
sudo systemctl enable --now docker
sudo systemctl daemon-reload
sudo systemctl restart docker
systemctl show --property=Environment docker    # show docker environment variables
sudo usermod -aG docker $USER                   # add the user to the docker group
echo "Done! ✓"

echo
echo "-------------------------------------------------"
echo "----------> Installing docker-compose <----------"
sudo curl -L --fail https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo /usr/local/bin/docker-compose version
echo "Done! ✓"

echo
echo "-------------------------------------------------"
echo "---------------> Installing ZSH <----------------"
sudo apt install -yq zsh
sudo chsh -s /usr/bin/zsh $USER   # set as default shell
if [ -d ~/.oh-my-zsh ]; then
    echo -e "oh-my-zsh is already installed\n"
else
    zsh ohmyzsh.sh
fi

echo
echo "-------------------------------------------------"
echo "---------------> Installing FZF <----------------"
if [ -d ~/bin/fzf ]; then
    cd ~/bin/fzf && git pull
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/bin/fzf
fi
~/bin/fzf/install --all

echo
echo "-------------------------------------------------"
echo "---------------> Installing NVM <----------------"
URL=$(printf "https://raw.githubusercontent.com/nvm-sh/nvm/%s/install.sh" $NVM_VERSION)
curl -o- $URL | bash

echo -e "\n\033[92mProvisioning complete! \033[0m"
echo -e "Press any key to shutdown..."
read choice
cmd.exe /C wsl --shutdown