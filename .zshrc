export UPDATE_ZSH_DAYS=20
DISABLE_AUTO_TITLE="true"

plugins=(git colorize colored-man-pages zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Custom PATH setting
export PATH=$(getconf PATH):$PATH
export PATH=.:$PATH  # add current directory to PATH

# ls aliases
alias l='ls -alh'
alias la='ls -a'
alias ll='ls -al'

# tmux related aliases
# use tmux server with separate socket using separate conf
alias tmux='tmux -L crissed -f $DOTFILE_ROOT/.tmux.conf'
alias tls='tmux ls'
alias ta='tmux attach -t'

# vim
export VIMINIT="source $DOTFILE_ROOT/.vimrc"
alias vim='vim -u $DOTFILE_ROOT/.vimrc'
alias vi='vim'
# alias vim='mvim -v'  # use only after installing macvim

# IMPORT LOCAL ALIASES
if [ -f ~/.bash_aliases ] ; then
  source $HOME/.bash_aliases
fi

# LANGUAGE SETTINGS
export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

### BREW
# export PATH=/usr/local/bin:/opt/local/bin:$PATH  # OSX brew

### FASD -- NEED TO INSTALL BEFORE USE
# eval "$(fasd --init auto)"
# fasd_cache="$HOME/.fasd-init-zsh"
# if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
#   fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
# fi
# source "$fasd_cache"
# unset fasd_cache
# alias v='f -e vim'  # quick open files with vim

### ctags
# generate python tags for site-packages
alias pytags="ctags -R --fields=+l -f ./tags . $(python -c "import os, sys; print(' '.join('{}'.format(d) for d in sys.path if os.path.isdir(d)))")"

# Greet message
echo "Work Harder Bitch"
