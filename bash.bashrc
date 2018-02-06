alias ls='ls --color=auto'
alias o='grep --color=auto'

if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
export PATH=~/bin:${PATH}
