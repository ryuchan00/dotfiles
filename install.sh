#!/bin/sh

DOTFILES=$(cd $(dirname $0); pwd)

cd ~/

ln -s $DOTFILES/.gitconfig
ln -s $DOTFILES/.gitignore_global
ln -fs $DOTFILES/.zshrc
ln -fs $DOTFILES/.tmux.conf
