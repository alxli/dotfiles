# Alex's dotfiles

Config files and utility scripts for macOS, with partial GNU/Linux support.

The install commands below download individual files directly from GitHub. A
full clone is not required. Review remote scripts before running them if you
are installing on a new machine.

## Shell

- **`.bash_profile`** loads `.bashrc` for login shells.
- **`.bashrc`** is a portable Bash config for macOS and Linux. It includes:
  - Shell options: large history, `autocd`, `globstar`, and spelling correction
  - `$PATH` helpers: `prepend_to_PATH` and `append_to_PATH`
  - Prompt auto-detection for oh-my-posh, starship, powerline-go, and
    powerline-shell, with a colored fallback prompt
  - Safer aliases, navigation shortcuts, colorized `ls` and `grep`, and package
    manager shortcuts
  - Utility functions including `mkcd`, `up`, `ff`, `fd`, `extract`, `cpprun`,
    `killport`, `dl`, `sysinfo`, `trash`, `backup`, and `gcap`
  - A final `~/.bashrc.local` include for machine-specific settings

### Install or replace the shell config

Use this when your custom settings are already isolated in `~/.bashrc.local`.
It replaces `~/.bashrc` and `~/.bash_profile` with the latest remote versions:

```sh
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/.bashrc \
  -o "$HOME/.bashrc"
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/.bash_profile \
  -o "$HOME/.bash_profile"
bash -n "$HOME/.bashrc"
```

Reload the active shell configuration:

```sh
. "$HOME/.bashrc"
```

### Merge an existing `.bashrc`

If your current `~/.bashrc` still contains custom code, download the latest
template separately:

```sh
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/.bashrc \
  -o /tmp/dotfiles.bashrc
```

Then give an LLM with local file access this prompt:

```text
Review my current ~/.bashrc and /tmp/dotfiles.bashrc. Merge the latest template
changes from /tmp/dotfiles.bashrc into ~/.bashrc, including comments. Preserve
my custom behavior, but move machine-specific settings into ~/.bashrc.local
where appropriate. Do not overwrite unrelated local changes. Validate the
result with bash -n and explain what changed.
```

Optional prompt setup:

```sh
brew install bash
brew install --cask font-meslo-lg-nerd-font
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
```

## iTerm2

- **`iterm2_preset.json`** is an iTerm2 profile preset with a black background,
  green-on-black text, Meslo Nerd Font, Homebrew Bash, Option-as-Meta key
  mappings, and `xterm-256color`.

Download the preset:

```sh
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/iterm2_preset.json \
  -o "$HOME/Downloads/iterm2_preset.json"
```

Then open iTerm2 and use **Settings > Profiles > Other Actions > Import JSON
Profiles** to import `~/Downloads/iterm2_preset.json`.

## macOS Default Apps

- **`set_mac_defaults.swift`** sets default apps by file extension. The tracked
  defaults include MarkEdit for Markdown, Sublime Text for code and text files,
  and Elmedia Player for media. Edit the script if your preferred apps differ.

Download, review, and run it:

```sh
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/set_mac_defaults.swift \
  -o /tmp/set_mac_defaults.swift
less /tmp/set_mac_defaults.swift
swift /tmp/set_mac_defaults.swift
```

Find a macOS application's bundle ID with:

```sh
osascript -e 'id of app "App Name"'
```

## Toggle Dock Position

- **`toggle_dock_position/`** builds a macOS app that toggles the Dock between
  its left and bottom positions. The installer writes the app to
  `/Applications/Toggle Dock Position.app` and requests admin privileges.

Download and install it:

```sh
curl -fsSL https://github.com/alxli/dotfiles/archive/refs/heads/master.tar.gz \
  | tar -xz --strip-components=1 -C /tmp dotfiles-master/toggle_dock_position
/tmp/toggle_dock_position/install.sh
```

After installation, drag the app from `/Applications` to the Dock.

## Vim

- **`.vimrc`** configures the Molokai color scheme, 4-space tabs, line numbers,
  smart search, mouse support, `jk` to escape, and clipboard integration.
- **`.vim/colors/molokai.vim`** installs the Molokai color scheme.

Install both files:

```sh
mkdir -p "$HOME/.vim/colors"
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/.vimrc \
  -o "$HOME/.vimrc"
curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/.vim/colors/molokai.vim \
  -o "$HOME/.vim/colors/molokai.vim"
```

## Sublime Text

- **`Sublime Text/Packages/User/Preferences.sublime-settings`** configures the
  Monokai theme, 2-space tabs, an 80-character ruler, trailing-whitespace
  trimming, and UTF-8 defaults.

Install the preferences on macOS:

```sh
mkdir -p "$HOME/Library/Application Support/Sublime Text/Packages/User"
curl -fsSL 'https://raw.githubusercontent.com/alxli/dotfiles/master/Sublime%20Text/Packages/User/Preferences.sublime-settings' \
  -o "$HOME/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"
```
