alias ls='ls --color=auto'
alias o='grep --color=auto'

if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
export PATH=~/bin:${PATH}
export PS1='\[\033[1;36m\]🐳 \h \[\033[1;34m\]\w\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'
