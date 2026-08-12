local ok, mod = pcall(require, "cendre")
local c = require("cendre.palette").get(ok and mod.config.background or "hard")
local ground = (ok and mod.config.transparent) and "NONE" or c.bg2

-- Mode colour tracks the semantic family, not the syntax pigments: the mode
-- block should never look like a token.
local cendre = {}

-- One ground for the whole bar, bg2, which is what this theme's own StatusLine
-- group is set to: a lualine section painted in bg1 would contradict the
-- statusline every other Neovim surface draws. Sections separate by ink weight,
-- fg against fg_dim, and the mode block is the only fill. Under `transparent`
-- that ground drops out, the same way StatusLine does, or the bar paints a slab
-- everywhere its components reach and leaves holes everywhere they do not.
cendre.normal = {
  a = { fg = c.bg0, bg = c.ember, gui = "bold" },
  b = { fg = c.fg, bg = ground },
  c = { fg = c.fg_dim, bg = ground },
}

cendre.insert = {
  a = { fg = c.bg0, bg = c.ok, gui = "bold" },
}

cendre.visual = {
  a = { fg = c.bg0, bg = c.info, gui = "bold" },
}

cendre.replace = {
  a = { fg = c.bg0, bg = c.error, gui = "bold" },
}

cendre.command = {
  a = { fg = c.bg0, bg = c.brass, gui = "bold" },
}

cendre.terminal = {
  a = { fg = c.bg0, bg = c.hint, gui = "bold" },
}

cendre.inactive = {
  a = { fg = c.gutter, bg = ground },
  b = { fg = c.gutter, bg = ground },
  c = { fg = c.gutter, bg = ground },
}

return cendre
