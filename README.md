<p align="center">
  <img src="assets/banner.svg" alt="cendre" width="880">
</p>

Dark colorscheme for Neovim. One wood fire, taken apart.

Every pigment hue was computed from something measurable in a burning log:
Planck's law for the coals, published emission wavelengths for everything else,
pushed through the CIE 1931 colour matching functions into OKLCH. Lightness and
chroma are chosen, because a spectral line sits far outside sRGB and has to be
brought into gamut anyway. Nothing was nudged toward a nicer number.

Dark only, on purpose. Every hue, ratio and surface is laid out at
**[cendretheme.com](https://cendretheme.com/)**.

```lua
{ "Aejkatappaja/cendre" }
```

Neovim 0.9 or newer, with `termguicolors`.

<img src="assets/editor.svg" alt="Go code in cendre, with git signs, diagnostics and a statusline" width="880">

Diagnostics, git signs, diff and statusline draw from the semantic family. An
error never wears the same red as a keyword.

## 29 surfaces, one palette

Neovim is where this starts, not where it stops. Ghostty, kitty, wezterm, foot,
Alacritty, Konsole, tmux, bat, delta, lazygit, yazi, eza, fzf, btop, starship,
helix, Zed, Obsidian, Firefox, KDE Plasma and the rest, with the path each one installs to:
[cendretheme.com/#surfaces](https://cendretheme.com/#surfaces).

Nothing under `extras/` or `assets/` is written by hand, nor the favicon and share
card under `docs/`. All of it is rendered from `lua/cendre/palette.lua`, so a
colour cannot be right in the editor and stale in a terminal, in this README, or
on the site:

```sh
nvim --headless --noplugin -u NONE -c "set rtp+=." -c "luafile scripts/extras.lua" -c q
```

**Every surface ships at all three depths.** A reader on `soft` wants `soft` in
their terminal too, so each directory holds `cendre`, `cendre-medium` and
`cendre-soft`. The unsuffixed name is the depth the plugin defaults to, so the
editor and everything around it match with no second decision.

Anything that stores a theme name rather than taking it from its filename gets
that name qualified per depth, or installing two of them collides on one entry in
Zed, bat, Obsidian and the rest. The test asserts that.

Ghostty, for example:

```
theme = cendre
```

Inside the editor, these get groups of their own rather than whatever their
defaults land on: gitsigns, blink.cmp, Snacks, fzf-lua, which-key, Noice,
neo-tree, nvim-tree, netrw, flash, trouble, lazy.nvim, mason, nvim-dap and dap-ui,
neotest, mini.indentscope, mini.hipatterns, hlchunk, grug-far, diffview,
illuminate, treesitter-context and rainbow-delimiters.

The 16 ANSI slots are also exported as `vim.g.terminal_color_*`, so `:terminal`
matches. Slot 5 is potassium's 404 nm line, derived the same way as the pigments,
and it exists because ANSI wants six hues while the editor needs five.

## Three depths, one palette

The pigments are the identity, so they never move. Only the ground under them
does, at three depths. A screenshot at one depth is recognisably the same theme
as a screenshot at another, which is the whole point.

| depth    | bg0       | L     | text     | comment | dimmest pigment |
| -------- | --------- | ----- | -------- | ------- | --------------- |
| `hard`   | `#171311` | 0.191 | 12.89:1  | 3.32:1  | 4.77:1          |
| `medium` | `#1d1917` | 0.217 | 12.18:1  | 3.14:1  | 4.51:1          |
| `soft`   | `#231f1d` | 0.243 | 11.41:1  | 2.94:1  | 4.22:1          |

`hard` is the default. It is deeper than any theme this was measured against, and
is the reason the ramp above it has to be finely stepped. `soft` is lifted to
where the dark themes people keep for years actually sit.

Switch at runtime, no restart:

```
:CendreBackground soft
:CendreBackground hard
```

## Install

lazy.nvim:

```lua
{
  "Aejkatappaja/cendre",
  lazy = false,
  priority = 1000,
  config = function()
    require("cendre").setup({
      background = "hard", -- "hard" | "medium" | "soft"
      italic_virtual_text = false,
    })
  end,
},
{
  "LazyVim/LazyVim",
  opts = { colorscheme = "cendre" },
}
```

Without LazyVim, just `vim.cmd.colorscheme("cendre")` after setup.

lualine picks it up with `options.theme = "cendre"`, or leave `"auto"`.

`:help cendre` covers the options, the commands and the role map in full.

## Options

| option            | default    | effect                                                   |
| ----------------- | ---------- | -------------------------------------------------------- |
| `background`      | `"hard"`   | ground depth: `hard`, `medium` or `soft`                  |
| `transparent`     | `false`    | strips Normal, floats and the statusline; plugin windows follow |
| `italic_virtual_text` | `false` | italics on inlay hints, ghost text, git blame, the dashboard footer |
| `italic_comments` | `true`     | italics on comments, independently of the above             |
| `on_colors`       | noop       | `function(colors)` mutates the palette before highlights  |
| `on_highlights`   | noop       | `function(highlights, colors)` gets the last word         |

The background is painted by default. The ash bed is a colour the theme derived,
so it may as well be on screen.

The two italic switches are independent, not one overriding the other, so
`italic_virtual_text = false` on its own leaves comments italic. Set both to
`false` for no italics. `italic` is the old name for `italic_virtual_text`, kept
as an alias that warns, and removed in 2.0. `Italic` and `@markup.italic` are
outside both, because italic is their entire definition: strip it and
`*emphasis*` renders as body text.

With `transparent = true`, plugin windows go through too, without being listed one
by one: which-key, the Snacks picker, Noice and fzf-lua link their windows to
`NormalFloat`, so stripping that strips all of them, including plugins released
after this README. The completion menu is the exception and stays painted, since a
transparent popup over code is not readable. That covers `Pmenu` and blink.cmp's own
windows, which read neither `Pmenu` nor `NormalFloat`.

```lua
require("cendre").setup({
  on_highlights = function(hl, c)
    hl.Comment = { fg = c.bg5 }
  end,
})
```

## The cursor stays your terminal's

`Cursor`, `lCursor`, `CursorIM` and `TermCursor` are all set to `ember`, and outside
`:terminal` Neovim never asks for them. Its default `'guicursor'` names a highlight
group only for terminal mode:

```
n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor
```

With no group on the other parts, the terminal draws its own cursor in its own
colour. So a black cursor on this theme is your terminal's setting, not a missing
highlight.

The theme does not set `'guicursor'`, because that option carries the cursor's
shape and blink rather than its colour, and those are yours.

Two ways to change it. Install the terminal theme for whatever you run, and the
cursor matches in the editor and in the shell, since every file under `extras/`
sets it. Or hand the cursor to Neovim by naming the group on the other modes:

```lua
vim.opt.guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,"
  .. "r-cr-o:hor20-Cursor,t:block-blinkon500-blinkoff500-TermCursor"
```

## Palette

Ground, hue 43°, which is wood ash under a 1300 K flame. Ash is spectrally flat,
so it lands within a degree of the bare flame itself. Shown at `hard`, the default:

| token     | hex       | L     | use                |
| --------- | --------- | ----- | ------------------ |
| `bg_deep` | `#0f0c0a` | 0.156 | floats, sidebars   |
| `bg0`     | `#171311` | 0.191 | editor             |
| `bg1`     | `#201b19` | 0.227 | cursorline         |
| `bg2`     | `#2a2422` | 0.266 | statusline         |
| `bg3`     | `#362f2c` | 0.312 | splits             |
| `bg4`     | `#463e3a` | 0.371 | hover              |
| `bg5`     | `#5a504c` | 0.440 | float edges        |

Ink, shared by every depth. Ratios against `bg0` at `hard`:

| token     | hex       | ratio   | use                   |
| --------- | --------- | ------- | --------------------- |
| `fg`      | `#e6d5c2` | 12.89:1 | body text             |
| `fg_dim`  | `#a09384` |  6.15:1 | operators, delimiters |
| `comment` | `#73665b` |  3.32:1 | comments              |
| `gutter`  | `#4e4641` |  2.00:1 | line numbers, inlay   |

`comment` is deliberately under AA. Every dark theme people keep for years puts
comments below that line, most around 3.3:1, and a comment as loud as the code
it explains is noise.

The five pigments, in order of lightness, which is also order of distance from
the fire:

| name     | hue    | L     | source              | role                            |
| -------- | ------ | ----- | ------------------- | ------------------------------- |
| `brass`  |  61.4° | 0.838 | sodium D 589 nm     | functions, methods, calls       |
| `ember`  |  43.8° | 0.754 | blackbody 1300 K    | properties, fields, params, UI  |
| `sap`    | 123.4° | 0.721 | C₂ Swan 563 nm      | every literal value             |
| `cinder` |  25.9° | 0.665 | CaOH band 622 nm    | keywords, control flow, storage |
| `frost`  | 227.4° | 0.600 | C₂ Swan 474 nm      | types, classes, constructors    |

Arc 202°, smallest gap 17.6°, chroma 0.072 to 0.115. A fire does not offer
well-spaced warm hues: cinder, ember and brass sit within 36° of each other
because that is where calcium, soot and sodium actually are. They stay legible
on lightness instead, which is also why `brass` is the brightest thing on screen
and `frost` the dimmest.

Semantic colours (`error` `warn` `ok` `hint` `info`) are a separate family, all
carrying more chroma than any pigment, so a diagnostic never wears the same red
as a keyword. Chroma is held inside 0.125 to 0.160: unbounded, the optimiser
that placed them produced neon.

Each hue traced from its spectrum to its hex:
[cendretheme.com/#derivation](https://cendretheme.com/#derivation).

## Rules it obeys

1. Hue comes from the source, separation is bought with lightness.
2. One role, one pigment. No token depends on bold or italic.
3. A declared name is not a role. Variables and constant names stay in `fg`, and
   only the value a constant holds takes a pigment.
4. Punctuation is not a token. Operators, commas and brackets take `fg_dim`.
5. Diagnostics are their own family, separate from the pigments.
6. Nothing readable under 4.5:1, with three exceptions that are stated rather
   than hidden: `comment` everywhere, and `frost` and `error` on `soft`.

## Test

```sh
nvim --headless --noplugin -u NONE -c "set rtp+=." -c "luafile test/smoke.lua"
```

Loads every depth through `nvim_set_hl`, which throws on a missing palette key,
then asserts that the switches behave, that `:CendreBackground` swaps the live
ground and rejects junk, that the pigments never drift between depths, that no
pigment collides with a diagnostic, that every published contrast ratio is what
the code actually measures, that the role map lands where this README says, that
no readable token leans on bold or italic, and that every committed file under
`extras/`, `assets/` and `docs/` matches a fresh render of the palette. Exits
non-zero on failure.

## Discussions

Four threads are open, and none of them is a bug report:

- [Show your setup](https://github.com/Aejkatappaja/cendre/discussions/43), any
  surface, any depth. The only screenshot here is mine.
- [Which surface next](https://github.com/Aejkatappaja/cendre/discussions/47), a
  poll over eight candidates.
- [Argue with the palette](https://github.com/Aejkatappaja/cendre/discussions/44).
  The hue is not negotiable, everything chosen around it is.
- [Install and setup questions](https://github.com/Aejkatappaja/cendre/discussions/45),
  including the black cursor.

## Licence

MIT.
