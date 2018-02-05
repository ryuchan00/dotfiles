export ZSH=$HOME/.oh-my-zsh

plugins=(git ruby osx bundler brew rails emoji-clock zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

if [[ -f $HOME/.zsh/antigen/antigen.zsh ]]; then
  source $HOME/.zsh/antigen/antigen.zsh
  antigen bundle mollifier/anyframe
  antigen apply
fi

# tmuxをターミナル起動時に開く
if [ $SHLVL = 1 ]; then
  tmux
fi

# キーのリピート入力認識までの時間とキーリピート時間の確認
# ref:https://dev.classmethod.jp/tool/mac-keyboard-speed-2/

# History
# ref:https://github.com/june29/dotfiles/blob/master/.zshrc#L83-L84
HISTFILE=$HOME/Dropbox/dotfiles/.zsh_history
HISTSIZE=530000
SAVEHIST=530000


function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# search zsh man
# usage ---
# % zman SHARE_HISTORY
function zman() {
    PAGER="less -g -s '+/^ {7}"$1"'" man zshall
}

# ctrl + \ でghq管理下のファイルを開く
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^\' peco-src

# ctrl + ^ でghq管理下のファイルをatomで開く
function peco-atom () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="atom ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-atom
bindkey '^^' peco-atom

# Prompt
# ref:https://github.com/kenchan/dotfiles/blob/master/dot.zshrc#L9-L18
autoload -U colors && colors
autoload -U add-zsh-hook
# vcsinfo: gitやCVSなどのいわゆるバージョン管理システムから情報を取得してくれる便利な関数。
autoload -U vcs_info
setopt prompt_subst  #プロンプト表示する度に変数を展開

# どのバージョン管理システムを使うか宣言する(hg: Mervurial(マーキュリアル))
zstyle ':vcs_info:*' enable git hg svn

# $vcs_info_msg_0_で表示する内容をここに指定します。
zstyle ':vcs_info:*' formats '[%b]%c%u'

# mergeでコンフリクトが起きたり、何かしら特殊な状況になった場合に formatsの代わりに actionformatsで指定した文字列が$vcs_info_msg_0_に格納される。
zstyle ':vcs_info:*' actionformats '[%b|%a]%c%u'

# trueにすると formatsという項目で%cと%uというフォーマットが使えるようになる。これは、リポジトリにコミットされていないファイルがあった場合に%cまたは%uに文字列が格納される。
zstyle ':vcs_info:git:*' check-for-changes true

function _update_prompt() {
  LANG=en_US.UTF-8 vcs_info
  PROMPT="%{$fg[magenta]%}[%T]%{$reset_color%} %{$fg_bold[blue]%}%d %{$fg[red]%}($(rbenv version-name)) %{$fg[green]%}${vcs_info_msg_0_}
%{$fg_bold[blue]%}$%{$reset_color%} "
}

add-zsh-hook precmd _update_prompt

eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/bin:$PATH"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# web db press vol83
alias g='git'
alias ls='ls -F'
alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias va='vagrant'
alias be='bundle exec'

# cdr: 最近移動したディリクトリに移動する
autoload -Uz add-zsh-hook
autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs

# cdrをpecoで開く
# ref: http://wada811.blogspot.com/2014/09/zsh-cdr.html
function peco-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr
bindkey '^l' peco-cdr

# recent-dirs-max: 履歴として保存するディレクトリ、0か負の値で無制限になる
zstyle ':chpwd:*' recent-dirs-max 200

# recent-dirs-default: trueにすると、cdrコマンドがcdコマンドを兼ねるようになる
zstyle ':chpwd:*' recent-dirs-default true

# zsh-completions: 補完を強化する
fpath=(/usr/local/share/zsh-completions(N-/) $fpath)

# 大文字小文字を区別をしない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# zmv: 複数のファイルを一括でリネームする
autoload -Uz zmv

# anyframeを使ってプロセスを停止する
function peco-kill() {
  ps -u $USER -o pid,stat,%cpu,%mem,cputime,command \
  | anyframe-selector-auto \
  | awk '{print $1}' \
  | anyframe-action-execute kill
}
zle -N peco-kill
bindkey '^k' peco-kill

# Gitのブランチを切り替える
bindkey '^_' anyframe-widget-checkout-git-branch
bindkey '^]' anyframe-widget-insert-git-branch

# tmuxとAnythingインターフェースを使ってウィンドウを切り替える
function peco-tmux() {
  local i=$(tmux lsw | awk '/active.$/ {print NR-1}')
  local f='#{window_index}: #{window_name}#{window_flags} #{pane_current_path}'
  tmux lsw -F "$f" \
    | anyframe-selector-auto "" --initial-index $i \
    | cut -d ':' -f 1 \
    | anyframe-action-execute tmux select-window -t
}
zle -N peco-tmux
bindkey '^xw' peco-tmux

bindkey '⌥f' forward-word
bindkey '⌥b' backward-word

export PATH=$HOME/.nodebrew/current/bin:$PATH

# brew install phpが必要
export PATH="$(brew --prefix homebrew/php/php72)/bin:$PATH"

# ref: https://ja.stackoverflow.com/questions/21718/touch%E3%81%A7mkdir-p%E3%82%82%E8%A1%8C%E3%81%84%E3%81%9F%E3%81%84
dirtouch() {
      mkdir -p "$(dirname $1)"
          touch "$1"
}
alias touch=dirtouch
export PATH="/usr/local/sbin:$PATH"
