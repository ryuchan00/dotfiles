if [[ ! -d $HOME/.zsh/antigen ]]; then
  mkdir $HOME/.zsh
  cd $HOME/.zsh/
  git clone git@github.com:zsh-users/antigen.git
else
  echo "already installed Antigen"
fi
