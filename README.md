# Dotfiles

Personal configuration files managed with
[chezmoi](https://www.chezmoi.io/).

This repository is an environment snapshot rather than a portable installer.
Review the rendered diff before applying it to a new machine because some files
depend on operating-system packages, locally installed tools, and
machine-specific paths.

## Managed configuration

The repository contains configuration for:

- shells and command-line tools
- terminals, editors, and desktop applications
- user services
- local helper scripts

SSH configuration and credentials are intentionally machine-local and are not
managed by this repository.

## Bootstrap

Install `git` and `chezmoi`, then initialize the repository:

```sh
chezmoi init mora1n/dotfiles
```

Inspect the destination changes before applying them:

```sh
chezmoi diff
chezmoi apply --interactive
```

For an existing checkout, update and review first:

```sh
chezmoi update --dry-run
chezmoi diff
chezmoi update --interactive
```

Do not run an unreviewed full apply on a machine that already has local
configuration. Apply individual targets when only one component is needed:

```sh
chezmoi apply ~/.zshrc
```

## Repository layout

Chezmoi source names encode target paths and file attributes:

```text
private_dot_config/  -> ~/.config/
private_dot_local/   -> ~/.local/
private_dot_zshrc    -> ~/.zshrc
dot_bashrc           -> ~/.bashrc
scripts/             -> ~/scripts/
```

Files prefixed with `executable_` are rendered with executable permissions;
files or directories prefixed with `private_` are rendered with private
permissions according to chezmoi's source-state conventions.
