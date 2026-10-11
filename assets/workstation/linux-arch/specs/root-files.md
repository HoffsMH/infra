# root/: system files outside $HOME

`assets/workstation/linux-arch/root/` mirrors `/`. A file at
`root/etc/prometheus/prometheus.yml` is installed to
`/etc/prometheus/prometheus.yml`. It is the `/etc` counterpart of
`dotfiles/`, which mirrors `$HOME`.

## Rules

- **Copy, never symlink.** `root.set` copies every file in each layer's
  `root/` to `/`, root-owned, mode 644 (755 if executable, 440 under
  `/etc/sudoers.d/`). It never overwrites a differing file without `-f`,
  and `-n` is a dry run. It refuses a sudoers file that fails `visudo -c`.
  Why: root-owned services read these files, often as their own users, and
  must not depend on a path inside a user's home. A sudoers link into
  `$HOME` would also let any process running as the user grant itself root.
  `links.set` handles `$HOME` only.
- **Files only.** `root/` holds files that are installed. Docs live in
  `specs/`, scripts beside `root/`. Nothing at the top level of `root/`
  other than directories that mirror `/`.
- **A setup script owns packages and services, when files need them.**
  `setup-<thing>.sh` installs the packages its files configure and enables
  the services. A file that needs neither, like a sudoers drop-in, needs no
  script. Example: [`../setup-monitoring.sh`](../setup-monitoring.sh).
- **Repo is the source of truth.** Edit the file in `root/`, then rerun
  `root.set` (and the setup script, if any). If you edited `/etc` live, copy it back into `root/` in the
  same session.
- **Do not touch package-owned files when a drop-in exists.** Prefer
  `/etc/systemd/system/<unit>.d/*.conf`, `/etc/conf.d/<unit>`, or a
  separately named config file over editing a file pacman ships. Why: no
  `.pacnew` conflicts, and the diff against upstream stays obvious.
- **Layer.** `root/` sits in `linux-arch` because nothing here is
  Omarchy-specific. An Omarchy-only system file would go in
  `omarchy/root/`.

## Not yet migrated

`omarchy/setup-xremap.sh` predates this and installs files from
`omarchy/xremap/` into `/etc`. Leave it until there is a reason to touch
it; then move its files to `root/` under the same rules.
