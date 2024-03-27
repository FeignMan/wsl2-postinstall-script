#!/bin/bash

# Specify the version of neovim you want to install
NEOVIM_VERSION="0.9.5"

install-nvim() {

    # Download the tar file from the official releases
    wget -q https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux64.tar.gz

    # Extract the tar file directly into the ~/.local/share folder
    mkdir -p ~/.local/share
    tar xzf nvim-linux64.tar.gz -C ~/.local/share && rm nvim-linux64.tar.gz

    # Create a symbolic link to nvim in ~/.local/bin/
    mkdir -p ~/.local/bin
    ln -sf ~/.local/share/nvim-linux64/bin/nvim ~/.local/bin/nvim

    echo -e "$(tput setaf 2)Neovim version ${NEOVIM_VERSION} installed successfully$(tput sgr0)\n"

    # Install lunarvim
    bash "${VM_SCRIPTS_PATH}/neovim/install-lunarvim.sh"
}

uninstall-nvim() {
    # Install lunarvim
    [ -d "$HOME/.local/share/lunarvim" ] && bash "${VM_SCRIPTS_PATH}/neovim/install-lunarvim.sh" --uninstall

    # Remove the symbolic link from ~/.local/bin/
    rm ~/.local/bin/nvim

    # Remove the nvim directory from ~/.local/share
    rm -rf ~/.local/share/nvim-linux64

    # Remove the configuration files
    rm -rf ~/.config/nvim

    echo "$(tput setaf 2)Neovim uninstalled successfully$(tput sgr0)"
}

main() {
    if [ "$1" == "--uninstall" ]; then
        uninstall-nvim
    else
        install-nvim
    fi
}

main "$@"