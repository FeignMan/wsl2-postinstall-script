#!/bin/bash
LVIM_VERSION="release-1.3/neovim-0.9"

checkDependencies() {
    local missingDependencies=0
    # check if git, make, pip, python, npm, node, cargo and ripgrep are installed
    declare -a requiredPackages=("git" "make" "pip" "python3" "npm" "node" "cargo" "rgrep")
    for package in "${requiredPackages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            echo "$(tput setaf 1)[Error] Missing Dependency: $package is not installed. Please install it before installing LunarVim$(tput sgr0)"
            missingDependencies=1
        fi
    done

    return "$missingDependencies"
}

# Function to install LunarVim
install_lunarvim() {
    echo -e "$(tput setaf 2)Installing LunarVim...$(tput sgr0)"
    
    if ! checkDependencies; then exit 1; fi

    # install LunarVim
    LV_BRANCH="$LVIM_VERSION" bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) --yes
}

# Function to uninstall LunarVim
uninstall_lunarvim() {
    echo "$(tput setaf 2)Uninstalling LunarVim...$(tput sgr0)"
    
    if [ -d "$HOME/.local/share/lunarvim" ]; then
        bash ~/.local/share/lunarvim/lvim/utils/installer/uninstall.sh --remove-config --remove-backups
    fi
}

# Check if the script is run with the '--uninstalled' argument
if [[ "$1" == "--uninstall" ]]; then
    uninstall_lunarvim
else
    install_lunarvim
fi