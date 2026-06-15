# ~/.bashrc: executed by bash(1) for non-login shells.
# Portable .bashrc — works on Linux (Debian/Arch/RHEL) and macOS.
# Customize per-machine settings in ~/.bashrc.local (sourced at the end).

# If not running interactively, don't do anything.
case $- in
  *i*) ;;
    *) return;;
esac

#============================================================#
#                     Shell Options                          #
#============================================================#

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Large in-memory history and persist to disk. Keep HISTFILESIZE >= HISTSIZE
# so nothing is lost when the shell exits.
HISTSIZE=100000
HISTFILESIZE=200000

# Timestamp each history entry (useful for auditing).
HISTTIMEFORMAT="%F %T  "

# Append to history instead of overwriting it.
shopt -s histappend 2>/dev/null

# Check window size after each command and update LINES and COLUMNS.
shopt -s checkwinsize 2>/dev/null

# cd into a directory by typing just its name (bash 4+).
shopt -s autocd 2>/dev/null

# Allow ** to match files and directories recursively (bash 4+).
shopt -s globstar 2>/dev/null

# Correct minor spelling errors in cd arguments.
shopt -s cdspell 2>/dev/null

# Correct minor spelling errors during tab completion.
shopt -s dirspell 2>/dev/null

#============================================================#
#                         PATH                               #
#============================================================#

# Resolves symlinks via pwd -P.
_canonical_path_dir() {
  local d
  d=$({ builtin cd -- "$1" && { pwd -P || pwd; } } 2>/dev/null) || return
  [ -n "$d" ] && printf '%s\n' "$d"
}

remove_from_PATH() {
  local d path_part new_PATH old_IFS
  local -a path_parts
  for d; do
    d=$(_canonical_path_dir "$d") || continue
    old_IFS=$IFS
    IFS=:
    read -r -a path_parts <<< "$PATH"
    IFS=$old_IFS
    new_PATH=
    for path_part in "${path_parts[@]}"; do
      [ "$path_part" = "$d" ] && continue
      new_PATH="${new_PATH:+$new_PATH:}$path_part"
    done
    PATH="$new_PATH"
  done
}

# Add a directory to the end of $PATH if it exists and isn't already present.
append_to_PATH() {
  local d
  for d; do
    d=$(_canonical_path_dir "$d") || continue
    case ":$PATH:" in
      *":$d:"*) ;;
             *) PATH="${PATH:+$PATH:}$d" ;;
    esac
  done
}

# Move directories to the front of $PATH, preserving argument order.
# Existing copies are removed first, so this promotes paths already in $PATH.
prepend_to_PATH() {
  local d idx
  for (( idx=$#; idx>0; idx-- )); do
    d=${!idx}
    d=$(_canonical_path_dir "$d") || continue
    remove_from_PATH "$d"
    PATH="$d${PATH:+:$PATH}"
  done
}

#============================================================#
#              Your Custom PATH & Exports                    #
#============================================================#

# Common defaults (non-existent paths are silently skipped).
append_to_PATH /opt/bin /usr/local/bin /usr/local/sbin /usr/sbin "$HOME/.local/bin"

# Homebrew (macOS) — covers Apple Silicon and custom prefix installs.
if [ "$(uname)" = "Darwin" ]; then
  prepend_to_PATH /opt/homebrew/bin /opt/homebrew/sbin
  prepend_to_PATH "$HOME/homebrew/bin" "$HOME/homebrew/sbin"
  append_to_PATH /opt/homebrew/opt/coreutils/libexec/gnubin
  append_to_PATH "$HOME/homebrew/opt/coreutils/libexec/gnubin"
fi

# Add your own directories and environment variables below.

#============================================================#
#                    Completion                              #
#============================================================#

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -f /opt/homebrew/etc/bash_completion ]; then
    . /opt/homebrew/etc/bash_completion      # Homebrew on Apple Silicon
  elif [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion         # Homebrew on Intel Mac
  fi
fi

#============================================================#
#                   Terminal & Colors                        #
#============================================================#

# Silence the macOS "default interactive shell is now zsh" message.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Enable color prompt if the terminal supports it.
# NOTE: Do not hardcode TERM=xterm-256color — it breaks tmux, SSH, and screen.
# Let your terminal emulator set TERM correctly.
if [ -x /usr/bin/tput ] && tput setaf 1 >/dev/null 2>&1; then
  color_prompt=yes
elif [[ "$TERM" == *-256color || "$TERM" == xterm-color ]]; then
  color_prompt=yes
fi

# LS_COLORS via dircolors. Force xterm-256color palette for rich colors
# without overriding TERM (which breaks tmux/SSH/screen).
if command -v dircolors &>/dev/null; then
  if [ -r "$HOME/.dircolors" ]; then
    eval "$(TERM=xterm-256color dircolors -b "$HOME/.dircolors")" 2>/dev/null
  else
    eval "$(TERM=xterm-256color dircolors -b)" 2>/dev/null
  fi
fi

# Debian chroot indicator for the prompt.
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

#============================================================#
#                      Prompt                                #
#============================================================#

# Uses the first fancy prompt found, falling back to a simple colored prompt.
# NOTE: On macOS, stock bash is v3.2 — oh-my-posh and starship need bash 4+.
#   Upgrade with:    brew install bash
#   Then register:   echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
#   And switch:      chsh -s "$(brew --prefix)/bin/bash"
#   If iTerm2 still uses old bash, check Preferences > Profiles > General >
#   Command — set to "Login shell" or point directly to Homebrew's bash.
# Install any one of these (listed in priority order):
#   oh-my-posh:      curl -s https://ohmyposh.dev/install.sh | bash
#   starship:        curl -sS https://starship.rs/install.sh | sh
#   powerline-go:    go install github.com/justjanne/powerline-go@latest
#   powerline-shell: pipx install powerline-shell
# NOTE: Most of these prompts need a Nerd Font for icons/glyphs to render.
#   Install one from https://www.nerdfonts.com (e.g. "MesloLGS NF") and set
#   it as your terminal's font (iTerm2: Settings > Profiles > Text > Font).
#   On macOS:        brew install --cask font-meslo-lg-nerd-font
# Browse themes at: https://ohmyposh.dev/docs/themes
#   To persist a theme, make sure it's downloaded and set this in .bashrc.local:
#   OMP_CONFIG="$HOME/.cache/oh-my-posh/themes/jblab_2021.omp.json"
_set_basic_ps1() {
  PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
}

_init_prompt() {
  local _prompt_init

  if command -v oh-my-posh &>/dev/null && (( BASH_VERSINFO[0] >= 4 )); then
    if [ -n "${OMP_CONFIG:-}" ]; then
      _prompt_init=$(oh-my-posh init bash --config "$OMP_CONFIG" 2>/dev/null)
    else
      _prompt_init=$(oh-my-posh init bash 2>/dev/null)
    fi
    if [[ "$_prompt_init" == *"_omp_hook"* || "$_prompt_init" == *"POSH_SESSION_ID"* ]]; then
      eval "$_prompt_init"
    else
      _set_basic_ps1
    fi
  elif command -v starship &>/dev/null && (( BASH_VERSINFO[0] >= 4 )); then
    if _prompt_init=$(starship init bash 2>/dev/null); then
      eval "$_prompt_init"
    else
      _set_basic_ps1
    fi
  elif command -v powerline-go &>/dev/null && powerline-go -error 0 -jobs 0 >/dev/null 2>&1; then
    _update_ps1() {
      local status=$? prompt
      prompt=$(powerline-go -error "$status" -jobs "$(jobs -p | wc -l)" 2>/dev/null) \
        && PS1="$prompt" \
        || _set_basic_ps1
      return "$status"
    }
    [[ "$TERM" != linux && ! "${PROMPT_COMMAND:-}" =~ _update_ps1 ]] \
      && PROMPT_COMMAND="_update_ps1; ${PROMPT_COMMAND:-}"
  elif command -v powerline-shell &>/dev/null && powerline-shell 0 >/dev/null 2>&1; then
    _update_ps1() {
      local status=$? prompt
      prompt=$(powerline-shell "$status" 2>/dev/null) \
        && PS1="$prompt" \
        || _set_basic_ps1
      return "$status"
    }
    [[ "$TERM" != linux && ! "${PROMPT_COMMAND:-}" =~ _update_ps1 ]] \
      && PROMPT_COMMAND="_update_ps1; ${PROMPT_COMMAND:-}"
  else
    _set_basic_ps1
  fi
}
_set_basic_ps1

# Flush each command to ~/.bash_history immediately (survives crashes).
# Append so prompt hooks can still inspect the previous command's exit status.
if [[ ! ";${PROMPT_COMMAND:-};" =~ \;[[:space:]]*history[[:space:]]+-a[[:space:]]*\; ]]; then
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"
fi

#============================================================#
#                       Editor                               #
#============================================================#

export VISUAL=vim
export EDITOR="$VISUAL"

# --- Editors and configs ---
alias suedit='sudo "$VISUAL"'
alias fstab='sudo "$VISUAL" /etc/fstab'
alias grubcfg='sudo "$VISUAL" /etc/default/grub'

#============================================================#
#                       Aliases                              #
#============================================================#

# Source a separate aliases file if it exists.
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

# --- Safety nets ---
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -p"

# --- Navigation ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# --- ls family ---
# Pick the best `ls` across GNU (Linux / coreutils) and BSD (stock macOS).
# On macOS, install GNU coreutils for the full experience: brew install coreutils
# Use `command ls` for detection and aliases so aliases/functions cannot
# affect the probe or cause recursion when .bashrc is re-sourced.
if command -v gls &>/dev/null && gls --group-directories-first / &>/dev/null; then
  # GNU coreutils present as `gls` (e.g. Homebrew without gnubin in PATH).
  alias ls='gls -h --color=auto --group-directories-first'
elif command ls --group-directories-first / &>/dev/null; then
  # Default `ls` is GNU (typical on Linux).
  alias ls='command ls -h --color=auto --group-directories-first'
else
  # BSD ls (stock macOS): -G for color, no --group-directories-first.
  alias ls='command ls -hG'
fi
alias ll='ls -lv'
alias la='ll -A'            # Include hidden files.
alias lk='ls -lSr'          # Sort by size, biggest last.
alias lt='ls -ltr'          # Sort by date, most recent last.
alias lc='ls -ltcr'         # Sort by/show change time, most recent last.
alias lu='ls -ltur'         # Sort by/show access time, most recent last.
alias lr='ll -R'            # Recursive listing.

# --- grep with color ---
alias grep='grep --color=auto'

# --- Pretty-print ---
alias path='echo "${PATH}" | tr ":" "\n"'
alias printpath='path'
alias df='df -h'
alias du='du -h'

# --- Package managers (only defined when available) ---
command -v apt-get &>/dev/null && alias aptup="sudo apt-get update && sudo apt-get upgrade"
command -v pacman  &>/dev/null && alias pacup="sudo pacman -Syu"
command -v brew    &>/dev/null && alias brewup="brew update && brew upgrade"

#============================================================#
#                      Functions                             #
#============================================================#

# ---- Navigation ----

# ls after cd.
cd() {
  builtin cd "$@" && ls
}

# Create a directory and cd into it.
mkcd() {
  [ -z "$1" ] && { echo "Usage: mkcd <dir>"; return 1; }
  mkdir -p -- "$1" && builtin cd -- "$1"
}

# Go up N directories: "up 3" is equivalent to "cd ../../..".
up() {
  local d="" count="${1:-1}" i
  [[ "$count" =~ ^[0-9]+$ ]] || { echo "Usage: up [count]"; return 1; }
  for ((i = 0; i < count; i++)); do d="$d../"; done
  builtin cd "$d" || return 1
}

# ---- Search ----

# Find files by name pattern (case-insensitive).
ff() {
  [ -z "$1" ] && { echo "Usage: ff <pattern>"; return 1; }
  find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name pattern (case-insensitive).
fd() {
  [ -z "$1" ] && { echo "Usage: fd <pattern>"; return 1; }
  find . -type d -iname "*$1*" 2>/dev/null
}

# Search command history.
hist() {
  [ -z "$1" ] && { history 25; return; }
  history | grep -i -- "$1"
}

# Find a string in files recursively. Use -i for case-insensitive.
fstr() {
  local case_flag=""
  [ "$1" = "-i" ] && { case_flag="-i"; shift; }
  [ -z "$1" ] && { echo "Usage: fstr [-i] <pattern> [filename_pattern]"; return 1; }
  grep -rn --color=always ${case_flag:+"$case_flag"} --include="${2:-*}" -- "$1" . 2>/dev/null | less -R
}

# ---- Archives ----

# Extract common archive formats (respective tools must be installed).
extract() {
  [ ! -f "$1" ] && { echo "'${1:-}' is not a valid file."; return 1; }
  case "$1" in
    *.tar.bz2) tar xjf "$1"          ;;
    *.tar.gz)  tar xzf "$1"          ;;
    *.tar.xz)  tar xJf "$1"          ;;
    *.tar.zst) tar --zstd -xf "$1"   ;;
    *.bz2)     bunzip2 "$1"          ;;
    *.rar)     unrar x "$1"          ;;
    *.gz)      gunzip "$1"           ;;
    *.tar)     tar xf "$1"           ;;
    *.tbz2)    tar xjf "$1"          ;;
    *.tgz)     tar xzf "$1"          ;;
    *.zip)     unzip "$1"            ;;
    *.Z)       uncompress "$1"       ;;
    *.7z)      7z x "$1"             ;;
    *)         echo "'$1': unrecognized archive format."; return 1 ;;
  esac
}

# Create a .tar.gz archive from a file or directory.
maketar() {
  [ -z "$1" ] && { echo "Usage: maketar <file-or-dir>"; return 1; }
  tar cvzf "${1%%/}.tar.gz" "${1%%/}/"
}

# Create a .zip archive from a file or directory.
makezip() {
  [ -z "$1" ] && { echo "Usage: makezip <file-or-dir>"; return 1; }
  zip -r "${1%%/}.zip" "$1"
}

# ---- System Info ----

# Colored man pages via LESS_TERMCAP.
man() {
  env \
    LESS_TERMCAP_mb=$'\e[1;31m' \
    LESS_TERMCAP_md=$'\e[1;31m' \
    LESS_TERMCAP_me=$'\e[0m'    \
    LESS_TERMCAP_se=$'\e[0m'    \
    LESS_TERMCAP_so=$'\e[1;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m'    \
    LESS_TERMCAP_us=$'\e[1;32m' \
    man "$@"
}

# Pretty-print disk usage bar for given mount points (defaults to / and $HOME).
mydf() {
  local args=("$@") fs j
  [ ${#args[@]} -eq 0 ] && args=(/ .)
  for fs in "${args[@]}"; do
    [ ! -d "$fs" ] && { echo "$fs: No such directory"; continue; }
    local total used pct free
    read -r total used pct <<< "$(command df -P "$fs" | awk 'NR==2{print $2,$3,$5}')"
    free=$(command df -Ph "$fs" | awk 'NR==2{print $4}')
    if [ "${total:-0}" -le 0 ] 2>/dev/null; then
      echo "[--------------------] (empty filesystem on $fs)"
      continue
    fi
    local nbstars=$(( 20 * used / total ))
    local bar="["
    for ((j = 0; j < 20; j++)); do
      [ $j -lt $nbstars ] && bar+="*" || bar+="-"
    done
    bar+="]"
    echo "$pct $bar ($free free on $fs)"
  done
}

# Show primary local IP address (IPv4 preferred, IPv6 fallback).
myip() {
  local ip
  if command -v ip &>/dev/null; then
    ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
    [ -z "$ip" ] && ip=$(ip -6 route get 2001:4860:4860::8888 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
  elif command -v ifconfig &>/dev/null; then
    ip=$(ifconfig | awk '/inet / && !/127.0.0.1/{print $2; exit}' | sed 's/addr://')
    [ -z "$ip" ] && ip=$(ifconfig | awk '/inet6 / && !/fe80::/ && !/::1/{print $2; exit}')
  fi
  echo "${ip:-Not connected}"
}

# Quick system overview.
sysinfo() {
  local bold=$'\e[1m' reset=$'\e[0m'
  echo -e "\n${bold}Hostname:${reset}  $(hostname)"
  echo -e "${bold}Kernel:${reset}    $(uname -srm)"
  echo -e "${bold}Uptime:${reset}    $(uptime | sed 's/.*up //;s/,  *[0-9]* user.*//')"
  echo -e "${bold}Users:${reset}     $(who | awk '{print $1}' | sort -u | tr '\n' ' ')"
  echo -e "${bold}Date:${reset}      $(date)"
  echo -e "${bold}Local IP:${reset}  $(myip)"
  echo -e "${bold}Disk:${reset}"; mydf
  echo
}

# ---- Networking ----

# Show listening ports (auto-detects ss / lsof / netstat).
ports() {
  if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null
  elif command -v lsof &>/dev/null; then
    if [ "$1" = "-a" ]; then
      sudo lsof -iTCP -sTCP:LISTEN -n -P
    else
      lsof -iTCP -sTCP:LISTEN -n -P
    fi
  elif [ "$(uname)" = "Darwin" ]; then
    netstat -anv -p tcp 2>/dev/null | grep LISTEN
  elif command -v netstat &>/dev/null; then
    netstat -tlnp 2>/dev/null
  else
    echo "ports requires ss, lsof, or netstat." >&2
    return 1
  fi
}

# Kill process(es) listening on a given port.
killport() {
  local port="${1:?Usage: killport <port> [signal]}" sig="${2:-TERM}" pids pid
  command -v lsof &>/dev/null || { echo "killport requires lsof."; return 1; }
  [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )) || { echo "Invalid port: $port" >&2; return 1; }
  pids=$(lsof -ti :"$port" 2>/dev/null) || { echo "No process on port $port" >&2; return 1; }
  lsof -i :"$port" -P -n 2>/dev/null
  for pid in $pids; do
    kill -s "$sig" "$pid" 2>/dev/null && echo "Killed PID $pid (SIG$sig)" || echo "Failed to kill PID $pid" >&2
  done
}

# Copy a file back to the SSH client.
dl() {
  [ -z "${SSH_CLIENT:-}" ] && { echo "SSH_CLIENT is not set."; return 1; }
  [ -z "$1" ] && { echo "Usage: dl <file> [remote_dest]"; return 1; }
  local host="${SSH_CLIENT%% *}" dest="${2:-~/Downloads/}"
  [[ "$host" == *:* ]] && host="[$host]"
  scp "$1" "$USER@$host:$dest"
}

# ---- Files & Directories ----

# Tree view with sensible defaults (requires: brew install tree / apt install tree).
tre() {
  command -v tree &>/dev/null || { echo "tree not installed."; return 1; }
  tree -aC -I '.git|node_modules|vendor|__pycache__|.venv' --dirsfirst "$@" | less -FRNX
}

# Show the N (default 5) most recently modified files, skipping hidden.
newest() {
  local n="${1:-5}"
  [[ "$n" =~ ^[0-9]+$ ]] || { echo "Usage: newest [count]"; return 1; }
  if stat -c '%Y' / &>/dev/null 2>&1; then
    find . -type f ! -path '*/.*' -printf '%T@ %p\0' \
      | sort -zn \
      | tail -z -n "$n" \
      | cut -z -d' ' -f2- \
      | tr '\0' '\n'
  else
    find . -type f ! -path '*/.*' -print0 | xargs -0 stat -f '%m %N' | sort -n | tail -n "$n" | cut -d' ' -f2-
  fi
}

# Show top 10 largest files/dirs in current directory.
topsize() {
  if sort -h </dev/null &>/dev/null; then
    command du -hs -- * 2>/dev/null | sort -rh | head -10
  else
    command du -ks -- * 2>/dev/null | sort -rn | head -10 | awk '{ printf "%.1fM\t%s\n", $1 / 1024, substr($0, index($0,$2)) }'
  fi
}

# Move files to trash instead of deleting. Uses macOS Trash or freedesktop.
trash() {
  [ $# -eq 0 ] && { echo "Usage: trash <file> ..."; return 1; }
  if [ "$(uname)" = "Darwin" ]; then
    mv "$@" "$HOME/.Trash/"
  else
    local d="$HOME/.local/share/Trash/files"
    mkdir -p "$d" && mv "$@" "$d/"
  fi
}

# Backup a file to ~/backups/<name>-<timestamp>.bak before editing it.
backup() {
  [ -z "$1" ] && { echo "Usage: backup <file>"; return 1; }
  [ ! -f "$1" ] && { echo "'$1' is not a file."; return 1; }
  local dir="$HOME/backups"
  mkdir -p "$dir"
  local name; name="$(basename "$1")-$(date +%Y%m%d%H%M).bak"
  cp -- "$1" "$dir/$name" && echo "Backed up to $dir/$name"
}

# Set sane file permissions: owner rwX, group rX, others none.
sanitize() {
  [ $# -eq 0 ] && { echo "Usage: sanitize <path> ..."; return 1; }
  chmod -R u=rwX,g=rX,o= "$@"
}

# ---- Development ----

# Build and run a C++ file, showing execution time and exit code.
# Usage: cpprun [--clean|-c] file.cpp [args...] [<input] [>output]
#        CPPRUN_FLAGS='-DLOCAL -g' cpprun file.cpp
# Useful for competitive programming. On macOS, prefer `brew install gcc` over
# the built in Apple Clang, so stuff like <bits/stdc++.h> work.
cpprun() {
  local clean=0
  case "$1" in
    --clean|-c) clean=1; shift ;;
  esac

  [ -z "$1" ] && { echo "Usage: cpprun [--clean|-c] <file[.cpp]> [args...]"; return 1; }
  local basepath srcpath
  case "$1" in
    *.cpp|*.cc|*.cxx|*.C) basepath="${1%.*}"; srcpath="$1" ;;
    *) basepath="$1"; srcpath="$basepath.cpp" ;;
  esac
  [ ! -f "$srcpath" ] && { echo "File not found: $srcpath"; return 1; }

  local CXX
  for CXX in /opt/homebrew/bin/g++-[0-9]* g++ c++ clang++; do
    command -v "$CXX" &>/dev/null && break
  done
  command -v "$CXX" &>/dev/null || { echo "No C++ compiler found."; return 1; }

  "$CXX" "$srcpath" -o "$basepath" -O2 -std=c++20 -Wall ${CPPRUN_FLAGS:-} \
    || { echo "Build failed." >&2; return 1; }

  local start_s=$SECONDS status
  if [[ "$basepath" == */* ]]; then
    "$basepath" "${@:2}"
  else
    ./"$basepath" "${@:2}"
  fi
  status=$?
  (( clean )) && rm -f -- "$basepath"
  echo "Ran in $(( SECONDS - start_s ))s with exit code $status." >&2
  return $status
}

# ---- Git shortcuts ----

# Stage all, commit, and push in one step.
gcap() {
  [ -z "$1" ] && { echo 'Usage: gcap "commit message"'; return 1; }
  git add . && git commit -m "$*" && git push
}

#============================================================#
#                 Local Overrides                            #
#============================================================#

# Source machine-specific config last. Put host-specific or private
# settings (API keys, work aliases, etc.) here instead of this file.
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi

_init_prompt
