-- Smoke test for the Cendre colorscheme.
-- Run: nvim --headless --noplugin -u NONE -c "set rtp+=." -c "luafile test/smoke.lua"
-- Exits non-zero on failure (via :cquit) so CI catches it.

local failures = {}

local function check(name, fn)
  local ok, err = pcall(fn)
  if ok then
    print("ok   - " .. name)
  else
    print("FAIL - " .. name .. ": " .. tostring(err))
    table.insert(failures, name)
  end
end

local function reload()
  for _, mod in ipairs({
    "cendre", "cendre.palette", "cendre.extras", "cendre.groups.editor", "cendre.groups.syntax",
    "cendre.groups.treesitter", "cendre.groups.lsp", "cendre.groups.integrations",
    "lualine.themes.cendre",
  }) do
    package.loaded[mod] = nil
  end
end

local BACKGROUNDS = { "hard", "medium", "soft" }

-- Contrast helpers, so the palette's own claims are checked rather than trusted.
local function lin(v)
  v = v / 255
  return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
end
local function luminance(hex)
  local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
  assert(r, "not a hex colour: " .. tostring(hex))
  return 0.2126 * lin(tonumber(r, 16)) + 0.7152 * lin(tonumber(g, 16)) + 0.0722 * lin(tonumber(b, 16))
end
local function ratio(a, b)
  local la, lb = luminance(a), luminance(b)
  local hi, lo = math.max(la, lb), math.min(la, lb)
  return (hi + 0.05) / (lo + 0.05)
end

-- load() pushes every highlight through nvim_set_hl, which throws on a nil or
-- malformed colour. A clean load is therefore the core regression guard: any
-- group referencing a missing palette key blows up right here.
for _, bg in ipairs(BACKGROUNDS) do
  check("load background: " .. bg, function()
    reload()
    require("cendre").setup({ background = bg })
    require("cendre").load()
    assert(vim.g.colors_name == "cendre", "colors_name not set")
  end)
end

check("unknown background falls back to hard instead of erroring", function()
  reload()
  require("cendre").setup({ background = "nope" })
  require("cendre").load()
  local p = require("cendre.palette")
  assert(require("cendre").colors.bg0 == p.grounds.hard.bg0, "did not fall back")
end)

check("the default is the deepest ground, painted, matching the landing page", function()
  reload()
  require("cendre").setup({})
  require("cendre").load()
  assert(require("cendre").config.background == "hard", "default depth drifted from hard")
  assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == 0x171311,
    "Normal is not the hard ground, so either the default moved or transparent leaked")
end)

check("transparent = true strips Normal bg", function()
  reload()
  require("cendre").setup({ transparent = true })
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == nil, "Normal bg not stripped")
end)

check("transparent = true keeps the float border stroke", function()
  reload()
  require("cendre").setup({ transparent = true })
  require("cendre").load()
  local hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
  assert(hl.bg == nil, "FloatBorder bg not stripped")
  assert(hl.fg ~= nil, "FloatBorder lost its stroke")
end)

check("transparent = false keeps Normal bg", function()
  reload()
  require("cendre").setup({ background = "hard", transparent = false })
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == 0x171311, "Normal bg wrong")
end)

check("italic = false, italic_comments = true", function()
  reload()
  require("cendre").setup({ italic = false, italic_comments = true })
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "Comment" }).italic, "Comment lost its italic")
  assert(not vim.api.nvim_get_hl(0, { name = "@variable.parameter" }).italic,
    "parameter still italic")
end)

check("italic_comments = false kills every italic", function()
  reload()
  require("cendre").setup({ italic = false, italic_comments = false })
  require("cendre").load()
  assert(not vim.api.nvim_get_hl(0, { name = "Comment" }).italic, "Comment still italic")
end)

check("on_colors override", function()
  reload()
  require("cendre").setup({ on_colors = function(colors) colors.bg0 = "#000000" end })
  require("cendre").load()
end)

check("on_highlights override wins", function()
  reload()
  require("cendre").setup({
    transparent = false,
    on_highlights = function(hl, colors) hl.Normal = { fg = colors.fg, bg = "#000000" } end,
  })
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == 0x000000, "override not applied")
end)

check(":CendreBackground exists after a bare colorscheme, with no setup call", function()
  reload()
  vim.api.nvim_del_user_command("CendreBackground")
  -- no setup() here on purpose: installing without configuration is supported,
  -- and it used to be the path that silently lost the command
  vim.cmd("colorscheme cendre")
  local ok = pcall(vim.cmd, "CendreBackground soft")
  assert(ok, "the command is missing when the colorscheme is loaded without setup")
  assert(require("cendre").config.background == "soft", "the switch did not take")
end)

check(":CendreBackground switches the live ground", function()
  reload()
  require("cendre").setup({ background = "hard", transparent = false })
  require("cendre").load()
  vim.cmd("CendreBackground soft")
  local soft = require("cendre.palette").grounds.soft
  assert(require("cendre").colors.bg0 == soft.bg0, "background did not switch")
  assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == tonumber(soft.bg0:sub(2), 16),
    "highlights not reapplied")
end)

check(":CendreBackground rejects an unknown name without reloading", function()
  reload()
  require("cendre").setup({ background = "hard" })
  require("cendre").load()
  -- a bad argument should surface as a command error, so pcall it and check
  -- that the rejection left the config alone
  local ok = pcall(vim.cmd, "CendreBackground banana")
  assert(not ok, "an unknown background was accepted silently")
  assert(require("cendre").config.background == "hard", "config was clobbered")
end)

check("the pigments do not move with the background", function()
  reload()
  local p = require("cendre.palette")
  for _, bg in ipairs(BACKGROUNDS) do
    local c = p.get(bg)
    for name, hex in pairs(p.pigments) do
      assert(c[name] == hex, name .. " drifted on " .. bg)
    end
    for name, hex in pairs(p.ink) do
      assert(c[name] == hex, name .. " drifted on " .. bg)
    end
  end
end)

check("one role, one hue: no two pigments share a hex", function()
  reload()
  local seen = {}
  for name, hex in pairs(require("cendre.palette").pigments) do
    assert(not seen[hex], "duplicate pigment " .. hex .. " on " .. name .. " and " .. tostring(seen[hex]))
    seen[hex] = name
  end
end)

check("no pigment collides with a diagnostic colour", function()
  reload()
  local p = require("cendre.palette")
  for sname, shex in pairs(p.semantic) do
    for pname, phex in pairs(p.pigments) do
      assert(shex ~= phex, sname .. " and " .. pname .. " are the same colour")
    end
  end
end)

-- The published ratios. These are what the landing page claims, so they get
-- asserted rather than documented: change a hex and this test names the number
-- that has to be updated with it.
local EXPECTED = {
  hard = {
    fg = 12.89, fg_dim = 6.15, comment = 3.32, gutter = 2.00,
    brass = 10.97, ember = 8.13, sap = 7.65, cinder = 5.74, frost = 4.77,
    error = 4.76, warn = 8.82, ok = 6.80, hint = 9.03, info = 8.91,
  },
  medium = {
    fg = 12.18, fg_dim = 5.82, comment = 3.14, gutter = 1.89,
    brass = 10.37, ember = 7.68, sap = 7.23, cinder = 5.42, frost = 4.51,
    error = 4.50, warn = 8.33, ok = 6.43, hint = 8.54, info = 8.42,
  },
  soft = {
    fg = 11.41, fg_dim = 5.45, comment = 2.94, gutter = 1.77,
    brass = 9.71, ember = 7.19, sap = 6.77, cinder = 5.08, frost = 4.22,
    error = 4.21, warn = 7.81, ok = 6.02, hint = 8.00, info = 7.89,
  },
}

for _, bg in ipairs(BACKGROUNDS) do
  check("measured ratios match the published ones on " .. bg, function()
    reload()
    local c = require("cendre.palette").get(bg)
    for key, want in pairs(EXPECTED[bg]) do
      local got = ratio(c[key], c.bg0)
      assert(math.abs(got - want) < 0.02,
        string.format("%s is %.2f:1 on %s, page says %.2f:1", key, got, bg, want))
    end
  end)
end

-- Three colours sit under 4.5:1 on purpose and are flagged as such on the page.
-- Everything else clears AA on every depth.
local QUIET = { comment = true, frost = true, error = true }

for _, bg in ipairs(BACKGROUNDS) do
  check("everything not deliberately quiet clears 4.5:1 on " .. bg, function()
    reload()
    local p = require("cendre.palette")
    local c = p.get(bg)
    for _, set in ipairs({ p.ink, p.pigments, p.semantic }) do
      for key in pairs(set) do
        if key ~= "gutter" and not QUIET[key] then
          local r = ratio(c[key], c.bg0)
          assert(r >= 4.5, string.format("%s is %.2f:1 on %s, under the floor", key, r, bg))
        end
      end
    end
  end)

  check("comment stays quiet, and frost and error stay above 4.2 on " .. bg, function()
    reload()
    local c = require("cendre.palette").get(bg)
    local cm = ratio(c.comment, c.bg0)
    assert(cm < 4.5, string.format("comment is %.2f:1, no longer the quiet one", cm))
    assert(cm > 2.5, string.format("comment is %.2f:1, now unreadable", cm))
    for _, key in ipairs({ "frost", "error" }) do
      local r = ratio(c[key], c.bg0)
      assert(r >= 4.2, string.format("%s is %.2f:1 on %s, below the stated floor", key, r, bg))
    end
  end)

  check("terminal slots derive from the palette on " .. bg, function()
    reload()
    local c = require("cendre.palette").get(bg)
    assert(c.terminal_red == c.cinder, "ansi 1 drifted")
    assert(c.terminal_green == c.sap, "ansi 2 drifted")
    assert(c.terminal_yellow == c.brass, "ansi 3 drifted")
    assert(c.terminal_cyan == c.frost, "ansi 6 drifted")
    assert(c.terminal_bright_white == c.fg, "ansi 15 drifted")
    -- ANSI needs a sixth hue the editor never uses, so slot 5 is its own colour
    for _, key in ipairs({ "cinder", "ember", "brass", "sap", "frost" }) do
      assert(c.terminal_magenta ~= c[key], "ansi 5 collided with " .. key)
    end
  end)

  check("all 16 terminal slots are set on " .. bg, function()
    reload()
    local c = require("cendre.palette").get(bg)
    for _, key in ipairs({
      "terminal_black", "terminal_red", "terminal_green", "terminal_yellow",
      "terminal_blue", "terminal_magenta", "terminal_cyan", "terminal_white",
      "terminal_bright_black", "terminal_bright_red", "terminal_bright_green",
      "terminal_bright_yellow", "terminal_bright_blue", "terminal_bright_magenta",
      "terminal_bright_cyan", "terminal_bright_white",
    }) do
      assert(c[key] and c[key]:match("^#%x%x%x%x%x%x$"), key .. " is not a hex colour")
    end
  end)
end

check("the role map holds: every pigment lands where the page says", function()
  reload()
  require("cendre").setup({ background = "hard", italic = false })
  require("cendre").load()
  local c = require("cendre").colors
  local want = {
    ["@keyword"] = c.cinder,
    ["@function"] = c.brass,
    ["@function.call"] = c.brass,
    ["@type"] = c.frost,
    ["@constructor"] = c.frost,
    ["@string"] = c.sap,
    ["@number"] = c.sap,
    ["@boolean"] = c.sap,
    ["@property"] = c.ember,
    ["@field"] = c.ember,
    ["@variable.parameter"] = c.ember,
    -- a declared name is not a role
    ["@variable"] = c.fg,
    ["@constant"] = c.fg,
    -- punctuation is not a token
    ["@operator"] = c.fg_dim,
    ["@punctuation.bracket"] = c.fg_dim,
  }
  for group, hex in pairs(want) do
    local got = vim.api.nvim_get_hl(0, { name = group }).fg
    assert(got == tonumber(hex:sub(2), 16),
      string.format("%s is %s, expected %s", group, got and ("#%06x"):format(got) or "unset", hex))
  end
end)

check("nothing readable depends on bold or italic", function()
  reload()
  require("cendre").setup({ background = "hard", italic = false })
  require("cendre").load()
  for _, group in ipairs({
    "@keyword", "@function", "@type", "@string", "@number", "@property", "@variable",
  }) do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    assert(not hl.bold, group .. " leans on bold")
    assert(not hl.italic, group .. " leans on italic")
  end
end)

check("lualine theme follows the active background", function()
  reload()
  require("cendre").setup({ background = "soft" })
  require("cendre").load()
  package.loaded["lualine.themes.cendre"] = nil
  local theme = require("lualine.themes.cendre")
  assert(theme.normal.c.bg == require("cendre.palette").grounds.soft.bg1,
    "lualine still on the wrong ground")
end)

print(("-"):rep(52))
if #failures > 0 then
  print(#failures .. " failing: " .. table.concat(failures, ", "))
  vim.cmd("cquit")
else
  print("all checks passed")
  vim.cmd("quit")
end