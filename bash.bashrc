alias ls='ls --color=auto'
alias o='grep --color=auto'
alias cdb='cd /ceph/build'
alias cdbd='cd /ceph/build/src/pybind/mgr/dashboard'
alias cdsd='cd /ceph/src/pybind/mgr/dashboard'

if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
export PATH=~/bin:${PATH}
export SOURCE_DATE_EPOCH=0
export PS1='\[\033[1;36m\]🐳 \h \[\033[1;34m\]\w\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'
