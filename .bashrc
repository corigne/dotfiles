#
# ~/.bashrc
#

# If not running interactively, don't do anything

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"
. "$HOME/.rokit/env"

ulimit -v 16777216    # Virtual memory limit: 16GB (in KB)
ulimit -m 4194304    # Physical memory limit: 4GB (in KB)
ulimit -u 4096       # Max user processes: 4096
ulimit -n 4096       # Max open file descriptors: 4096
