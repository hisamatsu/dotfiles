# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
umask 022

# User specific environment and startup programs

#-------------------------------------------------------------------------------
# local-specific bashrc
#-------------------------------------------------------------------------------

if [[ -f "${HOME}/.bashrc.prelocal" ]]; then
  . "${HOME}/.bashrc.prelocal"
fi

#-------------------------------------------------------------------------------
# Env. Configuration
#-------------------------------------------------------------------------------

UNAME=${UNAME:-$(uname)}

case "${UNAME}" in
  Linux)
    ;;
  MINGW64*)
    ;;
  Darwin)
   export BASH_SILENCE_DEPRECATION_WARNING=1
    ;;
esac

#if [[ "$(uname -r)" == *microsoft* ]]; then
#  # WSL でやりたい処理
#fi

export PATH
#export LC_ALL=C
#export LANG=C
#export LANG=en_US.UTF-8
export HISTTIMEFORMAT='%F %T '
export HISTSIZE=5000
export HISTFILESIZE=10000
export EDITOR=nvim

#-------------------------------------------------------------------------------
# XDG
#-------------------------------------------------------------------------------
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=$HOME/.local/share


#-------------------------------------------------------------------------------
# go
#-------------------------------------------------------------------------------
export GOPATH=${HOME}/go
export GOBIN=${GOPATH}/bin
PATH=${GOBIN}:${PATH}

#-------------------------------------------------------------------------------
# cargo
#-------------------------------------------------------------------------------
if [[ -f "${HOME}/.cargo/env" ]]; then
  . "${HOME}/.cargo/env"
fi

#-------------------------------------------------------------------------------
# SSH Agent
# + based on https://github.com/mitchellh/dotfiles/blob/master/bashrc#L181-L203
#-------------------------------------------------------------------------------

# if you want to disable this function, you should "ssh_env=/dev/null" in ~/.bashrc.prelocal.
ssh_env=${ssh_env:-${HOME}/.ssh/environment.${HOSTNAME}}

function start_ssh_agent() {
  # remote?
  [[ -z "${SSH_CLIENT}" ]] || return 0

  ssh-agent | sed 's/^echo/#echo/' > "${ssh_env}"
  chmod 0600 "${ssh_env}"
  . "${ssh_env}" > /dev/null

  local ssh_agent_keys=${HOME}/.ssh/agent_keys

  if [[ -f "${ssh_agent_keys}" ]]; then
    local privkey=
    while read privkey; do
      # expand a file path using "~" or "${HOME}"
      eval privkey="${privkey}"
      [[ -f "${privkey}" ]] || continue
      ssh-add "${privkey}"
    done < "${ssh_agent_keys}"
  else
    ssh-add
  fi
}

# Source SSH agent settings if it is already running, otherwise start
# up the agent proprely.

if [[ -f "${ssh_env}" ]]; then
  . "${ssh_env}" > /dev/null
  ps -p "${SSH_AGENT_PID}" > /dev/null || {
    start_ssh_agent
  }
else
  start_ssh_agent
fi

function swap_ssh_agent_sock() {
  # static ssh agent sock path
  local ssh_agent_sock=${HOME}/.ssh/agent.sock.${HOSTNAME}
  # ignore?
  [[ "${ssh_env}" == "/dev/null" ]] && return 0

  # based on http://www.gcd.org/blog/2006/09/100/
  if ! [[ -L "${SSH_AUTH_SOCK}" ]] && [[ -S "${SSH_AUTH_SOCK}" ]]; then
    ln -fs "${SSH_AUTH_SOCK}" "${ssh_agent_sock}"
    export SSH_AUTH_SOCK="${ssh_agent_sock}"
  fi
}
swap_ssh_agent_sock

#-------------------------------------------------------------------------------
# bash_it
#-------------------------------------------------------------------------------
# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# Path to the bash it configuration
export BASH_IT="${HOME}/.bash_it"

# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location /.bash_it/themes/
# if [[ ${UNAME} == Darwin ]]; then
#   export BASH_IT_THEME='agnoster'
# else
#   export BASH_IT_THEME='oh-my-posh'
# fi
export BASH_IT_THEME=""

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
#THEME_CHECK_SUDO='true'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# (Advanced): Change this to the name of the main development branch if
# you renamed it or if it was changed for some reason
# export BASH_IT_DEVELOPMENT_BRANCH='master'

# Your place for hosting Git repos. I use this for private repos.
# export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
#export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
#export TODO="t"

# Set this to the location of your work or project folders
#BASH_IT_PROJECT_PATHS="${HOME}/Projects:/Volumes/work/src"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=false
# Set to actual location of gitstatus directory if installed
#export SCM_GIT_GITSTATUS_DIR="$HOME/gitstatus"
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
#export GITSTATUS_NUM_THREADS=8

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
export SHORT_HOSTNAME=$(hostname -s)

# Set Xterm/screen/Tmux title with only a short username.
# Uncomment this (or set SHORT_USER to something else),
# Will otherwise fall back on $USER.
#export SHORT_USER=${USER:0:8}

# If your theme use command duration, uncomment this to
# enable display of last command duration.
export BASH_IT_COMMAND_DURATION=false
# You can choose the minimum time in seconds before
# command duration is displayed.
#export COMMAND_DURATION_MIN_SECONDS=1

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#export SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
# export BASH_IT_RELOAD_LEGACY=1

# Load Bash It
source "$BASH_IT"/bash_it.sh

#-------------------------------------------------------------------------------
# tmux
#-------------------------------------------------------------------------------
if which tmux >/dev/null 2>&1; then
    #if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi

#-------------------------------------------------------------------------------
# fzf
#-------------------------------------------------------------------------------
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash
fi

if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash.local ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash.local
fi

#-------------------------------------------------------------------------------
# starship
#-------------------------------------------------------------------------------
eval "$(starship init bash)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export STARSHIP_CACHE=~/.cache/starship

#-------------------------------------------------------------------------------
# zoxide
#-------------------------------------------------------------------------------
eval "$(zoxide init bash)"

#-------------------------------------------------------------------------------
# gh completion
#-------------------------------------------------------------------------------
eval "$(gh completion -s bash)"

#-------------------------------------------------------------------------------
# Aliases
#-------------------------------------------------------------------------------
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
