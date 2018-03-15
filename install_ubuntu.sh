#!/bin/bash
# ref: [Ubuntuの/bin/shはbashではなくdash | Siguniang's Blog](https://siguniang.wordpress.com/2013/05/12/dash-is-not-bash/)
# ubuntuでの/bin/shはdashを見ている

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

ln -s $DOTFILES/.gitconfig
ln -s $DOTFILES/.gitignore_global
ln -fs $DOTFILES/.zshrc
ln -fs $DOTFILES/.tmux.conf

