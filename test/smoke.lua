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

-- Same matrices as derive.lua, which comes at OKLCH from the other end, wavelengths.
local SRGB_XYZ = { { 0.4123907993, 0.3575843394, 0.1804807884 },
                   { 0.2126390059, 0.7151686788, 0.0721923154 },
                   { 0.0193308187, 0.1191947798, 0.9505321522 } }
local XYZ_LMS = { { 0.8189330101, 0.3618667424, -0.1288597137 },
                  { 0.0329845436, 0.9293118715,  0.0361456387 },
                  { 0.0482003018, 0.2643662691,  0.6338517070 } }
local LMS_LAB = { { 0.2104542553,  0.7936177850, -0.0040720468 },
                  { 1.9779984951, -2.4285922050,  0.4505937099 },
                  { 0.0259040371,  0.7827717662, -0.8086757660 } }

local function mul(M, v)
  local o = {}
  for i = 1, 3 do
    o[i] = M[i][1] * v[1] + M[i][2] * v[2] + M[i][3] * v[3]
  end
  return o
end

local atan2 = math.atan2 or math.atan

--- @return number lightness, number chroma, number hue in degrees
local function oklch(hex)
  local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
  assert(r, "not a hex colour: " .. tostring(hex))
  local lms = mul(XYZ_LMS, mul(SRGB_XYZ, { lin(tonumber(r, 16)), lin(tonumber(g, 16)), lin(tonumber(b, 16)) }))
  for i = 1, 3 do
    local c = lms[i]
    lms[i] = c < 0 and -((-c) ^ (1 / 3)) or c ^ (1 / 3)
  end
  local lab = mul(LMS_LAB, lms)
  local L, a, bb = lab[1], lab[2], lab[3]
  return L, math.sqrt(a * a + bb * bb), atan2(bb, a) * 180 / math.pi % 360
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

check("dim_inactive is off unless asked, so a split does not move on its own", function()
  reload()
  require("cendre").setup({})
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "NormalNC" }).bg
      == vim.api.nvim_get_hl(0, { name = "Normal" }).bg,
    "NormalNC left the editor ground without being asked")
end)

check("dim_inactive = true drops NormalNC to bg_deep at every depth", function()
  for _, bg in ipairs(BACKGROUNDS) do
    reload()
    require("cendre").setup({ background = bg, dim_inactive = true })
    require("cendre").load()
    local want = tonumber(require("cendre.palette").grounds[bg].bg_deep:sub(2), 16)
    assert(vim.api.nvim_get_hl(0, { name = "NormalNC" }).bg == want,
      ("NormalNC on %s is not bg_deep"):format(bg))
    assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg
        == tonumber(require("cendre.palette").grounds[bg].bg0:sub(2), 16),
      ("dim_inactive moved the active window on %s"):format(bg))
  end
end)

check("transparent = true outranks dim_inactive", function()
  reload()
  require("cendre").setup({ transparent = true, dim_inactive = true })
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "NormalNC" }).bg == nil,
    "dim_inactive repainted a ground transparent = true is meant to strip")
end)

check("every float edge is the same stroke", function()
  reload()
  local c = require("cendre.palette").get("hard")
  local built = {}
  for _, mod in ipairs({ "editor", "syntax", "treesitter", "lsp", "integrations" }) do
    for name, hl in pairs(require("cendre.groups." .. mod).get(c)) do built[name] = hl end
  end

  -- A border on the float ground is the generic float edge and takes one colour.
  -- Noice's accent borders set no background, so they stay out by construction.
  local want = built.FloatBorder.fg
  for name, hl in pairs(built) do
    if name:match("Border$") and hl.bg == c.bg_deep then
      assert(hl.fg == want,
        ("%s strokes %s where FloatBorder strokes %s"):format(name, tostring(hl.fg), tostring(want)))
    end
  end
end)

check("transparent = true keeps the float border stroke", function()
  reload()
  require("cendre").setup({ transparent = true })
  require("cendre").load()
  local hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
  assert(hl.bg == nil, "FloatBorder bg not stripped")
  assert(hl.fg ~= nil, "FloatBorder lost its stroke")

  -- And it is the same stroke, not a second one: stripping the ground is the only
  -- thing transparency is allowed to do to an edge.
  local c = require("cendre.palette").get("hard")
  local want = require("cendre.groups.editor").get(c).FloatBorder.fg
  assert(("#%06x"):format(hl.fg) == want,
    ("transparent strokes #%06x where the theme strokes %s"):format(hl.fg, want))
end)

check("no group repeats a float surface, so plugin windows can inherit it", function()
  reload()
  local c = require("cendre.palette").get("hard")
  local built = {}
  for _, mod in ipairs({ "editor", "syntax", "treesitter", "lsp", "integrations" }) do
    for name, hl in pairs(require("cendre.groups." .. mod).get(c)) do built[name] = hl end
  end

  -- A group that copies NormalFloat or FloatBorder renders identically and buys
  -- nothing, because every plugin already links its window to those two. What it
  -- does buy is a pinned colour, which `transparent = true` cannot strip: that is
  -- what used to leave which-key, the Snacks picker, Noice and fzf-lua opaque over
  -- the terminal. Colour the two surfaces, and the windows follow.
  local function signature(hl)
    local parts = {}
    for _, key in ipairs({ "fg", "bg", "sp", "bold", "italic", "underline", "reverse" }) do
      if hl[key] ~= nil then
        parts[#parts + 1] = key .. "=" .. tostring(hl[key])
      end
    end
    return table.concat(parts, " ")
  end

  local surfaces = { NormalFloat = true, FloatBorder = true }
  -- these two carry bg_deep against a bg0 fallback, so they say something the
  -- surface groups do not
  -- Pmenu is the documented transparency exception: the completion menu stays
  -- painted because a transparent popup over code is not readable, so it is meant
  -- to look like NormalFloat and meant to pin that colour.
  local allowed = {
    SnacksNormal = true, SnacksNormalNC = true, NeoTreeWinSeparator = true,
    Pmenu = true, PmenuBorder = true,
    -- blink's windows read none of the float surfaces, so they have to pin their own
    BlinkCmpMenu = true, BlinkCmpMenuBorder = true,
    BlinkCmpDoc = true, BlinkCmpDocBorder = true,
    BlinkCmpSignatureHelp = true, BlinkCmpSignatureHelpBorder = true,
  }
  for name, hl in pairs(built) do
    if not surfaces[name] and not allowed[name] then
      for surface in pairs(surfaces) do
        assert(signature(hl) ~= signature(built[surface]),
          name .. " is a verbatim copy of " .. surface ..
          ", which pins a colour transparent = true then cannot strip")
      end
    end
  end
end)

check("transparent = true leaves no window surface painted", function()
  reload()
  require("cendre").setup({ transparent = true })
  require("cendre").load()
  local c = require("cendre.palette").get("hard")
  local grounds = {}
  for _, key in ipairs({ "bg_deep", "bg0" }) do
    grounds[tonumber(c[key]:sub(2), 16)] = key
  end

  -- Anything a plugin points a window at ends in one of these. A ground colour
  -- surviving here means the reader asked to see their terminal and got a panel.
  -- The completion menu is the documented exception, borders included.
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.bg and grounds[hl.bg] and not name:match("^BlinkCmp") and name ~= "PmenuBorder"
       and (name:match("Normal$") or name:match("NormalNC$") or name:match("Float$")
       or name:match("Border$") or name:match("Popup$") or name:match("Cmdline$")) then
      error(name .. " still paints " .. grounds[hl.bg] .. " under transparent = true")
    end
  end
end)

check("transparent = false keeps Normal bg", function()
  reload()
  require("cendre").setup({ background = "hard", transparent = false })
  require("cendre").load()
  assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == 0x171311, "Normal bg wrong")
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
  require("cendre").setup({ background = "hard", italic_virtual_text = false })
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

check("a group drawn over a painted block reads against that block", function()
  reload()
  local c = require("cendre.palette").get("hard")
  local built = {}
  for _, mod in ipairs({ "editor", "syntax", "treesitter", "lsp", "integrations" }) do
    for name, hl in pairs(require("cendre.groups." .. mod).get(c)) do built[name] = hl end
  end

  -- A foreground-only group stacked over a block another group already painted
  -- never meets the editor ground, so nothing else here measures it.
  local overlays = {
    { "LazySpecial", { "LazyButtonActive", "LazyButton" } },
  }

  for _, pair in ipairs(overlays) do
    local over = built[pair[1]]
    assert(over and over.fg, pair[1] .. " has no foreground to check")
    assert(not over.bg, pair[1] .. " carries a background, so it is not an overlay any more")

    for _, name in ipairs(pair[2]) do
      local under = built[name]
      assert(under and under.bg, name .. " has no background to read against")
      local r = ratio(over.fg, under.bg)
      assert(r >= 4.5, string.format(
        "%s is %.2f:1 over %s, which is the ratio a reader actually gets",
        pair[1], r, name))
    end
  end
end)

check("nothing readable depends on bold or italic", function()
  reload()
  require("cendre").setup({ background = "hard", italic_virtual_text = false })
  require("cendre").load()
  for _, group in ipairs({
    "@keyword", "@function", "@type", "@string", "@number", "@property", "@variable",
  }) do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    assert(not hl.bold, group .. " leans on bold")
    assert(not hl.italic, group .. " leans on italic")
  end
end)

-- One group per family, so the four rows the README prints are a contract.
check("the italic switches do what the options table says", function()
  local MATRIX = {
    -- italic_virtual_text, italic_comments, comment, virtual text, markup
    { false, true, true, false, true },
    { false, false, false, false, true },
    { true, true, true, true, true },
    { true, false, false, true, true },
  }

  for _, row in ipairs(MATRIX) do
    local virtual_text, italic_comments, comment, virtual, markup = row[1], row[2], row[3], row[4], row[5]
    reload()
    require("cendre").setup({
      background = "hard",
      italic_virtual_text = virtual_text,
      italic_comments = italic_comments,
    })
    require("cendre").load()

    local function is_italic(group)
      return vim.api.nvim_get_hl(0, { name = group }).italic == true
    end
    local function want(group, expected, why)
      assert(is_italic(group) == expected,
        ("italic_virtual_text=%s italic_comments=%s: %s is %s, %s"):format(
          virtual_text, italic_comments, group, tostring(is_italic(group)), why))
    end

    want("Comment", comment, "comments follow italic_comments")
    want("@lsp.type.comment", comment, "an LSP attaching must not reshape a comment")
    want("SpecialComment", comment, "a special comment is still a comment")
    want("LspInlayHint", virtual, "virtual text follows italic")
    want("BlinkCmpGhostText", virtual, "ghost text is virtual text")
    want("Italic", markup, "this group carries no fg: stripped, it means nothing")
    want("@markup.italic", markup, "*emphasis* has to stay emphasised")
  end
end)

check("the old italic option still works, and says it is going away", function()
  reload()
  local told
  local real = vim.deprecate
  vim.deprecate = function(name, alternative, version)
    told = { name = name, alternative = alternative, version = version }
  end
  require("cendre").setup({ background = "hard", italic = true })
  vim.deprecate = real
  require("cendre").load()

  assert(told, "setting italic said nothing about the rename")
  assert(told.alternative == "italic_virtual_text",
    "pointed at " .. tostring(told.alternative) .. " instead of italic_virtual_text")
  assert(told.version == "2.0.0", "a deprecation without a removal version is not a promise")
  assert(vim.api.nvim_get_hl(0, { name = "LspInlayHint" }).italic == true,
    "italic = true no longer reaches virtual text")
end)

check("every surface ships at all three depths", function()
  reload()
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()
  -- Counted per theme name rather than per directory, because a directory can
  -- also hold something that is not a depth: Zed lists an extension once and its
  -- themes inside it, so extras/zed carries a manifest beside its three themes.
  local surfaces, depths = {}, {}
  for path in pairs(files) do
    local dir = path:match("^extras/([^/]+)/")
    if dir then
      surfaces[dir] = true
      local stem = path:match("cendre%-?(%a*)")
      if stem == "" or stem == "medium" or stem == "soft" then
        depths[dir] = (depths[dir] or 0) + 1
      end
    end
  end
  local n = 0
  for dir in pairs(surfaces) do
    n = n + 1
    assert(depths[dir] and depths[dir] % 3 == 0,
      string.format("%s has %s depth files, not a multiple of three",
        dir, tostring(depths[dir])))
  end
  assert(n >= 24, n .. " surfaces under extras/, expected at least 24")
end)

check("no two depths of one surface share a theme name", function()
  reload()
  local palette = require("cendre.palette")
  local seen = {}
  for _, bg in ipairs(palette.backgrounds) do
    local name = palette.name(bg)
    assert(not seen[name], "two depths resolve to the name " .. name)
    seen[name] = bg
  end
  -- and the name has to appear in the files that store one rather than deriving
  -- it from their filename, or installing two depths collides on one entry
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()
  for _, bg in ipairs(palette.backgrounds) do
    local name = palette.name(bg)
    local suffix = bg == palette.default and "" or ("-" .. bg)
    for _, target in ipairs({
      "extras/zed/themes/cendre%s.json",
      "extras/wezterm/cendre%s.toml",
      "extras/bat/cendre%s.tmTheme",
      "extras/hunk/cendre%s.toml",
      "extras/vim/cendre%s.vim",
      "extras/obsidian/cendre%s/manifest.json",
      "extras/firefox/cendre%s/manifest.json",
      "extras/tmux/cendre%s.tokyo-night.sh",
    }) do
      local path = target:format(suffix)
      local body = files[path]
      assert(body, "missing " .. path)
      assert(body:find(name, 1, true), path .. " does not carry the name " .. name)
    end
  end
end)

check("the tmux plugin theme is mapped by role, not by ANSI name", function()
  reload()
  local palette = require("cendre.palette")
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- These four keys carry ANSI names the plugin does not honour: it paints its own
  -- statusbar with them and never program output. Aligning them back to their names
  -- reads as a cleanup and costs contrast, so the intent is pinned here rather than
  -- left to a comment nobody has to obey.
  for _, bg in ipairs(palette.backgrounds) do
    local c = palette.get(bg)
    local suffix = bg == palette.default and "" or ("-" .. bg)
    local path = ("extras/tmux/cendre%s.tokyo-night.sh"):format(suffix)
    local body = files[path]
    assert(body, "missing " .. path)

    for key, want in pairs({
      blue = c.ember,     -- the plugin's accent
      bblack = c.bg4,     -- a block background, and it has to mark a state
      black = c.gutter,   -- read as a foreground
      white = c.fg,       -- the bright ink
      bwhite = c.fg_dim,  -- the dim ink
    }) do
      local got = body:match('%["' .. key .. '"%]="(#%x+)"')
      assert(got == want,
        ("%s maps %s to %s, expected %s"):format(path, key, tostring(got), want))
    end
  end
end)

check("no group Neovim ships keeps a colour the palette does not define", function()
  reload()
  require("cendre").setup({})
  require("cendre").load()

  local palette = require("cendre.palette")
  local known = {}
  for _, bg in ipairs(palette.backgrounds) do
    for _, v in pairs(palette.get(bg)) do
      if type(v) == "string" and v:match("^#%x%x%x%x%x%x$") then known[v:lower()] = true end
    end
  end

  -- Neovim defines a handful of groups with colours of its own, and a theme that
  -- names none of them leaves them on screen: Added, Removed and Changed are what
  -- @diff.plus, @diff.minus, @diff.delta and PreInsert link to, and vim.pack and
  -- mini.deps paint with. Only the internal error and the redraw debug surfaces
  -- are left alone, since they have to stay readable when the theme is the bug.
  local theirs = { NvimInternalError = true }

  local checked = 0
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if not theirs[name] and not name:match("^RedrawDebug") then
      for _, key in ipairs({ "fg", "bg", "sp" }) do
        if type(hl[key]) == "number" then
          checked = checked + 1
          assert(known[("#%06x"):format(hl[key])],
            ("%s sets %s to #%06x, which the palette does not define"):format(name, key, hl[key]))
        end
      end
    end
  end
  assert(checked > 300, "only " .. checked .. " colours checked, expected hundreds")
end)

check("no generated file carries a colour the palette does not define", function()
  reload()
  local palette = require("cendre.palette")
  local known = {}
  for _, bg in ipairs(palette.backgrounds) do
    for _, v in pairs(palette.get(bg)) do
      if type(v) == "string" and v:match("^#%x%x%x%x%x%x$") then known[v:lower()] = true end
    end
  end

  -- The drift check compares every file to a fresh render, so a colour written
  -- into a generator by hand matches itself and passes. This is the check that
  -- does not: one source of truth means the palette, not the palette plus
  -- whatever a template happened to hardcode.
  package.loaded["cendre.extras"] = nil
  local checked = 0
  for path, body in pairs(require("cendre.extras").files()) do
    for hex in body:gmatch("#(%x+)") do
      -- Zed writes eight digits, the last two being alpha. A fully transparent
      -- value has no colour to be wrong about.
      local rgb = #hex == 8 and hex:sub(7) ~= "00" and hex:sub(1, 6) or (#hex == 6 and hex)
      if rgb then
        checked = checked + 1
        assert(known["#" .. rgb:lower()],
          path .. " carries #" .. rgb .. ", which is not in the palette")
      end
    end
  end
  assert(checked > 2000, "only " .. checked .. " colours checked, expected thousands")
end)

check("the opencode theme fills every colour its Theme type declares", function()
  reload()
  local palette = require("cendre.palette")
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- Every RGBA field of the Theme type in opencode's tui package. Its ThemeJson
  -- requires all of them but two, and the two exceptions fall back rather than
  -- fail, so a gap here is invisible: the selected row's text silently becomes
  -- the background and the menu silently becomes backgroundElement. The
  -- published documentation lists neither, which is how both were missed.
  local slots = {
    "primary", "secondary", "accent", "error", "warning", "success", "info",
    "text", "textMuted", "selectedListItemText", "background", "backgroundPanel",
    "backgroundElement", "backgroundMenu", "border", "borderActive", "borderSubtle",
    "diffAdded", "diffRemoved", "diffContext", "diffHunkHeader",
    "diffHighlightAdded", "diffHighlightRemoved", "diffAddedBg", "diffRemovedBg",
    "diffContextBg", "diffLineNumber", "diffAddedLineNumberBg",
    "diffRemovedLineNumberBg", "markdownText", "markdownHeading", "markdownLink",
    "markdownLinkText", "markdownCode", "markdownBlockQuote", "markdownEmph",
    "markdownStrong", "markdownHorizontalRule", "markdownListItem",
    "markdownListEnumeration", "markdownImage", "markdownImageText",
    "markdownCodeBlock", "syntaxComment", "syntaxKeyword", "syntaxFunction",
    "syntaxVariable", "syntaxString", "syntaxNumber", "syntaxType",
    "syntaxOperator", "syntaxPunctuation",
  }

  for _, bg in ipairs(palette.backgrounds) do
    local suffix = bg == palette.default and "" or ("-" .. bg)
    local path = ("extras/opencode/cendre%s.json"):format(suffix)
    local body = files[path]
    assert(body, "missing " .. path)

    local names, defs = {}, {}
    for name in body:match('"defs": {(.-)\n  }'):gmatch('"([%w]+)":') do
      defs[name] = true
    end
    for name, ref in body:match('"theme": {(.-)\n  }'):gmatch('"([%w]+)": "([^"]+)"') do
      names[name] = true
      -- Every value is a def name here, never a literal, so a typo would resolve
      -- to nothing and opencode would throw at load rather than at review.
      assert(defs[ref], path .. " points " .. name .. " at " .. ref .. ", which is not a def")
    end

    for _, slot in ipairs(slots) do
      assert(names[slot], path .. " leaves " .. slot .. " to opencode's fallback")
    end

    -- The two diff grounds are opposite states and used to share one colour
    local added = body:match('"diffAddedBg": "([^"]+)"')
    local removed = body:match('"diffRemovedBg": "([^"]+)"')
    assert(added ~= removed,
      path .. " gives added and removed rows the same ground, " .. tostring(added))
  end
end)

check("every scope Zed's grammars emit resolves to the hue Neovim gives it", function()
  reload()
  local palette = require("cendre.palette")
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- Captures from crates/grammars/src/*/highlights.scm in zed-industries/zed, each
  -- paired with the palette token its Neovim counterpart takes. Zed resolves a
  -- capture to the longest key in the theme that is a dotted prefix of it and falls
  -- through to editor.foreground when nothing matches, so a scope this theme never
  -- names is body text rather than a gap anybody would see.
  local scopes = {
    ["constant.builtin"]      = "sap",
    ["namespace"]             = "frost",
    ["module"]                = "frost",
    ["concept"]               = "frost",
    ["type.unit"]             = "frost",
    ["selector.class"]        = "cinder",
    ["selector.id"]           = "cinder",
    ["selector.pseudo"]       = "cinder",
    ["lifetime"]              = "cinder",
    ["keyword.operator"]      = "cinder",
    ["diff.plus"]             = "ok",
    ["diff.minus"]            = "error",
    ["diff.delta"]            = "info",
    ["diff.delta.moved"]      = "info",
    ["markup.heading"]        = "ember",
    ["title.markup"]          = "ember",
    ["markup.link.url"]       = "comment",
    ["link_uri.markup"]       = "comment",
    ["variable.other.member"] = "ember",
    ["attribute.jsx"]         = "ember",
    ["property.json_key"]     = "ember",
    ["punctuation.markup"]    = "fg_dim",
    ["text.literal.markup"]   = "sap",
    ["function.method.call"]  = "brass",
  }

  for _, bg in ipairs(palette.backgrounds) do
    local c = palette.get(bg)
    local suffix = bg == palette.default and "" or ("-" .. bg)
    local path = ("extras/zed/themes/cendre%s.json"):format(suffix)
    local body = assert(files[path], "missing " .. path)
    local syntax = vim.json.decode(body).themes[1].style.syntax

    for scope, token in pairs(scopes) do
      local matched
      for key in pairs(syntax) do
        if scope == key or scope:sub(1, #key + 1) == key .. "." then
          if not matched or #key > #matched then matched = key end
        end
      end
      assert(matched, path .. " names no prefix of " .. scope ..
        ", so Zed paints it in editor.foreground")
      assert(syntax[matched].color == c[token] .. "ff",
        ("%s resolves %s through %s to %s, where Neovim gives it %s (%s)"):format(
          path, scope, matched, syntax[matched].color, token, c[token]))
    end

    for _, scope in ipairs({ "title", "markup.heading", "emphasis.strong" }) do
      assert(syntax[scope].font_weight == 700,
        path .. " leaves " .. scope .. " at normal weight, where Neovim bolds it")
    end
    assert(syntax["emphasis"].font_style == "italic",
      path .. " drops the italic that is the whole definition of @markup.italic")
  end
end)

check("the hunk theme fills every slot hunk reads, and none it does not", function()
  reload()
  local palette = require("cendre.palette")
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- CUSTOM_THEME_COLOR_KEYS in hunk's config parser, which is the whole list and
  -- the same at the released version as on its main branch. The parser iterates
  -- that constant, so anything else is dropped without a word: this file used to
  -- write added, removed, context and lineNumber, none of which it reads.
  local slots = {
    "background", "panel", "panelAlt", "border", "accent", "accentMuted", "text",
    "muted", "addedBg", "removedBg", "movedAddedBg", "movedRemovedBg", "contextBg",
    "addedContentBg", "removedContentBg", "contextContentBg", "addedSignColor",
    "removedSignColor", "lineNumberBg", "lineNumberFg", "selectedHunk",
    "badgeAdded", "badgeRemoved", "badgeNeutral", "fileNew", "fileDeleted",
    "fileRenamed", "fileModified", "fileUntracked", "noteBorder", "noteBackground",
    "noteTitleBackground", "noteTitleText",
  }
  local retired = { "\nadded ", "\nremoved ", "\ncontext ", "\nlineNumber " }

  for _, bg in ipairs(palette.backgrounds) do
    local suffix = bg == palette.default and "" or ("-" .. bg)
    local path = ("extras/hunk/cendre%s.toml"):format(suffix)
    local body = files[path]
    assert(body, "missing " .. path)

    for _, slot in ipairs(slots) do
      assert(body:find("\n" .. slot .. " ", 1, true) or body:find("\n" .. slot .. "=", 1, true),
        path .. " leaves " .. slot .. " to the base theme")
    end

    -- The four that only looked like keys. Matched with the trailing space that
    -- the alignment gives them, so addedBg and removedBg do not answer for them.
    for _, name in ipairs(retired) do
      assert(not body:find(name, 1, true),
        path .. " still writes " .. name:gsub("\n", ""):gsub(" ", "") .. ", which hunk never reads")
    end

    -- Both syntax tables, which is the migration shape hunk documents: the
    -- released version reads only the roles, its successor prefers the scopes.
    assert(body:find("[custom_theme.syntax]", 1, true), path .. " has no role table")
    assert(body:find("[custom_theme.syntax_scopes]", 1, true), path .. " has no scope table")
  end
end)

check("the kde scheme carries the sections plasma reads", function()
  reload()
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- Taken from BreezeDark.colors, which KDE ships. Every Colors: section reads the
  -- same twelve keys, and a missing one falls back to a Breeze default.
  local sections = {
    "Colors:Button", "Colors:Complementary", "Colors:Header", "Colors:Header%]%[Inactive",
    "Colors:Selection", "Colors:Tooltip", "Colors:View", "Colors:Window",
  }
  local keys = {
    "BackgroundAlternate", "BackgroundNormal", "DecorationFocus", "DecorationHover",
    "ForegroundActive", "ForegroundInactive", "ForegroundLink", "ForegroundNegative",
    "ForegroundNeutral", "ForegroundNormal", "ForegroundPositive", "ForegroundVisited",
  }

  for path, body in pairs(files) do
    if path:match("%.colors$") then
      for _, section in ipairs(sections) do
        local block = body:match("%[" .. section .. "%]\n(.-)\n\n")
        assert(block, path .. " has no [" .. section:gsub("%%", "") .. "]")
        for _, key in ipairs(keys) do
          assert(block:match(key .. "=%d+,%d+,%d+"),
            path .. " is missing " .. key .. " in " .. section:gsub("%%", ""))
        end
      end

      for _, key in ipairs({ "activeBackground", "activeForeground", "inactiveForeground" }) do
        assert(body:match(key .. "=%d+,%d+,%d+"), path .. " has no [WM] " .. key)
      end

      -- Hover and focus are fills, not strokes, and keep ForegroundNormal on them.
      for _, section in ipairs(sections) do
        local block = body:match("%[" .. section .. "%]\n(.-)\n\n")
        local function triplet(key)
          local r, g, b = block:match(key .. "=(%d+),(%d+),(%d+)")
          return ("#%02x%02x%02x"):format(tonumber(r), tonumber(g), tonumber(b))
        end
        local ink = triplet("ForegroundNormal")
        for _, fill in ipairs({ "DecorationHover", "DecorationFocus" }) do
          local got = ratio(ink, triplet(fill))
          assert(got >= 4.5, ("%s: ForegroundNormal is %.2f:1 on %s in %s"):format(
            path, got, fill, section:gsub("%%", "")))
        end
      end

      local name = path:match("([%w%-]+)%.colors$")
      assert(body:find("ColorScheme=" .. name .. "\n", 1, true),
        path .. " does not name itself in [General]")
    end
  end
end)

check("the konsole scheme carries the sections konsole ships", function()
  reload()
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- Taken from Breeze.colorscheme, which Konsole ships. Nobody here runs KDE, so
  -- the shape is held to KDE's own file rather than to what a reader assumes.
  local bases = { "Background", "Foreground" }
  for i = 0, 7 do
    table.insert(bases, "Color" .. i)
  end
  local want = { General = true }
  for _, base in ipairs(bases) do
    want[base] = true
    want[base .. "Faint"] = true
    want[base .. "Intense"] = true
  end

  for path, body in pairs(files) do
    if path:match("konsole") then
      local seen = {}
      for name in body:gmatch("%[([%w]+)%]") do
        seen[name] = true
      end
      for name in pairs(want) do
        assert(seen[name], path .. " has no [" .. name .. "]")
      end
      for name in pairs(seen) do
        assert(want[name], path .. " invents [" .. name .. "]")
      end

      -- KConfig wants three decimals, and a hex slipping through would apply nothing
      for line in body:gmatch("Color=([^\n]+)") do
        local r, g, b = line:match("^(%d+),(%d+),(%d+)$")
        assert(r, path .. " has a colour that is not a decimal triplet: " .. line)
        for _, v in ipairs({ r, g, b }) do
          assert(tonumber(v) <= 255, path .. " has a channel over 255: " .. line)
        end
      end

      -- two depths under one Description collide on a single entry in Konsole's list
      local name = path:match("([%w%-]+)%.colorscheme$")
      assert(body:find("Description=" .. name .. "\n", 1, true),
        path .. " does not name itself in [General]")
    end
  end
end)

check("the yazi theme uses section and key names yazi still knows", function()
  reload()
  local palette = require("cendre.palette")
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()

  -- Taken from yazi's own preset theme. It renamed [manager] to [mgr] and
  -- [select] to [pick], and moved the tab, mode and hovered keys out into
  -- [tabs], [mode] and [indicator]. An unknown section is ignored rather than
  -- refused, so the retired spelling applied nothing and said nothing.
  local sections = {
    flavor = true, app = true, mgr = true, tabs = true, mode = true,
    indicator = true, status = true, which = true, confirm = true, spot = true,
    notify = true, pick = true, input = true, cmp = true, tasks = true,
    help = true, filetype = true,
  }
  -- Only names that are retired everywhere. `hovered` is not among them: it left
  -- [mgr] but is still a key of [tasks] and [help], and a bare match would fail
  -- on the two that are right. Its sibling preview_hovered covers the case.
  local retired = {
    "%[manager%]", "%[select%]", "preview_hovered",
    "tab_active", "tab_inactive", "mode_normal", "mode_select", "mode_unset",
    "separator_open", "separator_close",
  }

  for _, bg in ipairs(palette.backgrounds) do
    local suffix = bg == palette.default and "" or ("-" .. bg)
    local path = ("extras/yazi/cendre%s.toml"):format(suffix)
    local body = files[path]
    assert(body, "missing " .. path)

    local seen = 0
    for name in body:gmatch("\n%[([a-z]+)%]") do
      assert(sections[name], path .. " writes [" .. name .. "], which yazi does not read")
      seen = seen + 1
    end
    assert(seen >= 15, path .. " covers only " .. seen .. " sections")

    for _, pattern in ipairs(retired) do
      assert(not body:find(pattern),
        path .. " still writes " .. pattern:gsub("%%", "") .. ", retired by yazi")
    end
  end
end)

check("the committed extras match a fresh render of the palette", function()
  reload()
  package.loaded["cendre.extras"] = nil
  local files = require("cendre.extras").files()
  local n = 0
  for path, want in pairs(files) do
    local fd = io.open(path, "r")
    assert(fd, path .. " is missing, run scripts/extras.lua")
    local got = fd:read("*a")
    fd:close()
    assert(got == want, path .. " is stale, run scripts/extras.lua")
    n = n + 1
  end
  assert(n > 0, "no extras were rendered at all")
end)

check("the landing page carries the same palette as the module", function()
  local page = io.open("docs/index.html", "r")
  assert(page, "docs/index.html is missing")
  local html = page:read("*a")
  page:close()

  -- The page keeps its own copy of the palette, in the stylesheet and again in
  -- its data tables, because it has to render without Lua. Nothing structural
  -- stops those from drifting from the module, so it is asserted here instead.
  local palette = require("cendre.palette")
  local checked = 0
  local function must(hex, what)
    checked = checked + 1
    assert(html:lower():find(hex:lower(), 1, true),
      ("%s is %s in the palette but absent from docs/index.html"):format(what, hex))
  end

  for name, hex in pairs(palette.ink) do must(hex, "ink." .. name) end
  for name, hex in pairs(palette.pigments) do must(hex, name) end
  for name, hex in pairs(palette.semantic) do must(hex, name) end
  for _, bg in ipairs(palette.backgrounds) do
    for name, hex in pairs(palette.grounds[bg]) do must(hex, bg .. "." .. name) end
    for name, hex in pairs(palette.tints[bg]) do must(hex, bg .. ".tint." .. name) end
  end
  -- the three terminal-only slots are in both places too, so they are asserted
  -- rather than assumed to have been kept in step
  for _, hex in ipairs({ "#9480ba", "#a692cd", "#8bcfff" }) do
    must(hex, "terminal-only slot")
  end
  assert(checked >= 40, "only " .. checked .. " values cross-checked")
end)

check("every path the landing page tells a reader to copy exists", function()
  local page = io.open("docs/index.html", "r")
  assert(page, "docs/index.html is missing")
  local html = page:read("*a")
  page:close()

  -- The install commands are written into the page by hand, and they are not all
  -- one shape: cp, cp -r, source, open, an [include] line. So every extras/ path
  -- the page mentions is checked, whatever leads up to it. A reader who runs the
  -- command would find a stale path out; this finds it out first.
  local seen = {}
  for path in html:gmatch("(extras/[%w%-%./]+)") do
    path = path:gsub("%.$", "")
    if not seen[path] then
      seen[path] = true
      assert(vim.uv.fs_stat(path), "docs/index.html names " .. path .. ", which does not exist")
    end
  end
  local n = 0
  for _ in pairs(seen) do n = n + 1 end
  assert(n >= 20, "only " .. n .. " extras paths found on the page, expected one per surface")
end)

check("the surface count printed on the page matches the rows under it", function()
  local page = io.open("docs/index.html", "r")
  assert(page, "docs/index.html is missing")
  local html = page:read("*a")
  page:close()

  -- The script recomputes this on load, so the number in the markup is only what a
  -- reader sees before the script runs, or without one at all. That makes it exactly
  -- the kind of number that goes stale unnoticed when a surface is added.
  local printed = html:match('<span id="surface%-count">(%d+)</span>')
  assert(printed, "docs/index.html no longer prints a surface count")

  -- Counted inside the SURFACES literal only. Every three-string array on the page
  -- looks alike from the outside, so an unscoped count picks up DEPTHS and whatever
  -- else gets added next to it.
  local block = html:match("const SURFACES = (%b[])")
  assert(block, "docs/index.html no longer declares SURFACES as a literal")

  local rows = 0
  for _ in block:gmatch('%["[^"]+", "[^"]+", [\'"]') do
    rows = rows + 1
  end
  assert(tonumber(printed) == rows,
    ("docs/index.html prints %s surfaces but lists %d"):format(printed, rows))
end)

check("every section of the landing page is a unique deep link", function()
  local page = io.open("docs/index.html", "r")
  assert(page, "docs/index.html is missing")
  local html = page:read("*a")
  page:close()

  -- Duplicates are worth failing over rather than leaving to a reader to spot:
  -- the page's scripts reach for their render targets by id, so a second element
  -- answering to one of those names is silently written over.
  local seen = {}
  for id in html:gmatch('%sid="([^"]+)"') do
    assert(not seen[id], "duplicate id " .. id .. " in docs/index.html")
    seen[id] = true
  end

  -- Anything announced elsewhere has to keep landing somewhere. These are the
  -- anchors the README and the help file hand out.
  for _, id in ipairs({
    "depths", "in-the-editor", "specimen", "derivation", "pigments",
    "geometry", "rules", "install", "surfaces", "get",
  }) do
    assert(seen[id], "docs/index.html has no #" .. id .. " to link to")

    -- and each one is reachable from its own heading, so a section added later
    -- cannot quietly be the one without a permalink
    local anchor = ('<a class="permalink" href="#%s"'):format(id)
    assert(html:find(anchor, 1, true), "no permalink on the heading for #" .. id)
  end
end)

check("the help file exists and defines a tag per section", function()
  local doc = io.open("doc/cendre.txt", "r")
  assert(doc, "doc/cendre.txt is missing, so :help cendre fails")
  local body = doc:read("*a")
  doc:close()

  local seen = {}
  for tag in body:gmatch("%*([%w%.%-_():]+)%*") do
    assert(not seen[tag], "duplicate help tag " .. tag)
    seen[tag] = true
  end

  -- every documented option and command has to be reachable by :help
  for _, tag in ipairs({
    "cendre-contents", "cendre-installation", "cendre-configuration",
    "cendre-commands", "cendre-depths", "cendre-palette", "cendre-roles",
    "cendre-extras", "cendre.setup()", ":CendreBackground",
  }) do
    assert(seen[tag], "no help tag for " .. tag)
  end

  -- and every cross-reference inside the file has to land on one of them
  for ref in body:gmatch("|(cendre[%w%.%-_():]*)|") do
    assert(seen[ref], "help references |" .. ref .. "| but nothing defines it")
  end
end)

check("lualine theme follows the active background", function()
  reload()
  require("cendre").setup({ background = "soft" })
  require("cendre").load()
  package.loaded["lualine.themes.cendre"] = nil
  local theme = require("lualine.themes.cendre")
  assert(theme.normal.c.bg == require("cendre.palette").grounds.soft.bg2,
    "lualine still on the wrong ground")
end)

-- The margin beside every pigment claims a hue, a lightness and a source. None of
-- the three gets to be a comment nobody rechecks.
local PIGMENTS = { "brass", "ember", "sap", "cinder", "frost" }

--- The margin of M.pigments, parsed: hue, lightness and the source line as written.
local function margin()
  local src = io.open("lua/cendre/palette.lua", "r")
  assert(src, "lua/cendre/palette.lua is missing")
  local body = src:read("*a")
  src:close()

  local block = body:match("M%.pigments%s*=%s*{(.-)\n}")
  assert(block, "M.pigments is no longer a single table literal")

  local out = {}
  for name, hex, hue, l, source in block:gmatch('(%w+)%s*=%s*"(#%x+)",%s*%-%-%s*([%d%.]+)°%s*·%s*L%s*([%d%.]+)%s*·%s*(.-)%s*·') do
    out[name] = { hex = hex, hue = tonumber(hue), l = tonumber(l), source = source }
  end
  return out
end

check("the palette's margin matches the colours it ships", function()
  local noted = margin()
  local c = require("cendre.palette").pigments

  for _, name in ipairs(PIGMENTS) do
    local note = noted[name]
    assert(note, "no annotated line for " .. name .. " in M.pigments")
    assert(note.hex == c[name],
      ("%s: the margin sits beside %s but the table holds %s"):format(name, note.hex, c[name]))

    local L, _, hue = oklch(note.hex)
    assert(math.abs(hue - note.hue) < 0.05,
      ("%s: margin says %.1f°, %s is %.1f°"):format(name, note.hue, note.hex, hue))
    assert(math.abs(L - note.l) < 0.0005,
      ("%s: margin says L %.3f, %s is L %.3f"):format(name, note.l, note.hex, L))
  end
end)

check("every pigment carries the hue its source emits", function()
  -- derive.lua is a script that prints for a reader; here only its return matters
  local chunk = loadfile("derive.lua")
  assert(chunk, "derive.lua is missing: the palette's provenance is unverifiable")

  local spoken = print
  _G.print = function() end
  local ok, derived = pcall(chunk)
  _G.print = spoken
  assert(ok, "derive.lua failed to run: " .. tostring(derived))
  assert(type(derived) == "table", "derive.lua no longer returns what it computed")

  local noted = margin()

  -- The CMF fit derive.lua uses is published as within ~1% of the tabulated
  -- curves, and bringing a spectral line into sRGB rotates it a little more, so
  -- this is not an equality. Frost is the widest, at 1.4°.
  local TOLERANCE = 2.0

  for _, name in ipairs(PIGMENTS) do
    local from_source = derived[name]
    assert(from_source, "derive.lua computes no hue for " .. name)

    local _, _, hue = oklch(noted[name].hex)
    assert(math.abs(hue - from_source.hue) <= TOLERANCE,
      ("%s: %s is %.1f°, its source gives %.1f°"):format(name, noted[name].hex, hue, from_source.hue))

    -- and the margin has to name the number derive.lua was actually handed
    assert(noted[name].source:match(tostring(math.floor(from_source.arg))),
      ("%s: the margin reads \"%s\", derive.lua used %s"):format(name, noted[name].source, from_source.arg))
  end
end)

-- Both copies, the module's margin and the page's data tables, get recomputed from
-- the hex they sit beside, to half a unit in the last place each one prints.
local function annotated(body, pattern)
  local found = {}
  for line in body:gmatch("[^\n]+") do
    local hex = line:match('"(#%x%x%x%x%x%x)"')
    local note = hex and line:match(pattern)
    if note then
      found[#found + 1] = { hex = hex, note = note, line = line }
    end
  end
  return found
end

-- The decimal point is required: "C2 Swan 563 nm" sits in the same margin and
-- reads as a chroma of 2 to anything looser.
local function claims(note)
  return {
    { "L", tonumber(note:match("L:?%s*(%d%.%d+)")), 1, 0.0005 },
    { "C", tonumber(note:match("C:?%s*(%d%.%d+)")), 2, 0.0005 },
    { "hue", tonumber(note:match("hue:%s*(%d+%.%d)") or note:match("(%d+%.%d)°")), 3, 0.05 },
  }
end

check("every lightness and hue the module's margin prints is the hex beside it", function()
  local src = io.open("lua/cendre/palette.lua", "r")
  assert(src, "lua/cendre/palette.lua is missing")
  local body = src:read("*a")
  src:close()

  local rows = annotated(body, "%-%-%s*(.*)$")
  assert(#rows >= 30, "only " .. #rows .. " annotated colours found, the margin cannot have shrunk that far")

  for _, row in ipairs(rows) do
    local measured = { oklch(row.hex) }
    for _, c in ipairs(claims(row.note)) do
      local field, want, index, tolerance = c[1], c[2], c[3], c[4]
      if want then
        assert(math.abs(measured[index] - want) < tolerance,
          ("%s: margin says %s %s, %s is %.4f"):format(row.hex, field, want, row.hex, measured[index]))
      end
    end
  end
end)

check("every lightness and hue the page publishes is the hex beside it", function()
  local page = io.open("docs/index.html", "r")
  assert(page, "docs/index.html is missing")
  local body = page:read("*a")
  page:close()

  local rows = annotated(body, 'hex: "#%x+",%s*(.*)$')
  assert(#rows >= 30, "only " .. #rows .. " annotated colours found on the page")

  for _, row in ipairs(rows) do
    local measured = { oklch(row.hex) }
    for _, c in ipairs(claims(row.note)) do
      local field, want, index, tolerance = c[1], c[2], c[3], c[4]
      if want then
        assert(math.abs(measured[index] - want) < tolerance,
          ("%s: the page publishes %s %s, the hex is %.4f"):format(row.hex, field, want, measured[index]))
      end
    end
  end
end)

check("the derivation table on the page is what derive.lua prints", function()
  local page = io.open("docs/index.html", "r")
  assert(page, "docs/index.html is missing")
  local html = page:read("*a")
  page:close()

  local spoken = print
  _G.print = function() end
  local ok, derived = pcall(assert(loadfile("derive.lua")))
  _G.print = spoken
  assert(ok and type(derived) == "table", "derive.lua did not return what it computed")

  -- The page tells a reader that nvim -l derive.lua prints this column, so it has to.
  for _, name in ipairs(PIGMENTS) do
    local published = html:match('name:%s*"' .. name .. '".-derived:%s*([%d%.]+)')
    assert(published, "docs/index.html publishes no derived hue for " .. name)
    assert(math.abs(tonumber(published) - derived[name].hue) < 0.05,
      ("%s: the page publishes %s° derived, derive.lua computes %.1f°"):format(
        name, published, derived[name].hue))
  end
end)

check("the gaps the palette claims between its warm three are the gaps it ships", function()
  local src = io.open("lua/cendre/palette.lua", "r")
  local body = src:read("*a")
  src:close()

  local first, second = body:match("land%s+([%d%.]+)°%s+and%s+([%d%.]+)°%s+apart")
  assert(first, "the header no longer states the spacing of cinder, ember and brass")

  -- Held to the margin rather than to the full-precision hues, because that is what
  -- it restates: 61.4 less 43.8 is the 17.6 claimed, the hexes are 17.69 apart. The
  -- check above ties the margin to the hexes, so the chain still reaches the colour.
  local noted = margin()

  -- both sides are written to one decimal, so anything under that is float noise
  local function same(a, b)
    return math.abs(a - b) < 1e-9
  end

  assert(same(noted.ember.hue - noted.cinder.hue, tonumber(first)),
    ("cinder to ember is %.1f° in the margin, the header claims %s°"):format(
      noted.ember.hue - noted.cinder.hue, first))
  assert(same(noted.brass.hue - noted.ember.hue, tonumber(second)),
    ("ember to brass is %.1f° in the margin, the header claims %s°"):format(
      noted.brass.hue - noted.ember.hue, second))
end)

print(("-"):rep(52))
if #failures > 0 then
  print(#failures .. " failing: " .. table.concat(failures, ", "))
  vim.cmd("cquit")
else
  print("all checks passed")
  vim.cmd("quit")
end
