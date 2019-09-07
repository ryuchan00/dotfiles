set -g -x PATH /usr/local/bin $PATH
#peco
function fish_user_key_bindings
    bind \cr peco_select_history
end

#$XDG_DATA_HOME/fish/fish_history が読まれる
export XDG_DATA_HOME=/home/votoms/Dropbox/
