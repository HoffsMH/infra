# Shell (zsh)

## Default login shell

`zsh` (set via `chsh -s /usr/bin/zsh`). Confirm with
`getent passwd $USER | awk -F: '{print $7}'`.

## Configuration files

```
~/.zshrc                            (currently in-place; TODO: move to infra symlink)
~/.zsh/functions_and_aliases.sh     (copied from infra common)
```

Source of truth in infra (for the functions/aliases file):
`~/infra/assets/workstation/common/dotfiles/.zsh/functions_and_aliases.sh`.

## What's in .zshrc

- Source `~/.zsh/functions_and_aliases.sh`
- Tool init, gracefully skipped if absent:
  - `zoxide init zsh`
  - `direnv hook zsh`
  - `starship init zsh`
  - `atuin init zsh --disable-up-arrow --disable-ctrl-r`
- Plugins (Arch package paths):
  - `/usr/share/zsh/plugins/zsh-autopair/autopair.plugin.zsh`
  - `/usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh`
- `SSH_AUTH_SOCK` from `gpgconf --list-dirs agent-ssh-socket`
- `PATH` extension: `~/bin`, `~/.local/bin`
- `bindkey -e` (emacs mode); `bindkey '^e' edit_command` (open current
  command line in nvim for full editing)
- `fastfetch` greeting on startup

## Required packages (Arch / yay)

```
zoxide  fzf  lazygit  atuin  direnv  duf
zsh-fast-syntax-highlighting  zsh-autopair-git
fastfetch
```

(Plus the standard zsh, starship, eza, bat, dust, fd which are usually
already present on Omarchy.)

## Notes

- `~/.zsh/functions_and_aliases.sh` ports the **common** variant from
  infra (newer than the nix-specific one). Includes `mov-to-gif`,
  `extract`, `random_key`, `yotp`, fuzzy git checkout, and standard
  git/docker/PASS aliases.
- The mac `.zshrc` was Mac-specific (homebrew, asdf, gcloud, postgres
  paths) and intentionally not copied. The Linux `.zshrc` is a clean
  rewrite.
- The nix `.zshrc.common` had a `bindkey '^o' edit_last_output` referring
  to a function that wasn't defined in the imported common file. Skipped.
