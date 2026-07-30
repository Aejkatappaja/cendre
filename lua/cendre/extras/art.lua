local M = {}

-- Artwork for the README, the favicon and the share card.
--
-- GitHub strips inline SVG from markdown, so these ship as files referenced with
-- <img>. That has one consequence worth spelling out: an SVG loaded through <img>
-- can only use fonts the reader already has. Every text run therefore carries an
-- explicit textLength, which pins its width whatever font the reader falls back
-- to. Without it, a mock positioned by x coordinate drifts apart on any machine
-- without the intended mono.

local palette = require("cendre.palette")

local MONO = "ui-monospace, SFMono-Regular, &apos;SF Mono&apos;, Menlo, "
  .. "Consolas, &apos;DejaVu Sans Mono&apos;, monospace"

-- Monospace advance as a fraction of the font size. Held to one number because
-- every x below is derived from it rather than measured.
local ADV = 0.6

local function esc(t)
  return (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- One line of a code mock: a list of { text, colour } runs laid out from col.
local function runs(line, size, x0, y, col)
  local out, x = {}, x0
  for _, run in ipairs(line) do
    local text, fill = run[1], run[2]
    if text ~= "" then
      local w = #text * size * ADV
      if fill then
        table.insert(out, string.format(
          '<text x="%.1f" y="%.1f" textLength="%.1f" lengthAdjust="spacingAndGlyphs"'
            .. ' fill="%s" xml:space="preserve">%s</text>',
          x, y, w, fill, esc(text)))
      end
      x = x + w
    end
  end
  return table.concat(out, "\n    "), x
end

-- The wordmark alone, split the way the site splits it: the stem in ink, the last
-- two letters in ember. No tagline inside the image: the README says those words
-- in its first line, and saying them twice is noise.
--
-- Centred by arithmetic rather than by text-anchor, because both runs are pinned
-- with textLength: their combined width is known, so the same maths holds for a
-- reader whose machine picks a different mono.
local function banner(bg)
  local c = palette.get(bg)
  local W, H = 880, 200
  local size = 104
  local stem, tail = "cend", "re"
  local stemW, tailW = #stem * size * ADV, #tail * size * ADV
  local x0 = (W - (stemW + tailW)) / 2
  -- "cendre" has no descenders, so its ink runs from the ascender to the
  -- baseline. Centre that band, not the em box.
  local baseline = (H + size * 0.75) / 2
  return string.format([[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d"
  role="img" aria-label="cendre">
  <rect width="%d" height="%d" fill="%s"/>
  <g font-family="%s" font-size="%d">
    <text x="%.1f" y="%.1f" textLength="%.1f" lengthAdjust="spacingAndGlyphs"
      fill="%s">%s</text>
    <text x="%.1f" y="%.1f" textLength="%.1f" lengthAdjust="spacingAndGlyphs"
      fill="%s">%s</text>
  </g>
</svg>
]],
    W, H, W, H,
    W, H, c.bg0,
    MONO, size,
    x0, baseline, stemW, c.fg, stem,
    x0 + stemW, baseline, tailW, c.ember, tail)
end

-- The editor mock from the landing page: diagnostics, git signs and statusline
-- all drawn from the semantic family, so the picture makes the same argument the
-- page does.
local function editor(bg)
  local c = palette.get(bg)
  local W, size, lh = 880, 15, 26
  local left, gutter, code = 20, 44, 68
  local top = 74
  local lines = {
    { { "func ", c.cinder }, { "LoadCaptures", c.brass }, { "(", c.fg_dim },
      { "path", c.ember }, { " ", nil }, { "string", c.frost }, { ") ([]", c.fg_dim },
      { "Capture", c.frost }, { ", ", c.fg_dim }, { "error", c.frost }, { ") {", c.fg_dim } },
    { { "  raw, err ", c.fg }, { ":= ", c.fg_dim }, { "os", c.frost }, { ".", c.fg_dim },
      { "ReadFile", c.brass }, { "(", c.fg_dim }, { "path", c.ember }, { ")", c.fg_dim } },
    { { "  raw, err ", c.fg }, { ":= ", c.fg_dim }, { "ioutil", c.frost }, { ".", c.fg_dim },
      { "ReadFile", c.brass }, { "(", c.fg_dim }, { "path", c.ember }, { ")", c.fg_dim } },
    { { "  var ", c.cinder }, { "parsed ", c.fg }, { "[]", c.fg_dim }, { "Capture", c.frost },
      { "   ", nil }, { "declared and not used: parsed", c.gutter } },
    { { "  return ", c.cinder }, { "normalise", c.brass }, { "(", c.fg_dim },
      { "raw", c.fg }, { "), ", c.fg_dim }, { "nil", c.sap },
      { "   ", nil }, { "prefer 'parsed' over re-reading 'raw'", c.gutter } },
    { { "}", c.fg_dim } },
  }
  -- git sign per line, and the diagnostic marker that sits inside the text
  local signs = { nil, c.ok, c.error, c.info, nil, nil }
  local marks = { [4] = c.error, [5] = c.warn }
  local H = top + #lines * lh + 46

  local body = {}
  for i, line in ipairs(lines) do
    local y = top + (i - 1) * lh + size
    table.insert(body, string.format(
      '<text x="%d" y="%.1f" textLength="%.1f" lengthAdjust="spacingAndGlyphs"'
        .. ' fill="%s" text-anchor="end">%d</text>',
      gutter, y, size * ADV, c.gutter, i))
    if signs[i] then
      table.insert(body, string.format(
        '<rect x="%d" y="%.1f" width="2" height="%d" fill="%s"/>',
        left + 32, y - size + 3, size + 2, signs[i]))
    end
    if marks[i] then
      -- measured from the start of the last run, which is the message: a fixed
      -- character offset would land inside it, since the two messages differ in
      -- length
      local before = 0
      for k = 1, #line - 1 do before = before + #line[k][1] end
      table.insert(body, string.format(
        '<rect x="%.1f" y="%.1f" width="7" height="7" fill="%s"/>',
        code + before * size * ADV - 14, y - 8, marks[i]))
    end
    local text = runs(line, size, code, y, c.fg)
    table.insert(body, text)
  end

  local tabs, tx = {}, code
  for j, name in ipairs({ "captures.go", "registry.go", "palette.lua" }) do
    local w = #name * 13 * ADV
    table.insert(tabs, string.format(
      '<text x="%.1f" y="34" textLength="%.1f" lengthAdjust="spacingAndGlyphs"'
        .. ' fill="%s">%s</text>', tx, w, j == 1 and c.fg or c.comment, name))
    if j == 1 then
      table.insert(tabs, string.format(
        '<rect x="%.1f" y="46" width="%.1f" height="2" fill="%s"/>', tx - 12, w + 24, c.ember))
    end
    tx = tx + w + 34
  end

  local sy = H - 26
  local status = string.format([[
  <rect x="0" y="%d" width="%d" height="34" fill="%s"/>
  <rect x="0" y="%d" width="88" height="34" fill="%s"/>
  <g font-family="%s" font-size="13">
    <text x="20" y="%d" textLength="%.1f" lengthAdjust="spacingAndGlyphs" fill="%s"
      letter-spacing="2">NORMAL</text>
    <text x="108" y="%d" fill="%s" xml:space="preserve">captures.go   main</text>
    <text x="%d" y="%d" fill="%s" text-anchor="end" xml:space="preserve">go   31:22</text>
  </g>]],
    sy - 8, W, c.bg2,
    sy - 8, c.ember,
    MONO,
    sy + 14, 6 * 13 * ADV, c.bg0,
    sy + 14, c.fg_dim,
    W - 20, sy + 14, c.gutter)

  return string.format([[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d"
  role="img" aria-label="Neovim showing Go code in cendre, with git signs, diagnostics and a statusline">
  <rect width="%d" height="%d" fill="%s"/>
  <rect width="%d" height="48" fill="%s"/>
  <line x1="0" y1="48" x2="%d" y2="48" stroke="%s" stroke-width="1"/>
  <g font-family="%s" font-size="13">
    %s
  </g>
  <g font-family="%s" font-size="%d">
    %s
  </g>
%s
  <rect x="0.5" y="0.5" width="%d" height="%d" fill="none" stroke="%s"/>
</svg>
]],
    W, H, W, H,
    W, H, c.bg0,
    W, c.bg1,
    W, c.bg3,
    MONO, table.concat(tabs, "\n    "),
    MONO, size, table.concat(body, "\n    "),
    status,
    W - 1, H - 1, c.bg3)
end

-- The favicon. At 16 pixels there is no detail, only a silhouette and colour, so
-- this is the wordmark's own split reduced to geometry: the ink half and the
-- ember half. A letterform would be drawn with whatever font the reader has, and
-- five pigment bands merge into a smudge at tab size. Measured, both times.
local function favicon(bg)
  local c = palette.get(bg)
  return string.format([[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" fill="%s"/>
  <rect x="4" y="4" width="12" height="24" fill="%s"/>
  <rect x="16" y="4" width="12" height="24" fill="%s"/>
</svg>
]], c.bg0, c.fg, c.ember)
end

-- The share card. 1200x630 is what X, Slack and Discord crop to, and every
-- platform ignores SVG, so this is rasterised into docs/og.png before release.
--
-- Composed for the ~400px an unfurl actually renders at, not for its own 1200:
-- three elements, each large enough to survive that reduction. The line naming
-- Neovim is gone because the platform prints the description beside the card,
-- and at 400px it was unreadable anyway.
local function ogcard(bg)
  local c = palette.get(bg)
  local W, H = 1200, 630
  local size = 156
  local stem, tail = "cend", "re"
  local stemW, tailW = #stem * size * ADV, #tail * size * ADV
  local x0 = (W - (stemW + tailW)) / 2
  local order = { "brass", "ember", "sap", "cinder", "frost" }
  local band, bandW = 148, 26
  local sx = (W - #order * band) / 2
  local strip = {}
  for i, name in ipairs(order) do
    table.insert(strip, string.format(
      '<rect x="%.1f" y="452" width="%d" height="%d" fill="%s"/>',
      sx + (i - 1) * band, band, bandW, c[name]))
  end
  return string.format([[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d">
  <rect width="%d" height="%d" fill="%s"/>
  <g font-family="%s" font-size="%d">
    <text x="%.1f" y="300" textLength="%.1f" lengthAdjust="spacingAndGlyphs"
      fill="%s">%s</text>
    <text x="%.1f" y="300" textLength="%.1f" lengthAdjust="spacingAndGlyphs"
      fill="%s">%s</text>
  </g>
  <g font-family="%s" font-size="42" fill="%s" text-anchor="middle">
    <text x="%d" y="382">one wood fire, taken apart</text>
  </g>
  %s
</svg>
]],
    W, H, W, H,
    W, H, c.bg0,
    MONO, size,
    x0, stemW, c.fg, stem,
    x0 + stemW, tailW, c.ember, tail,
    MONO, c.fg_dim, W / 2,
    table.concat(strip, "\n  "))
end

M.esc = esc
M.runs = runs
M.banner = banner
M.editor = editor
M.favicon = favicon
M.ogcard = ogcard

return M
