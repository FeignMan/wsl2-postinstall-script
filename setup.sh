#!/bin/bash

if [ ! -f pre-provision.sh ]; then
    cd $HOME
    echo "ToDo: git clone wsl2-postinstall-setup && cd wsl2-postinstall-setup"
fi
bash pre-provision.sh
