#!/bin/bash

export SOURCE_FOLDER="${HOME}/projects"
export PRIVATE_FOLDER_PATH="${HOME}/private"
export LOCAL_VM_PATH="${HOME}/wsl2-postinstall-script"
export VM_SCRIPTS_PATH="${LOCAL_VM_PATH}/scripts"

export BASH_IT_THEME="atomic"
export BASH_IT_CUSTOM="${VM_SCRIPTS_PATH}/bash-it"
export EDITOR="code"

export GITHUB_TOKEN_PATH="${PRIVATE_FOLDER_PATH}/github-personalAccessToken"
if [ -f "$GITHUB_TOKEN_PATH" ]; then
    GITHUB_TOKEN=$(cat "${GITHUB_TOKEN_PATH}")
    export GITHUB_TOKEN
fi

# alias gitUpdate='. ${VM_SCRIPTS_PATH}/gitCloneGroup.sh --pull'
# alias gitQuickUpdate='gitUpdate --skip-datascience-repos'
alias gotoRepoRoot='cd $(git rev-parse --show-toplevel)'
alias configureShit='source ${VM_SCRIPTS_PATH}/bash-it/configure.sh'

if [ "$(command -v microk8s)" ]
then
    alias mk='microk8s.kubectl'
    alias watchk='watch -n 1 "microk8s.kubectl get all -A -o wide | grep -v kube-system"'
    alias kwatch='watch "kubectl get all -o wide"'
    alias mkdash='KUBECONFIG=~/microk8s.kubeconfig kdash'
    alias mk9s='k9s --kubeconfig ~/microk8s.kubeconfig'
fi
