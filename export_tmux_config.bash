bash <<'BASH'
set -e

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

# Create the tmux configuration
mkdir -p "$HOME/.tmux/plugins"

cat > "$HOME/.tmux.conf" <<'TMUX'
set-option -sa terminal-overrides ",xterm*:Tc"
set -g mouse on

# Prefix: Ctrl-a
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Split window into panes
bind h split-window -v
bind v split-window -h

# Start windows and panes at 1
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Switch panes with Alt + arrow keys
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

run '~/.tmux/plugins/tpm/tpm'
TMUX

# Install the tmux plugin manager
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

echo "Created $HOME/.tmux.conf"
echo "Start tmux, then press Ctrl-a followed by Shift-i to install plugins."
BASH