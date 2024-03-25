#!/bin/bash
declare localRepoPath="$HOME/wsl2-postinstall-script"
declare -a requiredFolders=("$HOME/projects" "$HOME/.ssh" "$HOME/bin" "$HOME/private")

## Second Run
function executeProvisioning {
  rm -f "$HOME/.ready-for-provisioning"

  if [ -f "$HOME/.bashrc.bak" ]; then
    rm -rf "$HOME/.bashrc"
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
  fi

  LOCAL_REPO_PATH=$localRepoPath bash "${localRepoPath}/provision.sh"
  return $?
}

function createFolderStructure {
  echo -e "\n$(tput setaf 4)Creating folder structure$(tput sgr0)"
  for folder in "${requiredFolders[@]}"; do
    if [ ! -d "${folder}" ]; then
      echo -e "$(tput setaf 3)Creating folder: ${folder}$(tput sgr0)"
      mkdir -p "${folder}"
    fi
  done
}

function configureSshKey {
  echo -e "\n$(tput setaf 4)Copying SSH Key...$(tput sgr0)"

  local username sshkeyWinPath
  cd /mnt/c && username=$(cmd.exe /C echo %USERNAME% | tr -d '\r') && cd "$HOME" || return
  sshkeyWinPath="C:\\Users\\${username}\\.ssh\\id_rsa"
  if ! cp "$(wslpath -ua "${sshkeyWinPath}")" "$HOME/.ssh/"; then
    echo -e "\n$(tput setaf 1)[Error] Failed to copy SSH key from host machine!$(tput sgr0)\n"
    return 1
  fi

  echo -e "\n$(tput setaf 10)Copied SSH key to $HOME/.ssh/id_rsa from host machine!$(tput sgr0)\n"
  chmod 600 "$HOME/.ssh/id_rsa"

  echo -e "$(tput setaf 4)Adding SSH Key to ssh-agent...$(tput sgr0)"
  eval "$(ssh-agent -t 3600 -s)"
  echo -e "AddKeysToAgent yes" >>"$HOME/.ssh/config"

  echo -e "\n$(tput setaf 2)SSH setup complete!$(tput sgr0)\n"
}

function configureNoPasswdSudo {
  echo -e "\n$(tput setaf 4)Grant password-less sudo access...$(tput sgr0)"
  sudo bash "$localRepoPath/scripts/grant_passwordless_sudo.sh" "$USER"
}

## Setup wsl.conf with vm hostname
function setupWslDotConf {
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

  # Update hostname
  currentHostname=$(hostname)
  sudo sed -i "s/$currentHostname/workstation/g" /etc/hosts
}

function setupProvisioningOnNextLogin {
  touch "$HOME"/.ready-for-provisioning
  cp "$HOME"/.bashrc "$HOME"/.bashrc.bak
  echo -e "\nbash ${localRepoPath}/setup.sh\n\n" >>"$HOME"/.bashrc
}

function main {

  if [ -f "$HOME/.ready-for-provisioning" ]; then
    executeProvisioning
    exit $?
  fi

  echo -e "$(tput setaf 9)Starting pre-provisioning setup...$(tput sgr0)"

  createFolderStructure
  configureSshKey
  configureNoPasswdSudo
  setupWslDotConf

  # Mute startup message
  touch "$HOME/.hushlogin"

  setupProvisioningOnNextLogin

  echo -e "\n$(tput setaf 10)Pre-provisioning complete! $(tput sgr0)"
  echo -e "\n\e[35;104;5mPress any key to shutdown WSL. Start WSL again to begin provisioning:\e[0m"
  read -rn 1
  wsl.exe --terminate "$WSL_DISTRO_NAME"
}

main "$@"
