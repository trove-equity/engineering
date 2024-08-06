#/bin/bash

# Color codes
RED='\033[0;91m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color


function confirmYesNo {
  Y=y; N=n
  if [ $# -gt 1 ]; then
    case ${1} in
      -DY) Y=Y; d=y;;
      -DN) N=N; d=n;;
    esac
    m=$2
  else
    m=$1
  fi
  read -r -p "$m ($Y/$N)? " -n 1 m
  case $m in
    Y|y) ans=y; echo;;
    N|n) ans=n; echo;;
     '') ans=$d;;
      *) ans='error'; echo;;
  esac
}


sudo_askpass() {
  if [ -n "$SUDO_ASKPASS" ]; then
    echo
    sudo --askpass "$@"
  else
    sudo "$@"
  fi
}


# Initialise (or reinitialise) sudo
sudo_init() {

  local SUDO_PASSWORD SUDO_PASSWORD_SCRIPT

  if ! sudo --validate --non-interactive &>/dev/null; then
    while true; do
      echo
      read -rsp "Enter your password (for sudo access):" SUDO_PASSWORD
      echo
      if sudo --validate --stdin 2>/dev/null <<<"$SUDO_PASSWORD"; then
        break
      fi

      unset SUDO_PASSWORD
      echo "!!! Wrong password!" >&2
    done


    SUDO_PASSWORD_SCRIPT="$(
      cat <<BASH
#!/bin/bash
echo "$SUDO_PASSWORD"
BASH
    )"
    unset SUDO_PASSWORD
    SUDO_ASKPASS_DIR="$(mktemp -d)"
    SUDO_ASKPASS="$(mktemp "$SUDO_ASKPASS_DIR"/pave-askpass-XXXXXXXX)"
    chmod 700 "$SUDO_ASKPASS_DIR" "$SUDO_ASKPASS"
    bash -c "cat > '$SUDO_ASKPASS'" <<<"$SUDO_PASSWORD_SCRIPT"
    unset SUDO_PASSWORD_SCRIPT

    export SUDO_ASKPASS
  fi
}


sudo_refresh() {
  if [ -n "$SUDO_ASKPASS" ]; then
    sudo --askpass --validate
  else
    sudo_init
  fi
}


# Setup shell profile for zsh
shell_profile() {
  if ! [ -f ${HOME}/.zshrc ]; then
    touch "$HOME/.zshrc"
    logN "No shell profile found. Created $HOME/.zshrc"
  fi

  if ! [ -f ${HOME}/.zprofile ]; then
    touch "$HOME/.zprofile"
    export PROFILE="$HOME/.zprofile"
    logN "No shell profile found. Created $PROFILE"
  else
    export PROFILE="$HOME/.zprofile"
  fi
}


# Check if string is in file
string_in_file() {
  grep -q "$1" "$2"
}


abort() {
  STRAP_STEP=""
  echo "!!! $*" >&2
  exit 1
}

# plain log
log() {
  SETUP_STEP=""
  printf -- "\n${YELLOW}%b${NC}\n" "$*"
}

# log plain with sudo refresh
logP() {
  STRAP_STEP="$*"
  sudo_refresh
  printf -- "\n%b\n" "$*"
}

# log notification
logN() {
  SETUP_STEP="$*"
  sudo_refresh
  printf -- "\n${YELLOW}%b${NC}\n" "$*"
}

# log alert
logA() {
  SETUP_STEP=""
  printf -- "\n${RED}%b${NC}\n" "$*" >&2
}

# log completion
logC() {
  SETUP_STEP=""
  printf -- "\n${GREEN}COMPLETED: %b${NC}\n" "$*"
}

# log skipped
logS() {
  SETUP_STEP=""
  printf -- "\n${CYAN}SKIPPED: %b${NC}\n" "$*"
}


# Check if a command exists
command_exists() {
  command -v "$@" >/dev/null 2>&1
}


SETUP_SUCCESS=""
cleanup() {
  set +e
  sudo_askpass rm -rf "$SUDO_ASKPASS" "$SUDO_ASKPASS_DIR"
  sudo --reset-timestamp
  if [ -z "$SETUP_SUCCESS" ]; then
    if [ -n "$SETUP_STEP" ]; then
      logA "!!! $SETUP_STEP FAILED"
    else
      logA "!!! SETUP FAILED"
    fi
  fi
}

trap "cleanup" EXIT