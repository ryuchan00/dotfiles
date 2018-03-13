#!/bin/sh

# ref: https://qiita.com/yudoufu/items/48cb6fb71e5b498b2532
# ghqで制御しているので、このファイルの実行ディレクトリをDOTFILESとする
DOTFILES=$(cd $(dirname $0); pwd)

cd ~/
now=$(date '+%Y%m%d%H%M%S')

if [[ -e .gitconfig ]]; then
  mv .gitconfig .gitconfig_$now
fi

if [[ -e .gitignore_global ]]; then
  mv .gitignore_global .gitignore_global_$now
fi

ln -s $DOTFILES/.gitconfig
ln -s $DOTFILES/.gitignore_global
ln -fs $DOTFILES/.zshrc
ln -fs $DOTFILES/.tmux.conf

function avoid_same_file() {
  if [[ -e $1 ]]; then

