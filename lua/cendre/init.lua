local M = {}

M.config = {
  -- "hard" | "medium" | "soft". The pigments never move, only the ground under
  -- them. Switch at runtime with :CendreBackground.
  background = "hard",
  -- The ash bed is a colour the theme derived, so it may as well be on screen.
  transparent = false,
  -- The window you are not in drops to bg_deep.
  dim_inactive = false,
  -- Italics on the text the editor adds around yours: inlay hints, ghost text,
  -- git blame, Noice virtual text, the dashboard footer. No syntax role is italic
  -- at any setting, since every role already keeps a real gap from the others.
  italic_virtual_text = false,
  italic_comments = true,
  on_colors = function(colors) end,
  on_highlights = function(highlights, colors) end,
}

-- Which switch each italic group answers to. Every family is listed, so a group
-- added later is classified on purpose rather than inheriting a switch whose name
-- does not describe it.
--
-- The comment family is wider than the three names a reader thinks of, because an
-- LSP attaching swaps Comment for @lsp.type.comment, and a comment that changes
-- shape when the server connects reads as a bug.
local ITALIC = {}
for _, name in ipairs({ "Italic", "@markup.italic" }) do
  ITALIC[name] = "markup"
end
for _, name in ipairs({
  "Comment", "SpecialComment", "@comment", "@comment.documentation",
  "@lsp.type.comment", "LspCodeLens", "@markup.quote",
}) do
  ITALIC[name] = "comment"
end
for _, name in ipairs({
  "LspInlayHint", "BlinkCmpGhostText", "GitSignsCurrentLineBlame",
  "NoiceVirtualText", "SnacksDashboardFooter",
}) do
  ITALIC[name] = "virtual"
end

--- Register :CendreBackground. Called from load() rather than setup(), because a
--- bare `colorscheme cendre` with no configuration is a supported way to install
--- this, and it should not be the way that silently loses the command.
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
  opts = vim.tbl_extend("force", {}, opts or {})

  -- `italic` never reached anything but virtual text, so it read as a master
  -- switch it never was. Removed in 2.0.
  if opts.italic ~= nil then
    vim.deprecate("cendre italic", "italic_virtual_text", "2.0.0", "cendre")
    if opts.italic_virtual_text == nil then
      opts.italic_virtual_text = opts.italic
    end
    opts.italic = nil
  end

  M.config = vim.tbl_deep_extend("force", M.config, opts)
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

  if M.config.dim_inactive then
    highlights.NormalNC.bg = c.bg_deep
  end

  if M.config.transparent then
    local strip = {
      "Normal", "NormalNC", "NormalFloat", "SignColumn", "FoldColumn",
      "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
      "WinSeparator", "VertSplit", "EndOfBuffer", "MsgArea",
      "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeWinSeparator", "NeoTreeEndOfBuffer",
      "NvimTreeNormal", "SnacksNormal", "SnacksNormalNC", "TroubleNormal",
      "DiffviewNormal", "TreesitterContext",
      -- stripped rather than dropped: a transparent float with no border has no
      -- edge, so the ground goes and the stroke stays as the groups declare it.
      "FloatBorder",
    }
    for _, name in ipairs(strip) do
      if highlights[name] then
        highlights[name].bg = "NONE"
      end
    end
  end

  -- Markup answers to neither switch: italic is the whole definition there, and a
  -- stripped one leaves an empty group, so *emphasis* would render as body text.
  for name, hl in pairs(highlights) do
    if hl.italic then
      local family = ITALIC[name]
      if family == "comment" then
        hl.italic = M.config.italic_comments
      elseif family == "virtual" then
        hl.italic = M.config.italic_virtual_text
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
