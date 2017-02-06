# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Add to history instead of overriding it
shopt -s histappend

# History length
HISTSIZE=1000
HISTFILESIZE=2000

# Window size sanity check
shopt -s checkwinsize

# User/root variables definition
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Colored XTERM promp
case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

# Colored prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
  else
    color_prompt=
  fi
fi

# Pretty prompt (Recommended font: Ohsnap)
export PS1="\[$(tput setaf 1)\]┌─╼ \[$(tput setaf 3)\][\u@\h] \[$(tput setaf 6)\]\w\n\[$(tput setaf 1)\]\$(if [[ \$? == 0 ]]; then echo \"\[$(tput setaf 1)\]└────╼\"; else echo \"\[$(tput setaf 1)\]└╼\"; fi) \[$(tput setaf 7)\]"

# trap 'echo -ne "\e[0m"' DEBUG

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Auto-completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Color support using ~/.dircolors
# if [ -x /usr/bin/dircolors ]; then
#   test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
# fi

# Alias definitions, if you choose to define it separately
# if [ -f ~/.bash_aliases ]; then
#     . ~/.bash_aliases
# fi

# Otherwise...


#----------------------------#
#       Useful Aliases       #
#----------------------------#

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

# Editors and configs:
export VISUAL=vim
export EDITOR="$VISUAL"
alias suedit="sudo $EDITOR"
alias fstab="sudo vim /etc/fstab"
alias grubcfg="sudo vim /etc/default/grub"

# Fix vim backspace bug in xterm.
stty erase '^?'

# Pretty-print PATH variables:
alias printpath='echo -e ${PATH//:/\\n}'

# 'ls' family
# Add colors for filetype and human-readable sizes by default on 'ls':
if [ "$(uname)" == "Darwin" ]; then
    # For colors on Mac, we need to install gls using "brew install coreutils"
    alias ls='gls -h --color=auto'
else
    alias ls='ls -h --color=auto'
fi
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.


#----------------------------#
#      Useful Functions      #
#----------------------------#

# Advanced directory creation
function mkcd {
  if [ ! -n "$1" ]; then
    echo "Please specify a name for the folder e.g. \"mkcd myfolder\"."
  elif [ -d $1 ]; then
    echo "\`$1' already exists."
  else
    mkdir $1 && cd $1
  fi
}

# Go back many times (e.g. "b 2" is the same as "cd ../..")
b() {
  str=""
  if [ ! -n "$1" ]; then
    count=1
  else
    count=$1
  fi
  while [ "$count" -gt 0 ];
  do
    str=$str"../"
    let count=count-1
  done
  cd $str
}

# Color man pages
man() {
  env \
  LESS_TERMCAP_mb=$(printf "\e[1;31m") \
  LESS_TERMCAP_md=$(printf "\e[1;31m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;32m") \
  man "$@"
}

# Auto cd into directories without needing to type cd before.
# Option only available after bash 4.0.
if [[ $(shopt -p) =~ "autocd" ]]; then
  shopt -s autocd
fi

# ls after a cd
function cd() {
  builtin cd "$*" && ls
}

# Extract archives (respective programs must be installed)
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xjf $1     ;;
      *.tar.gz)   tar xzf $1     ;;
      *.bz2)      bunzip2 $1     ;;
      *.rar)      unrar e $1     ;;
      *.gz)       gunzip $1      ;;
      *.tar)      tar xf $1      ;;
      *.tbz2)     tar xjf $1     ;;
      *.tgz)      tar xzf $1     ;;
      *.zip)      unzip $1       ;;
      *.Z)        uncompress $1  ;;
      *.7z)       7z x $1        ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find a file with a pattern in name:
function ff() {
  find . -type f -iname '*'"$*"'*' -ls ;
}

# Find a pattern in a set of files and highlight them:
#+ (needs a recent version of egrep).
function fstr() {
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
  shift $(( $OPTIND - 1 ))
  if [ "$#" -lt 1 ]; then
    echo "$usage"
    return;
  fi
  find . -type f -name "${2:-*}" -print0 | \
xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more
}

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make your directories and files access rights sane.
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}

# Process/system related Functions
function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }
function killps() {  # kill by process name
  local pid pname sig="-TERM"   # default signal
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: killps [-SIGNAL] pattern"
    return;
  fi
  if [ $# = 2 ]; then sig=$1 ; fi
  for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
  do
    pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
    if ask "Kill process $pid <$pname> with signal $sig?"
      then kill $sig $pid
    fi
  done
}

# Misc utilities. A few of the above functions depend on this!

function repeat() {  # example: repeat 10 echo 'hi'
  local i max
  max=$1; shift;
  for ((i=1; i <= max ; i++)); do  # --> C-like syntax
    eval "$@";
  done
}

function ask() {  # See 'killps' for example of use.
  echo -n "$@" '[y/n] ' ; read ans
  case "$ans" in
    y*|Y*) return 0 ;;
    *) return 1 ;;
  esac
}
