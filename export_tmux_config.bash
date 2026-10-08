#!/usr/bin/env bash
set -e

# The tmux configuration lives in a standalone file next to this script.
if [[ "$0" == */* ]]; then
  script_path="$0"
else
  script_path="$(command -v -- "$0" 2>/dev/null || printf '%s' "$0")"
fi
script_dir="$(CDPATH= cd -- "$(dirname -- "$script_path")" 2>/dev/null && pwd || pwd)"

tmux_conf="$script_dir/tmux.conf"
if [ ! -f "$tmux_conf" ]; then
  # Fall back to the current directory, e.g. when pasting this into a terminal.
  if [ -f "./tmux.conf" ]; then
    tmux_conf="$(pwd)/tmux.conf"
  else
    echo "Could not find tmux.conf."
    echo "Keep tmux.conf in the same folder as this script, then run it again."
    exit 1
  fi
fi

# Ensure Git is installed
if ! command -v git >/dev/null 2>&1; then
  echo "Git is not installed. Installing it now..."

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y git
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm git
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper --non-interactive install git
  elif command -v apk >/dev/null 2>&1; then
    sudo apk add git
  elif command -v brew >/dev/null 2>&1; then
    brew install git
  else
    echo "Could not find a supported package manager."
    echo "Please install Git manually and run this command again."
    exit 1
  fi
fi

echo "Using Git: $(git --version)"

# Install the tmux configuration from the standalone conf
if [ -f "$HOME/.tmux.conf" ] && ! cmp -s "$tmux_conf" "$HOME/.tmux.conf"; then
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
  echo "Backed up existing config to $HOME/.tmux.conf.bak"
fi
mkdir -p "$HOME/.tmux"
cp "$tmux_conf" "$HOME/.tmux.conf"

# Install the tmux plugin manager
mkdir -p "$HOME/.tmux/plugins"
if [ ! -d "$HOME/.tmux/plugins/tpm/.git" ]; then
  rm -rf "$HOME/.tmux/plugins/tpm"
  git clone --depth 1 \
    https://github.com/tmux-plugins/tpm \
    "$HOME/.tmux/plugins/tpm"
fi

# Reload the configuration when tmux is running
if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf"
fi

echo "Created $HOME/.tmux.conf (from $tmux_conf)"
echo "Start tmux, then press Ctrl-a followed by Shift-i to install plugins."
