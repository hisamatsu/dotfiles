case "${UNAME}" in
  MINGW64*)
    alias o='explorer .'
    alias acmd='powershell -command "Start-Process -Verb runas cmd"'
    ;;
  Linux)
    ;;
  Darwin)
    ;;
esac

alias g='git'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias cat='bat -p --paging=never'

#https://gist.github.com/AppleBoiy/04a249b6f64fd0fe1744aff759a0563b
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias l='eza -bGF --header --git --color=always --group-directories-first --icons'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons'
alias la='eza --long --all --group --group-directories-first'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'

alias lS='eza -1 --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'
alias l.="eza -a | grep -E '^\.'"
