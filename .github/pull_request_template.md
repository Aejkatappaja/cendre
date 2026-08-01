## What this changes

<!-- One or two sentences. What is different after this lands, and why. -->

## Commit messages

This repository uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/),
`type(scope): subject`, because release-please reads them to build the changelog
and pick the next version. `feat` and `fix` produce a changelog entry, the rest
do not.

Scopes in use: `palette`, `groups`, `extras`, `lualine`, `site`, `ci`.

- [ ] Every commit follows `type(scope): subject`

## If this touches colours

- [ ] Nothing under `extras/`, `assets/` or `docs/` was edited by hand. All 87
      of those files are rendered from `lua/cendre/palette.lua`, and the test
      fails on any difference
- [ ] Regenerated with the command in `CONTRIBUTING.md`, and the regenerated
      files are committed
- [ ] Every colour comes from the palette. Nothing hardcoded, nothing blended

## If this adds highlight groups

- [ ] The role map holds: keywords `cinder`, functions `brass`, literals `sap`,
      types `frost`, properties and parameters `ember`. Declared names stay in
      `fg`, punctuation in `fg_dim`. See `:help cendre-roles`
- [ ] Diagnostics use the semantic family, never a pigment
- [ ] No plugin window repeats `NormalFloat` or `FloatBorder`. Link to them
      instead, or `transparent = true` cannot reach it. There is a test for this
- [ ] Nothing readable lands under 4.5:1, or it is stated rather than hidden

## Verified

- [ ] `smoke (stable)` and `smoke (nightly)` pass. Both are required to merge

<!--
Numbers in a description are worth more than adjectives. If you measured a
contrast ratio, read a tool's schema, or proved a test fails without your fix,
say so and show it.
-->
