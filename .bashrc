# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything.
case $- in
  *i*) ;;
    *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# History length.
HISTSIZE=1000000
HISTFILESIZE=10000

# Add to history instead of overriding it.
shopt | grep -q '^histappend\b' && shopt -s histappend

# Sanity check window size after each command.
shopt | grep -q '^checkwinsize\b' && shopt -s checkwinsize

# Auto cd into directories without needing to type cd before.
# Option only available after bash 4.0.
shopt | grep -q '^autocd\b' && shopt -s autocd

# Use ** in pathname expansions to match all files and zero or more directories
# and subdirectories. On macOS, you may need to switch to Homebrew's bash.
shopt | grep -q '^globstar\b' && shopt -s globstar

# Adds variable to $PATH, canonicalizing simlinks and non-existent directories.
add_to_PATH() {
  for d; do
    d=$({ cd -- "$d" && { pwd -P || pwd; } } 2>/dev/null)
    if [ -z "$d" ]; then continue; fi
    case ":$PATH:" in
      *":$d:"*) : ;;
             *) PATH=$PATH:$d ;;
    esac
  done
}

# Add some common places.
add_to_PATH /opt/bin /usr/local/bin /usr/local/sbin /usr/sbin ~/.local/bin

# User/root variables definition.
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Auto-completion.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Silence the upgrade to zsh message on macOS.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Set color profile.
export TERM=xterm-256color
force_color_prompt=yes

# Colored XTERM promp.
case "$TERM" in
  xterm-color|*-256color) export color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support. Assume it's compliant with Ecma-48 (ISO/IEC-6429).
    # (Lack of such support is extremely rare, and such a case would tend to
    # support setf rather than setaf.)
    export color_prompt=yes
  else
    export color_prompt=
  fi
fi

# Color support using ~/.dircolors.
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && (eval "$(dircolors -b ~/.dircolors)" \
    || eval "$(dircolors -b)")
fi

# Set up powerline-shell (https://github.com/b-ryan/powerline-shell).
if type "powerline-shell" > /dev/null ; then
  _update_ps1() {
    PS1=$(powerline-shell $?)  # Or wherever it's installed.
  }
  if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  fi
fi

# Append to .bash_history after each command, instead of on bash exit.
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

#----------------------------#
#       Useful Aliases       #
#----------------------------#

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Prompt before removing, copying, or moving
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
# if b isn't in /a/, mkdir /a/b/c/ will create /b/ and /c/
alias mkdir="mkdir -p"

# Update system using APT
alias aptup="sudo apt-get update && sudo apt-get upgrade"

# Update official repositories and AUR in Arch Linux
alias pacup="sudo pacman -Syu"
alias aup="yaourt -Syu --aur"

# Editors and configs.
export VISUAL=vim
export EDITOR="$VISUAL"
alias suedit="sudo vim"
alias fstab="sudo vim /etc/fstab"
alias grubcfg="sudo vim /etc/default/grub"

# Fix vim backspace bug in xterm.
stty erase '^?'

# Pretty-print PATH variables.
alias printpath='echo -e ${PATH//:/\\n}'

# 'ls' family
# Add colors for filetype and human-readable sizes by default on 'ls'.
if [ "$(uname)" == "Darwin" ]; then
  # For colors on Mac, must install gls using `brew install coreutils`.
  alias ls='~/homebrew/opt/coreutils/libexec/gnubin/ls -h --color=auto'
else
  alias ls='ls -h --color=auto'
fi

alias lx='ls -lXB'    #  Sort by extension.
alias lk='ls -lSr'    #  Sort by size, biggest last.
alias lt='ls -ltr'    #  Sort by date, most recent last.
alias lc='ls -ltcr'   #  Sort by/show change time,most recent last.
alias lu='ls -ltur'   #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'   #  Pipe through 'more'
alias lr='ll -R'      #  Recursive ls.
alias la='ll -A'      #  Show hidden files.

#----------------------------#
#      Useful Functions      #
#----------------------------#

# ls after a cd.
cd() {
  builtin cd "$*" && ls
}

# Advanced directory creation.
mkcd() {
  if [ -z "$1" ]; then
    echo "Please specify a name for the folder e.g. \"mkcd myfolder\"."
  elif [ -d "$1" ]; then
    echo "\`$1' already exists."
  else
    mkdir "$1" && (cd "$1" || exit)
  fi
}

# Go back many times (e.g. "b 2" is the same as "cd ../..").
b() {
  str=""
  if [ -z "$1" ]; then
    count=1
  else
    count=$1
  fi
  while [ "$count" -gt 0 ];
  do
    str=$str"../"
    count=$((count-1))
  done
  cd $str || exit
}

# Colored man pages.
man() {
  env \
    LESS_TERMCAP_mb="$(printf "\e[1;31m")" \
    LESS_TERMCAP_md="$(printf "\e[1;31m")" \
    LESS_TERMCAP_me="$(printf "\e[0m")" \
    LESS_TERMCAP_se="$(printf "\e[0m")" \
    LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
    LESS_TERMCAP_ue="$(printf "\e[0m")" \
    LESS_TERMCAP_us="$(printf "\e[1;32m")" \
    man "$@"
}

# Extract archives (respective programs must be installed).
extract() {
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)  tar xjf "$1"    ;;
      *.tar.gz)   tar xzf "$1"    ;;
      *.bz2)      bunzip2 "$1"    ;;
      *.rar)      unrar e "$1"    ;;
      *.gz)       gunzip "$1"     ;;
      *.tar)      tar xf "$1"     ;;
      *.tbz2)     tar xjf "$1"    ;;
      *.tgz)      tar xzf "$1"    ;;
      *.zip)      unzip "$1"      ;;
      *.Z)        uncompress "$1" ;;
      *.7z)       7z x "$1"       ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find a file with a pattern in name.
ff() {
  find . -type f -iname '*'"$*"'*' -ls ;
}

# Find a pattern in files and highlight them (needs a recent version of egrep).
fstr() {
  OPTIND=1
  local mycase=""
  local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
  while getopts :it opt
  do
    case "$opt" in
      i) mycase="-i " ;;
      *) echo "$usage"; return ;;
    esac
  done
  shift $((OPTIND-1))
  if [ "$#" -lt 1 ]; then
    echo "$usage"
    return;
  fi
  find . -type f -name "${2:-*}" -print0 | \
    xargs -0 egrep --color=always -sn "${mycase}" "$1" 2>&- | more
}

# Creates an archive (*.tar.gz) from given directory.
maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make your directories and files access rights sane.
sanitize() { chmod -R u=rwX,g=rX,o= "$@" ; }

# Pretty-print of 'df' output. Inspired by 'dfc' utility.
mydf() {
  for fs ; do
    if [ ! -d $fs ]
    then
      echo -e $fs" :No such file or directory" ; continue
    fi
    local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') )
    local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
    local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
    local out="["
    for ((j=0;j<20;j++)); do
      if [ ${j} -lt ${nbstars} ]; then
        out=$out"*"
      else
        out=$out"-"
      fi
    done
    out=${info[2]}" "$out"] ("$free" free on "$fs")"
    echo -e $out
  done
}

# Get IP adress on ethernet.
eth0_ip() {
  MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
    sed -e s/addr://)
  echo ${MY_IP:-"Not connected"}
}

# Get current host related info.
ii() {
  echo -e "\nYou are logged on ${BRed}$HOST"
  echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
  echo -e "\n${BRed}Users logged on:$NC " ; w -hs |
            cut -d " " -f1 | sort | uniq
  echo -e "\n${BRed}Current date :$NC " ; date
  echo -e "\n${BRed}Machine stats :$NC " ; uptime
  echo -e "\n${BRed}Memory stats :$NC " ; free
  echo -e "\n${BRed}Diskspace :$NC " ; mydf / $HOME
  echo -e "\n${BRed}Local IP Address :$NC" ; eth0_ip
  echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
  echo
}

# SSH download.
dl() {
  scp "$1" $USER@[${SSH_CLIENT%% *}]:/home/$USER/Downloads
}

# (Useful for competitive programming)
# Build and run a C++ file, showing execution time and exit code.
# Usage: cpprun srcfile [arg2] ... [arg99] [<file.in] [>file.out]
# Example: cpprun code.cpp <file.in >file.out  (specifying .cpp is optional)
cpprun() {
  basepath="${1%%.*}"  # Strip extension.
  [[ "$1" == "$basepath" ]] && srcpath="$basepath".cpp || srcpath=$1
  # Change the build command and arguments below as you like it it.
  # On Mac, `gcc` is likely just a clang shim and won't have bits/stdc++.h.
  # Install the real GCC with `brew install gcc` and invoke with `g++-12`.
  g++-13 "$srcpath" -o "$basepath" -O3 -std=gnu++17 -Wl,-stack_size -Wl,20000000 -Wall -Wno-variadic-macros
  status=$?
  if [ $status -eq 0 ]; then
    # On Mac, must run `brew install coreutils`
    [[ "$(uname)" == "Darwin" ]] && start=$(gdate +%s.%N) || start=$(date +%s.%N)
    # Check if argument is a path, else run in current directory.
    [[ "$basepath" == *\/* ]] && "$basepath" "${@:2:99}" || ./"$basepath" "${@:2:99}"
    status=$?
    [[ "$(uname)" == "Darwin" ]] && end=$(gdate +%s.%N) || end=$(date +%s.%N)
    runtime=$(python -c "print('{0:.0f}m {1:.3f}s'.format(*divmod(${end}-${start},60)))")
    echo "Finished in $runtime with exit code ${status}." >&2
    return $status
  else
    echo "Build failed" >&2
    return $status
  fi
}
