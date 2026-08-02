local M = {}

-- Cendre. One palette, three background depths.
--
-- Hue is not a choice here. Every pigment hue was computed from something
-- measurable in one burning log: Planck's law for the coals, published emission
-- wavelengths for the rest, pushed through the CIE 1931 colour matching
-- functions into OKLCH. Lightness and chroma are ours, because a spectral line
-- sits far outside sRGB and has to be brought into gamut anyway.
--
-- Lightness tracks distance from the heat. The warm three sit in the light, the
-- cool one sits in the dark, and that ordering is what buys back the separation
-- a fire refuses to give: cinder, ember and brass land 17.9° and 17.6° apart
-- because that is where calcium, soot and sodium actually are.

M.backgrounds = { "hard", "medium", "soft" }

-- The depth everything ships at unless told otherwise: the plugin, the landing
-- page and the unsuffixed file in every extras/ directory.
M.default = "hard"

--- The theme's name at a given depth. Any surface that stores a name, rather
--- than taking it from the filename, needs this: two depths installed under one
--- name collide on a single entry in Zed, bat, Obsidian and the rest.
--- @param bg string
--- @return string
function M.name(bg)
  return bg == M.default and "cendre" or ("cendre-" .. bg)
end

-- The ground, hue 43°, which is wood ash under a 1300 K flame. Ash is
-- spectrally flat, so it lands within a degree of the bare flame itself.
-- Seven steps, finely spaced, because a float over a statusline over a
-- cursorline has to read as one material at different distances.
M.grounds = {
  hard = {
    bg_deep = "#0f0c0a", -- L 0.156 · floats, sidebars
    bg0     = "#171311", -- L 0.191 · editor
    bg1     = "#201b19", -- L 0.227 · cursorline
    bg2     = "#2a2422", -- L 0.266 · statusline
    bg3     = "#362f2c", -- L 0.312 · borders, splits
    bg4     = "#463e3a", -- L 0.371 · hover
    bg5     = "#5a504c", -- L 0.440 · highest layer
  },
  medium = {
    bg_deep = "#141110", -- L 0.182
    bg0     = "#1d1917", -- L 0.217
    bg1     = "#26211f", -- L 0.253
    bg2     = "#312a28", -- L 0.292
    bg3     = "#3d3633", -- L 0.338
    bg4     = "#4e4541", -- L 0.397
    bg5     = "#625753", -- L 0.466
  },
  soft = {
    bg_deep = "#1a1716", -- L 0.208
    bg0     = "#231f1d", -- L 0.243
    bg1     = "#2d2725", -- L 0.279
    bg2     = "#37312e", -- L 0.318
    bg3     = "#443c39", -- L 0.364
    bg4     = "#554c48", -- L 0.423
    bg5     = "#695e5a", -- L 0.492
  },
}

-- Ink. Shared by every depth, so a screenshot at one depth is recognisable as
-- the same theme as a screenshot at another.
--
-- comment sits at 3.32:1 on hard, deliberately under AA. Every dark theme
-- people keep for years puts comments below that line, most around 3.3:1, and
-- a comment as loud as the code it explains is noise.
M.ink = {
  fg      = "#e6d5c2", -- L 0.882 · 12.89:1 on hard
  fg_dim  = "#a09384", -- L 0.670 ·  6.15:1 · operators, delimiters
  comment = "#73665b", -- L 0.520 ·  3.32:1 · quiet on purpose
  gutter  = "#4e4641", -- L 0.400 ·  2.00:1 · line numbers, inlay
}

-- The five pigments, in order of lightness, which is also order of distance
-- from the fire. One role each, and no role needs bold or italic to be read.
M.pigments = {
  brass  = "#fcba81", --  61.4° · L 0.838 · sodium D 589 nm      · functions, methods, calls
  ember  = "#ea9875", --  43.8° · L 0.754 · blackbody 1300 K     · properties, fields, params, UI
  sap    = "#99af6b", -- 123.4° · L 0.721 · C2 Swan 563 nm       · every literal value
  cinder = "#d1766e", --  25.9° · L 0.665 · CaOH band 622 nm     · keywords, control flow, storage
  frost  = "#4e89a2", -- 227.4° · L 0.600 · C2 Swan 474 nm       · types, classes, constructors
}

-- Diagnostics are a separate family, all of them carrying more chroma than any
-- pigment, so an error never wears the same red as a keyword. Chroma is held
-- inside 0.125 to 0.160: unbounded, the optimiser that placed these produced
-- neon that would have wrecked the theme.
M.semantic = {
  error = "#d25780", --   2.0° · C 0.160
  warn  = "#f4a21c", --  71.7° · C 0.160
  ok    = "#43b16a", -- 152.1° · C 0.145
  hint  = "#20c9cb", -- 196.2° · C 0.125
  info  = "#58bdff", -- 240.4° · C 0.133
}

-- Tinted grounds for diff and visual, per depth, so a selection lifts off the
-- editor by the same amount whichever ground is under it.
M.tints = {
  hard   = { vis = "#2f1e17", add = "#202515", del = "#301d1b", mod = "#12262e" },
  medium = { vis = "#36241d", add = "#262c1b", del = "#372321", mod = "#182c35" },
  soft   = { vis = "#3d2b23", add = "#2d3221", del = "#3e2a28", mod = "#1f333b" },
}

-- Derived like the pigments, and not one of them: it fills ANSI slot 5 and never
-- touches a token, so it stays out of M.pigments.
M.spectral = {
  potassium        = "#9480ba", -- 299.8° · L 0.640 · potassium 404 nm · ANSI slot 5
  potassium_bright = "#a692cd", -- same hue, L +0.06
}

local INFO_BRIGHT = "#8bcfff" -- info, L +0.06

-- Resolve a background name into a full colour table. Terminal slots are
-- derived from the pigments rather than restated, so they cannot drift.
function M.get(name)
  local ground = M.grounds[name] or M.grounds.hard
  local c = vim.tbl_extend("force", {},
    vim.deepcopy(ground),
    vim.deepcopy(M.ink),
    vim.deepcopy(M.pigments),
    vim.deepcopy(M.semantic),
    vim.deepcopy(M.spectral),
    vim.deepcopy(M.tints[name] or M.tints.hard))

  c.none = "NONE"

  c.terminal_black          = c.bg1
  c.terminal_red            = c.cinder
  c.terminal_green          = c.sap
  c.terminal_yellow         = c.brass
  c.terminal_blue           = c.info
  c.terminal_magenta        = c.potassium
  c.terminal_cyan           = c.frost
  c.terminal_white          = c.fg_dim
  c.terminal_bright_black   = c.comment
  c.terminal_bright_red     = c.error
  c.terminal_bright_green   = c.ok
  c.terminal_bright_yellow  = c.warn
  c.terminal_bright_blue    = INFO_BRIGHT
  c.terminal_bright_magenta = c.potassium_bright
  c.terminal_bright_cyan    = c.hint
  c.terminal_bright_white   = c.fg

  return c
end

-- Default, for anything that wants a table without asking.
M.colors = M.get("hard")

return M
