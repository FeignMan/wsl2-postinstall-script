#!/bin/bash

aliases=("docker" "docker-compose" "git" "todo.txt-cli")
plugins=("git" "gitstatus" "fzf" "thefuck" "projects" "todo")

if [[ -d "$HOME/.bash_it" && $BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE ]]; then
    unset BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE
    
    shit enable alias "${aliases[@]}"
    echo "$(tput setaf 2)Enabled aliases:$(tput sgr0)docker docker-compose git apt"
    
    shit enable plugin "${plugins[@]}"
    echo "$(tput setaf 2)Enabled plugins:$(tput sgr0)git gitstatus"
    
    read -rsp "Press any key to reload config" -n1
    export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
    shit reload
else
    echo "$(tput setaf 1)"Bash-it must be enabled before running this configuration script!"$(tput sgr0)"
fi
