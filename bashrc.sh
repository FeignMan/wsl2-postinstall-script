#!/bin/bash
# shellcheck disable=SC1090
declare repoRoot

if [ -d "$HOME/bin" ]; then
  PATH="$PATH:$HOME/bin"
fi

# Set Time
# sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

eval "$(ssh-agent -t 1800 -s)"

# Setup environment variables
repoRoot=$(dirname "${BASH_SOURCE[0]}")             # "${BASH_SOURCE[0]}" refers to the currently executing script even if it's sourced
[ -f "$repoRoot/env.sh" ] && source "$repoRoot/env.sh"
[ -d "${HOME}/.bash_it" ] && source "${repoRoot}/scripts/bash-it/bash-it.rc.sh"

# Load auto-completions for mk
if [ "$(command -v mk)" ]; then                     source <(mk completion bash | sed "s/kubectl/mk/g"); fi

# Show welcome message
if [ -f "${LOCAL_VM_PATH}welcome.txt" ]
then
    if [ -x "$(command -v lolcat)" ]
    then
        lolcat -a -d 2 < "${LOCAL_VM_PATH}welcome.txt"
    else
        echo -e "\033[92m"
        cat "${LOCAL_VM_PATH}welcome.txt"
        echo -e "\033[0m"
    fi
fi
