#!/bin/bash
# set -euo pipefail

function ensureGithubToken {
    # GITHUB_TOKEN_PATH is not defined - fail
    [ -z "$GITHUB_TOKEN_PATH" ] && {
        echo "$(tput setaf 1)[Error] Environment variable GITHUB_TOKEN_PATH not defined!$(tput sgr0)"
        return 1
    }

    # Token file already exists
    [ -f "$GITHUB_TOKEN_PATH" ] && return 0

    echo -e "$(tput setaf 1)Could not find a Personal Access Token for Github!\n \
    $(tput setaf 3)Paste a Perrsonal Access Token for your Github account below\n \
    (Minimum required scopes - 'repo', 'read:org'):$(tput sgr0)"
    
    REPLY=""
    while [[ -z $REPLY ]]; do
        read -r
    done
    
    if echo "$REPLY" > "$GITHUB_TOKEN_PATH"; then
        return 0
    else
        return 1
    fi
}

function ensureGithubLogin () {
    # check if we are logged in
    [[ $(gh auth status 2>/dev/null) ]] && return 0

    # Github-CLI not logged in: 
    echo "$(tput setaf 3)"[Info] Github-CLI not logged in"$(tput sgr0)"
    if ! ensureGithubToken; then return 1; fi

    # login using personal access token
    if gh auth login -h github.com -p ssh --with-token < "$GITHUB_TOKEN_PATH"; then
        echo "$(tput setaf 2)Github-CLI successully logged in to github.com$(tput sgr0)"
        return 0
    else
        echo "$(tput setaf 1)[Error] Github-CLI failed to login to github.com$(tput sgr0)"
        return 1
    fi
}

function setupGitGlobalConfig {
    if ! gh auth setup-git; then
        echo "$(tput setaf 1)[Error] Failed to set github-cli as credential manager$(tput sgr0)"
        return 1
    fi

    local -r name="$(gh api user -q '.name')"
    local -r email="$(gh api user -q '.email')"

    echo "$(tput setaf 2)[config] Setting user identity: $(tput setaf 2)$name <$email>$(tput sgr0)"
    git config --global user.name "$name"
    git config --global user.email "$email"

    git config --global submodule.recurse true

    # Setup p4merge as diff/merge tool
    # shellcheck disable=SC2016
    git config --global difftool.p4merge.cmd "p4merge.exe \"\$(wslpath -aw \$LOCAL)\" \"\$(wslpath -aw \$REMOTE)\""
    git config --global diff.tool p4merge
    git config --global difftool.prompt false
    git config --global merge.tool p4merge
    git config --global merge.p4merge.cmd "p4merge.exe \"\$(wslpath -aw \$BASE)\" \"\$(wslpath -aw \$LOCAL)\" \"\$(wslpath -aw \$REMOTE)\" \"\$(wslpath -aw \$MERGED)\""
    git config --global mergetool.p4merge.trustExitCode false

    return 0
}

main() {
    if ! ensureGithubLogin; then return 1; fi
    if ! setupGitGlobalConfig; then return 1; fi
    return 0
}

if main; then
    exit 0
else
    exit 1
fi