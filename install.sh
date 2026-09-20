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

echo "update nvim config?[Y/n]"
read answer
case $answer in
[Yy]*)
    if [[ -d ~/.config/nvim && ! -L ~/.config/nvim ]]; then
        mv ~/.config/nvim dotfile_history/nvim_$now
    fi
    mkdir -p ~/.config
    ln -fns $DOTFILES/nvim ~/.config/nvim
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac

echo "update tmux config?[Y/n]"
read answer
case $answer in
[Yy]*)
    if [[ -d ~/.config/tmux && ! -L ~/.config/tmux ]]; then
        mv ~/.config/tmux dotfile_history/tmux_$now
    fi
    mkdir -p ~/.config
    ln -fns $DOTFILES/tmux ~/.config/tmux
    ;;
n) ;;

*)
    echo -e "cannot understand $answer."
    ;;
esac

# WSL のときだけ: Windows 側の PowerShell プロファイルをスタブに差し替える。
# /mnt/c 上に張った symlink は Windows から辿れないので、symlink ではなく
# 「dotfiles の実体を \\wsl.localhost 経由で読み込むスタブ」を書き込む
if [[ -n $WSL_DISTRO_NAME ]]; then
    echo "update PowerShell profile (Windows)?[Y/n]"
    read answer
    case $answer in
    [Yy]*)
        win_home=$(wslpath -u "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
        ps_dir="$win_home/Documents/WindowsPowerShell"
        ps_profile="$ps_dir/Microsoft.PowerShell_profile.ps1"
        unc="\\\\wsl.localhost\\$WSL_DISTRO_NAME${DOTFILES//\//\\}\\PowerShell\\profile.ps1"

        mkdir -p "$ps_dir"
        if [[ -e $ps_profile ]]; then
            cp "$ps_profile" "$ps_dir/Microsoft.PowerShell_profile.ps1.bak-$now"
        fi

        # PS 5.1 は BOM が無いと日本語を CP932 として読むので UTF-8 BOM 付きで書く
        printf '\xef\xbb\xbf' >"$ps_profile"
        cat >>"$ps_profile" <<PSEOF
# =============================================================
#  PowerShell プロファイル (スタブ)
#
#  中身は dotfiles リポジトリで管理している。このファイルは
#  WSL 側の実体を読み込むだけなので、編集しないこと。
#
#    実体   : ~/dotfiles/PowerShell/profile.ps1  (WSL: $WSL_DISTRO_NAME)
#    再生成 : WSL 側で ~/dotfiles/install.sh ubuntu
# =============================================================

\$DotfilesProfile = '$unc'

# UNC パス (\\\\wsl.localhost\\...) 上のスクリプトは「リモート」扱いになるため、
# ExecutionPolicy が RemoteSigned だと dot-source が弾かれる。
# 内容を読んで ScriptBlock として実行することで、ポリシーを変更せずに読み込む。
# 実行ポリシーを緩めるのはこのファイル 1 本に限定される
try {
    if (Test-Path -LiteralPath \$DotfilesProfile) {
        \$src = Get-Content -LiteralPath \$DotfilesProfile -Raw -Encoding UTF8
        . ([scriptblock]::Create(\$src.TrimStart([char]0xFEFF)))
    } else {
        Write-Verbose "dotfiles プロファイルが見つかりません: \$DotfilesProfile"
    }
} catch {
    # WSL 停止中 / ディストリ名変更など。PowerShell 自体は普通に使えるようにしておく
    Write-Warning "dotfiles プロファイルの読み込みに失敗しました: \$(\$_.Exception.Message)"
}
PSEOF
        echo "  -> $ps_profile"
        ;;
    n) ;;

    *)
        echo -e "cannot understand $answer."
        ;;
    esac
fi
