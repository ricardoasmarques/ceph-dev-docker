#!/bin/bash

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
# sym link for .zshrc
rm /root/.zshrc
ln -s /shared/zsh/.zshrc /root/.zshrc
# sym link for dash.plugin.zsh
mkdir ~/.oh-my-zsh/custom/plugins/dash
ln -s /shared/zsh/dash.plugin.zsh ~/.oh-my-zsh/custom/plugins/dash/dash.plugin.zsh