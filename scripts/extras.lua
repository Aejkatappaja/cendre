-- Write everything under extras/ from lua/cendre/palette.lua.
--
-- Run: nvim --headless --noplugin -u NONE -c "set rtp+=." -c "luafile scripts/extras.lua" -c q
--
-- The templates live in lua/cendre/extras.lua so that test/smoke.lua can check
-- the committed files against a fresh render without writing anything.

for path, body in pairs(require("cendre.extras").files()) do
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local fd = assert(io.open(path, "w"))
  fd:write(body)
  fd:close()
  print("wrote " .. path)
end
