local M = {}

M.config = {
  -- "hard" | "medium" | "soft". The pigments never move, only the ground under
  -- them. Switch at runtime with :CendreBackground.
  background = "hard",
  -- The ash bed is a colour the theme derived, so it may as well be on screen.
  transparent = false,
  -- Every role keeps a real gap from the others, so italics carry no
  -- information here. Off by default.
  italic = false,
  italic_comments = true,
  on_colors = function(colors) end,
  on_highlights = function(highlights, colors) end,
}

--- Register :CendreBackground. Called from load() rather than setup(), because a
--- bare `colorscheme cendre` with no configuration is a supported way to install
--- this, and it should not be the way that silently loses the command.
--- @return nil
local function register_command()
  vim.api.nvim_create_user_command("CendreBackground", function(o)
    local palette = require("cendre.palette")
    local name = o.args ~= "" and o.args or palette.default
    if not palette.grounds[name] then
      vim.notify("cendre: unknown background '" .. name .. "'", vim.log.levels.ERROR)
      return
    end
    M.config.background = name
    M.load()
    vim.notify("cendre: " .. name)
  end, {
    nargs = "?",
    desc = "Switch the cendre background depth",
    complete = function()
      return vim.deepcopy(require("cendre.palette").backgrounds)
    end,
  })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  register_command()
end

function M.load()
  register_command()

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.g.colors_name = "cendre"
  vim.o.termguicolors = true
  vim.o.background = "dark"

  local c = require("cendre.palette").get(M.config.background)
  M.config.on_colors(c)
  M.colors = c

  local highlights = {}
  for _, mod in ipairs({ "editor", "syntax", "treesitter", "lsp", "integrations" }) do
    highlights = vim.tbl_extend("force", highlights, require("cendre.groups." .. mod).get(c))
  end

  if M.config.transparent then
    local strip = {
      "Normal", "NormalNC", "NormalFloat", "SignColumn", "FoldColumn",
      "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
      "WinSeparator", "VertSplit", "EndOfBuffer", "MsgArea",
      "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeWinSeparator", "NeoTreeEndOfBuffer",
      "NvimTreeNormal", "SnacksNormal", "SnacksNormalNC", "TroubleNormal",
      "DiffviewNormal", "TreesitterContext",
    }
    for _, name in ipairs(strip) do
      if highlights[name] then
        highlights[name].bg = "NONE"
      end
    end
    -- keep the border stroke: a transparent float with no border has no edge
    highlights.FloatBorder = { fg = c.bg3, bg = "NONE" }
  end

  if not M.config.italic then
    for _, hl in pairs(highlights) do
      hl.italic = false
    end
    if M.config.italic_comments then
      for _, name in ipairs({ "Comment", "@comment", "@comment.documentation" }) do
        if highlights[name] then
          highlights[name].italic = true
        end
      end
    end
  elseif not M.config.italic_comments then
    for _, name in ipairs({ "Comment", "@comment", "@comment.documentation" }) do
      if highlights[name] then
        highlights[name].italic = false
      end
    end
  end

  M.config.on_highlights(highlights, c)

  for name, val in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, val)
  end

  for i, key in ipairs({
    "terminal_black", "terminal_red", "terminal_green", "terminal_yellow",
    "terminal_blue", "terminal_magenta", "terminal_cyan", "terminal_white",
    "terminal_bright_black", "terminal_bright_red", "terminal_bright_green",
    "terminal_bright_yellow", "terminal_bright_blue", "terminal_bright_magenta",
    "terminal_bright_cyan", "terminal_bright_white",
  }) do
    vim.g["terminal_color_" .. (i - 1)] = c[key]
  end
end

return M
