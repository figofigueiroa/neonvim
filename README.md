# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Branch comparison

`<leader>gD` compares the committed `HEAD` tree with a selected local or remote
branch using CodeDiff's changed-file explorer. It compares the two committed
revisions directly; uncommitted working-tree changes are not included.

CodeDiff loads on demand and uses the repository in the current working
directory. This works on Linux and Windows with `git` on `PATH`, without
temporary exports or a dependency on `tar`.
