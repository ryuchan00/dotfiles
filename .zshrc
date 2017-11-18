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

# ctrl + ] でghq管理下のファイルを開く
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
autoload -U vcs_info
setopt prompt_subst

zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:*' formats '[%b]%c%u'
zstyle ':vcs_info:*' actionformats '[%b|%a]%c%u'
zstyle ':vcs_info:git:*' check-for-changes true

function _update_prompt() {
  LANG=en_US.UTF-8 vcs_info
  PROMPT="%{$fg[magenta]%}[%T]%{$reset_color%} %{$fg_bold[blue]%}%~ %{$fg[red]%}($(rbenv version-name)) %{$fg[green]%}${vcs_info_msg_0_}
%{$fg_bold[blue]%}$%{$reset_color%} "
}

add-zsh-hook precmd _update_prompt

eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
