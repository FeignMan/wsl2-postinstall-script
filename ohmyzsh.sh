#!/bin/zsh

THEME="zeta"
CURRENT_DIR=$PWD

function set_theme {
  sed -i.bak -e "s/^ZSH_THEME=[\"']\{0,1\}[A-Za-z0-9\._-]*[\"']\{0,1\}/ZSH_THEME=\"$1\"/1" $HOME/.zshrc
}

echo -e "Installing oh-my-zsh\n"

if [ -d ~/.oh-my-zsh ]; then
    echo -e "oh-my-zsh is already installed\n"
else
    if mv -n ~/.zshrc ~/.zshrc-backup-$(date +"%Y-%m-%d"); then # backup .zshrc
        echo -e "Backed up the current .zshrc to .zshrc-backup-date\n"
    fi
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install custom plugins
echo -e "Installing custom plugins\n"

sudo apt install zoxide

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]; then
    cd ~/.oh-my-zsh/custom/plugins/zsh-completions && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
    cd ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
fi

if [ -d ~/.oh-my-zsh/custom/plugins/k ]; then
    cd ~/.oh-my-zsh/custom/plugins/k && git pull
else
    git clone --depth 1 https://github.com/supercrabtree/k ~/.oh-my-zsh/custom/plugins/k
fi

# activate plugins
sed -i.bak 's/\(^plugins=([^)]*\)/\1 aliases themes git docker nvm colored-man-pages zoxide k zsh-syntax-highlighting zsh-autosuggestions/' $HOME/.zshrc

# Install custom spaceship theme
echo -e "\nInstalling custom themes\n"
# Spaceship
if [ -d ~/.oh-my-zsh/custom/themes/spaceship-prompt ]; then
    cd ~/.oh-my-zsh/custom/themes/spaceship-prompt && git pull
else
    git clone --depth=1 https://github.com/denysdovhan/spaceship-prompt.git ~/.oh-my-zsh/custom/themes/spaceship-prompt
    ln -s ~/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme
fi
cd $CURRENT_DIR

# Zeta
THEME_ZSH_FILE=https://raw.githubusercontent.com/skylerlee/zeta-zsh-theme/master/zeta.zsh-theme
curl -fsSL $THEME_ZSH_FILE > ~/.oh-my-zsh/custom/themes/zeta.zsh-theme

set_theme $THEME