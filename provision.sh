#!/bin/bash
set -euo pipefail

# shellcheck source=scripts/shell-utils.sh
source "${LOCAL_REPO_PATH}/scripts/shell-utils.sh"

declare -r NVM_VERSION="v0.39.1" NVM_DIR="${HOME}/bin/nvm"
declare -r DOCKER_VERSION="5:25.0.4-1" DOCKER_COMPOSE_VERSION="v2.24.7"

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_PRIORITY=critical
sudo dpkg-reconfigure debconf --frontend noninteractive

printBanner "        Provisioning Started           " "-"

sudo locale-gen en_US
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure --frontend noninteractive locales
sudo update-locale LANG=en_US.UTF-8

# "-----------------> System Update <------------------"
printBanner "            System Update              " "-"
sudo apt -yqq update && sudo apt -yqq upgrade && echo "Done! ✓"

# "------> Installing Utilities/Dependencies <------"
printBanner "   Installing Utilities/Dependencies   " "-"
sudo apt -yqq install --fix-missing wget git vim python3-pip jq curl snapd tree htop apt-transport-https ca-certificates gnupg-agent software-properties-common libssl-dev unzip figlet lolcat cowsay bat ripgrep
sudo pip3 install --quiet --upgrade pip yq
echo "Done! ✓"

# "--------> Installing GCC/GDB Toolchain <---------"
printBanner "     Installing GCC/GDB Toolchain      " "-"
sudo apt-get -q install -y build-essential gdb && echo "Done! ✓"

# Install CUDA Toolkit 12.3 - https://developer.nvidia.com/cuda-downloads
printBanner "         Install CUDA Toolkit          " "-"
wget -qP "$HOME" https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i "$HOME/cuda-keyring_1.1-1_all.deb" && rm "$HOME/cuda-keyring_1.1-1_all.deb"
sudo apt -yqq update && sudo apt -yqq install cuda-toolkit-12-3 && echo "Done! ✓"

echo
echo "-----------------------------------------------------"
echo "---------------> Installing Docker CE <--------------"
# Workaround to start docker service: revert to iptables-legacy: https://github.com/docker/for-linux/issues/1406
# echo -e "\n\tSelect iptables-legacy below (https://github.com/docker/for-linux/issues/1406):\n"
# sudo update-alternatives --config iptables
# https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -yqq update && \
    sudo apt -yqq install docker-ce="$DOCKER_VERSION~ubuntu.$(lsb_release -rs)~$(lsb_release -cs)" \
    "docker-ce-cli=$DOCKER_VERSION~ubuntu.$(lsb_release -rs)~$(lsb_release -cs)" \
    containerd.io
# enable the docker service at startup (and start right now)
sudo systemctl enable --now docker
sudo systemctl daemon-reload
sudo systemctl restart docker
# systemctl show --property=Environment docker    # show docker environment variables
sudo usermod -aG docker "$USER"                   # add the user to the docker group
echo "Done! ✓"

echo
echo "-------------------------------------------------"
echo "----------> Installing docker-compose <----------"
sudo curl -L --fail "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo /usr/local/bin/docker-compose version
echo "Done! ✓"

# "------------> Installing: kubectl <--------------"
printBanner "          Installing: kubectl          " "-"
curl -sLO https://storage.googleapis.com/kubernetes-release/release/v1.23.9/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl "$HOME/bin/kubectl"
echo "Done! ✓"

# Installing bash-it
printBanner "         Installing: cmd tools         " "-"
git clone https://github.com/Bash-it/bash-it.git ~/.bash_it
"$HOME/.bash_it/install.sh" --no-modify-config

# Installing bash-it plugin requirements
wget -qP "$HOME/bin" https://raw.githubusercontent.com/Lateralus138/todo-bash/master/todo
mv "$HOME/bin/todo" "$HOME/bin/todo.sh"; chmod +x "$HOME/bin/todo.sh"

# Installing fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/bin/.fzf
"$HOME/bin/.fzf/install" --all

# Installing shfmt
sudo snap install shfmt

# Installing gitstatus
git clone --depth=1 https://github.com/romkatv/gitstatus.git ~/bin/gitstatus
echo -e "\nsource ~/bin/gitstatus/gitstatus.prompt.sh" >> ~/.bashrc

# Installing Github-CLI
sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt -qq update \
&& sudo apt install gh -yqq

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit && rm lazygit.tar.gz
sudo install lazygit /usr/local/bin && rm -rf lazygit

printBanner "            Installing: NVM            " "-"
declare NVM_URL
NVM_URL=$(printf "https://raw.githubusercontent.com/nvm-sh/nvm/%s/install.sh" $NVM_VERSION)
curl -o- "$NVM_URL" | NVM_DIR="$NVM_DIR" bash
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install --lts

# "----------> Installing: fx <------------"
printBanner "            Installing: fx             " "-"
curl -L https://github.com/antonmedv/fx/releases/download/24.0.0/fx_linux_amd64 -o "$HOME/fx-linux"
mv "$HOME/fx-linux" "$HOME/bin/fx"
chmod +x "$HOME/bin/fx"
echo "Done! ✓"

# "-----------> Installing kdash & k9s <------------"
printBanner "       Installing: kdash & k9s         " "-"
curl https://raw.githubusercontent.com/kdash-rs/kdash/main/deployment/getLatest.sh | sudo bash
curl -sS https://webinstall.dev/k9s | bash
echo "Done! ✓"

# "------------> Installing: microk8s <--------------"
printBanner "        Installing: microk8s           " "-"
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
# sudo snap set system proxy.http=$http_proxy
# sudo snap set system proxy.https=$https_proxy

sudo snap install microk8s --classic --channel=1.29/stable
echo "Waiting for microk8s to be up and ready"
sudo /snap/bin/microk8s.status --wait-ready
# Give it a couple seconds to settle down
sleep 2

sudo usermod -a -G microk8s "$USER"
# printf "\nhttp_proxy=%s" $http_proxy | sudo tee -a /var/snap/microk8s/current/args/containerd-env > /dev/null
# printf "\nhttps_proxy=%s" $https_proxy | sudo tee -a /var/snap/microk8s/current/args/containerd-env > /dev/null
# printf "\nHTTP_PROXY=%s" $http_proxy | sudo tee -a /var/snap/microk8s/current/args/containerd-env > /dev/null
# printf "\nHTTPS_PROXY=%s\n" $https_proxy | sudo tee -a /var/snap/microk8s/current/args/containerd-env > /dev/null

sudo /snap/bin/microk8s.enable storage rbac
sudo /snap/bin/microk8s.stop
echo "Done! ✓"

# reset DEBIAN_FRONTEND -  defined at the top of this file
unset DEBIAN_FRONTEND DEBCONF_NONINTERACTIVE_SEEN DEBIAN_PRIORITY
sudo dpkg-reconfigure debconf --frontend dialog --priority critical

# source custom bashrc.sh file on login
line="source ${LOCAL_REPO_PATH}/bashrc.sh"
grep -qF -- "$line" "$HOME/.bashrc" || echo -e "\n$line" >> "$HOME/.bashrc"

printBanner "      Setting up Git       " "-"
bash "${LOCAL_REPO_PATH}/scripts/configure-git.sh"

printBanner " VM Provisioning Completed " "*"
echo -e "\e"
echo -e "\n\e[35;104;5mPress any key to shutdown WSL. Start WSL again to continue:\e[0m"
read -rn 1
wsl.exe --terminate "$WSL_DISTRO_NAME"
exit 0

