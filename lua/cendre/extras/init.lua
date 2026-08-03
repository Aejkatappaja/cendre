local M = {}

-- Every file under extras/, assets/ and the generated part of docs/ is rendered
-- from lua/cendre/palette.lua and nothing else, so a colour can never be right in
-- the editor and stale in a terminal.
--
-- This module only builds strings. scripts/extras.lua writes them to disk, and
-- test/smoke.lua compares them against what is committed, which is what makes
-- hand-editing a generated file a test failure instead of a silent divergence.

local palette = require("cendre.palette")

local art = require("cendre.extras.art")
local editors = require("cendre.extras.editors")
local terminals = require("cendre.extras.terminals")
local tools = require("cendre.extras.tools")

local DEFAULT = "hard"

-- Every surface below carries a background, so every one of them ships at all
-- three depths: a reader on soft wants soft in their terminal too. The default
-- depth keeps the unsuffixed name, so `theme = cendre` needs no second decision.
local PER_DEPTH = {
  ["extras/vim/cendre.vim"] = editors.vim,
  ["extras/helix/cendre.toml"] = editors.helix,
  ["extras/zed/themes/cendre.json"] = editors.zed,

  ["extras/ghostty/cendre"] = terminals.ghostty,
  ["extras/kitty/cendre.conf"] = terminals.kitty,
  ["extras/alacritty/cendre.toml"] = terminals.alacritty,
  ["extras/wezterm/cendre.toml"] = terminals.wezterm,
  ["extras/foot/cendre.ini"] = terminals.foot,
  ["extras/konsole/cendre.colorscheme"] = terminals.konsole,
  ["extras/kde/cendre.colors"] = tools.kde,
  ["extras/macos-terminal/cendre.itermcolors"] = terminals.itermcolors,
  ["extras/macos-terminal/cendre.terminal"] = terminals.macos_terminal,
  ["extras/tmux/cendre.tmux.conf"] = terminals.tmux,
  ["extras/tmux/cendre.tokyo-night.sh"] = terminals.tokyo_night_tmux,

  ["extras/starship/cendre.toml"] = tools.starship,
  ["extras/fzf/cendre.sh"] = tools.fzf,
  ["extras/eza/cendre.sh"] = tools.eza,
  ["extras/herdr/cendre.toml"] = tools.herdr,
  ["extras/bat/cendre.tmTheme"] = tools.bat,
  ["extras/delta/cendre.gitconfig"] = tools.delta,
  ["extras/lazygit/cendre.yml"] = tools.lazygit,
  ["extras/btop/cendre.theme"] = tools.btop,
  ["extras/yazi/cendre.toml"] = tools.yazi,
  ["extras/opencode/cendre.json"] = tools.opencode,
  ["extras/hunk/cendre.toml"] = tools.hunk,
  ["extras/slack/cendre.txt"] = tools.slack,

  -- Obsidian and Firefox load a folder, not a file, so their depths are folders.
  ["extras/obsidian/cendre/theme.css"] = tools.obsidian,
  ["extras/obsidian/cendre/manifest.json"] = tools.obsidian_manifest,
  ["extras/firefox/cendre/manifest.json"] = tools.firefox,
}

-- Artwork ships once. The landing page carries its own depth switcher, and a
-- README does not need three of each picture.
local ONCE = {
  -- Zed lists an extension once and its themes inside it, so the manifest does
  -- not take a depth suffix even though the three themes beside it do.
  ["extras/zed/extension.toml"] = editors.zed_extension,
  -- their packaging step looks for the licence beside the manifest, not at the
  -- root of the repository, so the extension carries its own copy
  ["extras/zed/LICENSE"] = editors.zed_licence,

  ["assets/banner.svg"] = art.banner,
  ["assets/editor.svg"] = art.editor,
  ["docs/favicon.svg"] = art.favicon,
  ["docs/og.svg"] = art.ogcard,
}

--- Where a target lands for a given depth. The default keeps the plain name; the
--- others take a suffix, before the extension for a file and on the folder for a
--- theme that ships as a directory.
--- @param path string the default-depth path
--- @param bg string depth name
--- @return string
local function at_depth(path, bg)
  if bg == DEFAULT then return path end

  local folder, rest = path:match("^(.*/cendre)/(.+)$")
  if folder then return ("%s-%s/%s"):format(folder, bg, rest) end

  -- everything after the first dot is the extension, so cendre.tmux.conf
  -- becomes cendre-soft.tmux.conf and not cendre.tmux.conf-soft
  local stem, ext = path:match("^(.*/cendre)(%..+)$")
  if stem then return ("%s-%s%s"):format(stem, bg, ext) end

  return ("%s-%s"):format(path, bg)
end

--- Every generated file, keyed by path relative to the repo root.
--- @return table<string, string>
function M.files()
  local out = {}

  for path, build in pairs(PER_DEPTH) do
    for _, bg in ipairs(palette.backgrounds) do
      out[at_depth(path, bg)] = build(bg)
    end
  end

  for path, build in pairs(ONCE) do
    out[path] = build(DEFAULT)
  end

  return out
end

--- The surfaces the extras cover, for the test that keeps the count honest.
--- @return integer
function M.surface_count()
  local seen = {}
  for path in pairs(PER_DEPTH) do
    seen[path:match("^extras/([^/]+)/")] = true
  end
  local n = 0
  for _ in pairs(seen) do n = n + 1 end
  return n
end

return M
