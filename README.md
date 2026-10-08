# tmux config

Two files:

- `tmux.conf` — the tmux configuration (prefix `Ctrl-a`, mouse on, `h`/`v` splits, panes start at 1, Alt+arrows switch panes).
- `export_tmux_config.bash` — installs it.

## Usage

Run the script from this folder:

```bash
./export_tmux_config.bash
```

It installs Git if missing, copies `tmux.conf` to `~/.tmux.conf` (backing up an existing one to `~/.tmux.conf.bak`), and installs the [tpm](https://github.com/tmux-plugins/tpm) plugin manager.

Or do it by hand: copy `tmux.conf` to `~/.tmux.conf`, then install tpm:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## After starting tmux

Press `Ctrl-a` then `Shift-i` to install the plugins.
