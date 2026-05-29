Alex's dotfiles
========

My config files and scripts for macOS (and partially GNU/Linux).

## Shell

- **`.bash_profile`** — Loads `.bashrc` for login shells.
- **`.bashrc`** — Portable bash config (macOS + Linux). Includes:
  - Shell options: large history, `autocd`, `globstar`, `cdspell`
  - Smart `$PATH` management (`prepend_to_PATH` / `append_to_PATH`)
  - Prompt: auto-detects oh-my-posh, starship, powerline-go, or powerline-shell (falls back to a colored prompt)
  - Aliases: safety nets (`rm -i`, `cp -i`), navigation (`..`, `...`), colorized `ls`/`grep`, package manager shortcuts
  - Functions: `mkcd`, `up`, `ff`/`fd` (find files/dirs), `extract` (archives), `cpprun` (build & run C++), `killport`, `sysinfo`, `trash`, `backup`, `gcap` (git add-commit-push), and more
  - Sources `~/.bashrc.local` for machine-specific overrides

## macOS Scripts

- **`set_mac_defaults.swift`** — Sets default apps by file extension (e.g. `.md` → MarkEdit, code files → Sublime Text, media → Elmedia Player). Uses `NSWorkspace.setDefaultApplication` for proper UTI handling. Edit the script’s defaults map to your own preferred defaults (find bundle IDs with `osascript -e 'id of app "App Name"’`) before running:

  ```
  swift set_mac_defaults.swift
  ```

- **`toggle_dock_position/`** — Toggles the macOS Dock between left and bottom positions. Installs as an app you can drag to the Dock.

  ```sh
  ./toggle_dock_position/install.sh
  ```

  Builds the `.app` installs it to `/Applications`.

## iTerm2

- **`iterm2_preset.json`** — iTerm2 profile preset: black background, green-on-black text, Meslo Nerd Font, Homebrew bash as shell, Option-as-Meta key mappings, xterm-256color.

## Vim

- **`.vimrc`** — Molokai color scheme, 4-space tabs, line numbers, smart search, mouse support, `jk` to escape, clipboard integration.
- **`.vim/colors/molokai.vim`** — Molokai color scheme file.

## Sublime Text

- **`Sublime Text/Packages/User/Preferences.sublime-settings`** — Monokai theme, 2-space tabs, 80-char ruler, trim trailing whitespace, UTF-8 defaults.
