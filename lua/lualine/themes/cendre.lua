local ok, cendre = pcall(require, "cendre")
local c = require("cendre.palette").get(ok and cendre.config.background or "hard")

-- Mode colour tracks the semantic family, not the syntax pigments: the mode
-- block should never look like a token.
local cendre = {}

cendre.normal = {
  a = { fg = c.bg0, bg = c.ember, gui = "bold" },
  b = { fg = c.fg, bg = c.bg2 },
  c = { fg = c.fg_dim, bg = c.bg1 },
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
  a = { fg = c.gutter, bg = c.bg1 },
  b = { fg = c.gutter, bg = c.bg1 },
  c = { fg = c.gutter, bg = c.bg1 },
}

return cendre
