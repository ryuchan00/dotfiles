#!/bin/sh

DOTFILES=~/dotfiles

cd ~/

ln -s $DOTFILES/.gitconfig
ln -s $DOTFILES/.gitignore_global
ln -fs $DOTFILES/.zshrc
