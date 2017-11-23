export ZSH=$HOME/.oh-my-zsh

plugins=(git ruby osx bundler brew rails emoji-clock)

source $ZSH/oh-my-zsh.sh

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

# cdr: 最近移動したディリクトリに移動する
autoload -Uz add-zsh-hook
autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs

# cdrをpecoで開く
function peco-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr
bindkey '^e' peco-cdr

# recent-dirs-max: 履歴として保存するディレクトリ、0か負の値で無制限になる
zstyle ':chpwd:*' recent-dirs-max 200

# recent-dirs-default: trueにすると、cdrコマンドがcdコマンドを兼ねるようになる
zstyle ':chpwd:*' recent-dirs-default true
