#!/bin/sh

# ref: https://qiita.com/yudoufu/items/48cb6fb71e5b498b2532
# ghqで制御しているので、このファイルの実行ディレクトリをDOTFILESとする
DOTFILES=$(cd $(dirname $0); pwd)

cd ~/
now=$(date '+%Y%m%d%H%M%S')

function avoid_same_file() {
  if [[ -e $1 ]]; then
    mv $1 $1_$now
  fi
}

avoid_same_file '.gitconfig'
avoid_same_file '.gitignore_global'
avoid_same_file '.zshrc'
avoid_same_file '.tmux.conf'

ln -fs $DOTFILES/.gitconfig_$1 ./.gitconfig
ln -fs $DOTFILES/.gitignore_global
ln -fs $DOTFILES/.zshrc_$1 ./.zshrc
ln -fs $DOTFILES/.tmux.conf
