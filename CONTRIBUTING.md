# Contributing

The one rule that will bite you if you skip it: **nothing under `extras/`,
`assets/` or `docs/` is written by hand.** Those 87 files are rendered from
`lua/cendre/palette.lua`, and the test fails on any difference. Edit the
generator, not the output.

## Run the test first

```sh
nvim --headless --noplugin -u NONE -c "set rtp+=." -c "luafile test/smoke.lua"
```

It exits non-zero on failure. `smoke (stable)` and `smoke (nightly)` are both
required to merge, so a red test is not a review comment, it is a blocked branch.

## Regenerate after touching a colour

```sh
nvim --headless --noplugin -u NONE -c "set rtp+=." -c "luafile scripts/extras.lua" -c q
```

Commit what it writes. A pull request that changes the palette without the
regenerated files fails the drift check.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/),
`type(scope): subject`, in English. release-please reads them to build
`CHANGELOG.md` and pick the next version, so the type is not decoration.

`feat` and `fix` produce a changelog entry. `docs`, `test`, `refactor`, `ci` and
`chore` do not, which is fine and often correct.

Scopes in use:

| scope | what it covers |
| --- | --- |
| `palette` | the derived colours in `lua/cendre/palette.lua` |
| `groups` | highlight groups under `lua/cendre/groups/` |
| `extras` | a generator under `lua/cendre/extras/`, and its output |
| `lualine` | the lualine theme |
| `site` | the landing page under `docs/` |
| `ci` | workflows, checks, release tooling |

Prefer several small commits to one large one. `Release-As:` in a footer forces a
version when a release needs one.

## Adding highlight groups

Read `:help cendre-roles` first. The map is the whole design, and a group that
ignores it will look wrong beside every other group:

| pigment | role |
| --- | --- |
| `cinder` | keywords, control flow, storage |
| `ember` | properties, fields, parameters, and the UI accent |
| `brass` | functions, methods, calls |
| `sap` | every literal value |
| `frost` | types, classes, constructors, modules |

Two rules that follow from it, both asserted by the test:

- A declared name is not a role. Variables and constant names stay in `fg`, and
  only the value a constant holds takes a pigment.
- Punctuation is not a token. Operators, commas and brackets take `fg_dim`.

Diagnostics are a separate family. `error` `warn` `ok` `hint` `info` all carry
more chroma than any pigment, so a diagnostic never wears the same red as a
keyword. Never reach for a pigment to signal a state.

**Do not paint plugin windows.** which-key, the Snacks picker, Noice, fzf-lua and
the rest link their windows to `NormalFloat` and their edges to `FloatBorder`.
Colouring those two colours all of them, including plugins released after you
read this. A verbatim copy of either group pins a colour that
`transparent = true` then cannot strip, and there is a test that fails on it.

Nothing readable goes under 4.5:1. Three colours do and are named in the README
rather than hidden: `comment` everywhere, and `frost` and `error` at the `soft`
depth. A fourth needs a reason and a line in the documentation.

## Adding a surface

Write a generator in the right module under `lua/cendre/extras/`, register it in
`lua/cendre/extras/init.lua`, regenerate, and add a test that pins the tool's
schema.

That last part is the one worth insisting on. Every surface fixed so far was
broken the same way: the tool ignored what it did not recognise instead of
refusing it, so half a theme applied and nothing said which half. yazi silently
dropped two retired sections, hunk silently dropped four keys that were never on
its list. The drift check cannot catch that, because regenerating makes the file
agree with itself.

So find the list the tool's own code reads, not its documentation page. For yazi
that was its shipped preset theme, for hunk a constant in its parser, for
opencode a TypeScript type. Two of those three disagreed with the published docs.

Then, if the tool stores a theme name rather than taking it from its filename,
qualify it per depth, or `cendre` and `cendre-soft` installed together collide on
one entry.

## Colours

Every hue was computed from a measurable property of a wood fire: Planck's law at
1300 K for the coals, published emission wavelengths for the rest, through the
CIE 1931 colour matching functions into OKLCH. Lightness and chroma are choices,
because a spectral line sits far outside sRGB and has to be brought into gamut.

A pull request that changes a hue needs to say where the new one comes from. That
constraint is the project, not a formality. "It looks better" is a valid opinion
and belongs in a
[discussion](https://github.com/Aejkatappaja/cendre/discussions), where it may
well win.

## Licence

MIT. By contributing you agree your work ships under it.
