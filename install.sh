#!/bin/bash

if [ $# != 1 ]; then
    echo 'missing number of arguments.'
    echo 'correct number is 1.'
    exit 1
fi

# ref: https://qiita.com/yudoufu/items/48cb6fb71e5b498b2532
# ghqで制御しているので、このファイルの実行ディレクトリをDOTFILESとする
DOTFILES=$(
    cd $(dirname $0)
    pwd
)

cd ~/
now=$(date '+%Y%m%d%H%M%S')
mkdir dotfile_history

function avoid_same_file() {
    if [[ -e $1 ]]; then
        mv $1 dotfile_history/$1_$now
    fi
}

echo "update .gitconfig?[Y/n]"
read answer
case $answer in
[Yy]*)
    avoid_same_file '.gitconfig'
    ln -fs $DOTFILES/.gitconfig.$1 ./.gitconfig
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac

echo "update .gitconfig_global?[Y/n]"
read answer
case $answer in
[Yy]*)
    avoid_same_file '.gitignore_global'
    ln -fs $DOTFILES/.gitignore_global
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac

echo "update .zshrc?[Y/n]"
read answer
case $answer in
[Yy]*)
    avoid_same_file '.zshrc'
    avoid_same_file '.zshrc.base'
    ln -fs $DOTFILES/.zshrc.base ./.zshrc.base
    ln -fs $DOTFILES/.zshrc.$1 ./.zshrc
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac

echo "update .tmux_conf?[Y/n]"
read answer
case $answer in
[Yy]*)
    avoid_same_file '.tmux.conf'
    ln -fs $DOTFILES/.tmux.conf.$1 ./.tmux.conf
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac

echo "update .vimrc?[Y/n]"
read answer
case $answer in
[Yy]*)
    avoid_same_file '.vimrc'
    ln -fs $DOTFILES/.vimrc
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac
