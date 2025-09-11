alias clock='tty-clock -cs -C4 -D -n -r -b'

alias l='exa'
alias la='exa -a'
alias ll='exa -lh --git'
alias lal='exa -lah --git'
alias ls='exa --color=auto'
alias lg='exa --git'

alias less='moor'

alias krita='bash ~/Scripts/krita.sh'

alias wtfioh='~/Scripts/wtfioh.zsh'
alias wtftree='du -ha | grep -E "^[0-9]+\.?[0-9]?G" | sort -n'

alias logout='loginctl terminate-user $USER'

alias prepare_slideshows='~/Scripts/prepare_sfw_slideshow.zsh;~/Scripts/prepare_home_slideshow.zsh;~/Scripts/prepare_animated_slideshow.zsh'
