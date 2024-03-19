#!/bin/bash
declare localRepoPath="$HOME/wsl2-postinstall-script"

## Second Run
if [ -f "$HOME/.pre-provision-done" ]; then
  rm -f "$HOME/.pre-provision-done"

  if [ -f "$HOME/.bashrc.bak" ]; then
    rm -rf "$HOME/.bashrc"
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
  fi
  
  LOCAL_REPO_PATH=$localRepoPath bash "${localRepoPath}/provision.sh"
  exit $?
fi

echo -e "$(tput setaf 9)Starting pre-provisioning setup...$(tput sgr0)"

declare -a requiredFolders=("$HOME/projects" "$HOME/.ssh" "$HOME/bin" "$HOME/private")
echo -e "\n$(tput setaf 4)Creating folder structure$(tput sgr0)"
for folder in "${requiredFolders[@]}"; do
  if [ ! -d "${folder}" ]; then
    echo -e "$(tput setaf 3)Creating folder: ${folder}$(tput sgr0)"
    mkdir -p "${folder}"
  fi
done

## Copy SSH key from windows
echo -e "\n$(tput setaf 4)Copying SSH Key...$(tput sgr0)"
declare username sshkeyWinPath
cd /mnt/c && username=$(cmd.exe /C echo %USERNAME% | tr -d '\r') && cd "$HOME" || return
sshkeyWinPath="C:\\Users\\${username}\\.ssh\\id_rsa"
cp "$(wslpath -ua "${sshkeyWinPath}")" "$HOME/.ssh/"
chmod 600 "$HOME/.ssh/id_rsa"

echo -e "$(tput setaf 4)Adding SSH Key to ssh-agent...$(tput sgr0)"
eval "$(ssh-agent -t 3600 -s)"
[ -f .ssh/config ] && mv "$HOME/.ssh/config" "$HOME/.ssh/config.bak"
echo -e "AddKeysToAgent yes" >> "$HOME/.ssh/config"
echo -e "\n$(tput setaf 2)SSH setup complete!$(tput sgr0)\n"

# update sudoers file to allow password-less sudo access
echo -e "\n$(tput setaf 4)Grant password-less sudo access...$(tput sgr0)"
sudo bash "$localRepoPath/scripts/grant_passwordless_sudo.sh" "$USER"

## Setup wsl.conf with vm hostname
echo -e "\n$(tput setaf 4)Setting up wsl.conf...$(tput sgr0)\n"
[ -f /etc/wsl.conf ] && sudo rm -f /etc/wsl.conf
sudo tee /etc/wsl.conf >/dev/null <<EOF
[network]
hostname = workstation
generateHosts = false
[boot]
systemd=true
EOF
echo -e "\n$(tput setaf 2)wsl.conf successfully configured!$(tput sgr0)\n"
currentHostname=$(hostname)
sudo sed -i "s/$currentHostname/workstation/g" /etc/hosts

touch $HOME/.pre-provision-done
cp $HOME/.bashrc $HOME/.bashrc.bak
echo -e "\nbash ${localRepoPath}/setup.sh\n\n" >> $HOME/.bashrc

echo -e "\n\033[92mPre-provisioning complete! \033[0m"
echo -e "\n\e[35;104;5mPress any key to shutdown WSL. Start WSL again to continue:\e[0m"
read -rn 1
wsl.exe --terminate "$WSL_DISTRO_NAME"

exit 0
