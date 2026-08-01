# Security policy

## Reporting

Report privately, through
[GitHub's advisory form](https://github.com/Aejkatappaja/cendre/security/advisories/new).
Not as an issue, and not on the Reddit thread. Private vulnerability reporting is
enabled on this repository, so that form reaches the maintainer and nobody else. If
you would rather use email, **frank.refactored@gmail.com** reaches the same person.

Expect a first reply within a week. If a report turns out to be real, the fix and
the advisory go out together.

## Supported versions

The latest release only. This is a colorscheme with no dependencies and no
runtime state, so there is nothing to backport a patch to: upgrading is reading
one line in a plugin manager.

| version | supported |
| --- | --- |
| latest release | yes |
| anything older | no, upgrade |

## What is actually worth reporting

This repository is Lua that runs inside the reader's editor, plus three GitHub
Actions workflows and one token. That is the whole surface, and it is small
enough to name:

- **Code execution.** `require("cendre")` runs on colorscheme load. Anything in
  `lua/` that runs a shell command, reads a file outside the plugin, or opens a
  socket does not belong there and is a real finding. The colorscheme reads no
  file at runtime: `lua/cendre/extras/` is only ever executed by
  `scripts/extras.lua`, by hand.
- **A release that does not match this source.** The tag, the published files and
  a fresh render of `lua/cendre/palette.lua` should agree. If they do not, say
  so, whatever the cause.
- **Anything reaching a workflow's write permissions or a secret.** The release
  workflow pushes to a second repository with a scoped token. A way to make it
  push somewhere else, or to print that token, is a real finding.
- **A generated file that does not match the palette.** More likely a bug than an
  attack, and the test catches it, but report it either way if you find one the
  test misses.

## What is not a vulnerability

- A colour you dislike, or one that reads badly on your monitor. That is a
  [discussion](https://github.com/Aejkatappaja/cendre/discussions).
- A contrast ratio under 4.5:1 that the documentation already names. `comment`
  everywhere, and `frost` and `error` at the `soft` depth, are deliberate and
  stated in the README.
- A Dependabot alert on a dependency. There are none: no `package.json`, no
  `Cargo.toml`, no lockfile. If a tool tells you otherwise, it is looking at a
  fork.
