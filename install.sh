#!/bin/bash

set -exu

if [ $# -ne 1 ]; then
  DOTFILE_DIR=$HOME/.crissed
else
  DOTFILE_DIR="$1"
fi

# create dotfile directory if it does not exist
if ! [ -d "$DOTFILE_DIR" ] ; then
  echo "Creating directory : $DOTFILE_DIR"
  mkdir "$DOTFILE_DIR"
fi

# retrieve the directory where this install script lies
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

pushd "${SCRIPT_DIR}"

# copy everything to this directory
cp .gitconfig "$DOTFILE_DIR"/
cp .gitignore "$DOTFILE_DIR"/
cp .ideavimrc "$DOTFILE_DIR"/
cp .tmux.conf "$DOTFILE_DIR"/
cp -r .vim "$DOTFILE_DIR"/
cp .vimrc "$DOTFILE_DIR"/
cp .ycm_extra_conf.py "$DOTFILE_DIR"/
cp .zshrc "$DOTFILE_DIR"/

popd

# move to dotfile directory
cd "$DOTFILE_DIR"

ZSHRC_PATH=$DOTFILE_DIR/.zshrc

prepend_zshrc() {
  printf '%s\n%s\n' "$1" "$(cat "$ZSHRC_PATH")" > "$ZSHRC_PATH"
}

# download and install zsh
if ! command -v zsh &> /dev/null ; then
  echo "zsh does not exist - installing"

  ZSH_BUILD=$DOTFILE_DIR/zsh_build
  # create build directory
  if ! [ -d "$ZSH_BUILD" ] ; then
    mkdir "$ZSH_BUILD"
  fi

  curl -L https://sourceforge.net/projects/zsh/files/zsh/5.7.1/zsh-5.7.1.tar.xz/download > zsh-5.7.1.tar.xz
  tar -xzvf zsh-5.7.1.tar.xz
  pushd zsh-5.7.1
  ./configure --prefix="$ZSH_BUILD" --exec-prefix="$ZSH_BUILD" --enable-cap --enable-pcre
  make -j5
  make check
  make install
  popd

  prepend_zshrc "export ZSH_BIN=$ZSH_BUILD/bin"
  echo "zsh installed"

  ZSH_PATH=$ZSH_BUILD
else
  ZSH_PATH=$(dirname $(which zsh))
fi

# install oh-my-zsh and follow the steps
git clone https://github.com/robbyrussell/oh-my-zsh.git "$DOTFILE_DIR"/oh-my-zsh
echo "oh-my-zsh installed"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$DOTFILE_DIR/oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
echo "zsh syntax highlighting enabled"

# install vim-plug
DOT_VIM_DIR=$DOTFILE_DIR/.vim
VIM_CONF=$DOTFILE_DIR/.vimrc
curl -fLo "$DOT_VIM_DIR"/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "vim-plug installed"

# install vim plugins
VIM_CONFIG_PATH=$DOTFILE_DIR vim -u "$VIM_CONF" '+PlugInstall --sync' +qall &> /dev/null || true
echo "vim plugins installed"

# install fasd
wget -O fasd-1.0.1.tar.gz -c https://github.com/clvv/fasd/tarball/1.0.1
mkdir fasd
tar -xvf fasd-1.0.1.tar.gz -C fasd --strip-components=1
pushd fasd
PREFIX=./ make install
popd
echo "fasd installed"

# install liquidprompt
# git clone https://github.com/nojhan/liquidprompt.git $DOTFILE_DIR/liquidprompt
# # create config directory if it doesnt exist
# mkdir -p ~/.config
# cp $DOTFILE_DIR/liquidprompt/liquidpromptrc-dist ~/.config/liquidpromptrc
# cp -f "${SCRIPT_DIR}/dansuh_liquidprompt.theme" ~/.config/  # use custom theme
# echo "source ~/.config/dansuh_liquidprompt.theme" >> ~/.config/liquidpromptrc


# check for other different applications
type tmux
if [ $? -ne 0 ] ; then
  echo "tmux doesn't exist - installation preferred"
else
  echo "tmux exists: installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if ! command -v ag &> /dev/null ; then
  echo "ag doesn't exist - installation preferred"
fi

if ! command -v fzf &> /dev/null ; then
  echo "fzf doesn't exist - installation preferred"
fi

# inherit path variables
# prepend_zshrc "[[ \$- = *i* ]] && source $DOTFILE_DIR/liquidprompt/liquidprompt"
prepend_zshrc "export PATH=\$ZSH_BIN:\$FASD_BIN:\$PATH"
prepend_zshrc "export GIT_EDITOR=vim"
prepend_zshrc "export FASD_BIN=$DOTFILE_DIR/fasd/bin"
prepend_zshrc "export VIM_CONFIG_PATH=$DOTFILE_DIR"
prepend_zshrc "export GIT_CONFIG=$DOTFILE_DIR/.gitconfig"
prepend_zshrc "export DOTFILE_ROOT=$DOTFILE_DIR"
prepend_zshrc "export ZSH=$DOTFILE_DIR/oh-my-zsh"
prepend_zshrc "export ZSH_PATH=$ZSH_PATH"
prepend_zshrc "# Generated Environment Variables and PATHs - inherits existing PATH."

# add init function
INIT_FUNCTION="js_init() { ZDOTDIR=$DOTFILE_DIR $ZSH_PATH/zsh ; }"
echo "$INIT_FUNCTION" >> "$HOME/.bashrc"
echo "js_init" >> "$HOME/.bashrc"

echo "Type 'js_init' to initialize with crissed's custom settings!"
source $HOME/.bashrc
