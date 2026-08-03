-- Cendre's palette, from wavelengths. Run it:
--
--   nvim -l derive.lua
--
-- No data file and no dependency: the CIE curves have a published analytic fit
-- and OKLab is two matrix multiplies around a cube root.

-- CIE 1931 2-degree colour matching functions, multi-lobe piecewise-Gaussian
-- fit. Wyman, Sloan & Shirley, JCGT 2013. Within ~1% of the tabulated values.
local function g(x, mu, s1, s2)
  local s = x < mu and s1 or s2
  return math.exp(-0.5 * ((x - mu) / s) ^ 2)
end

local function cmf(l)
  return {
    1.056 * g(l, 599.8, 37.9, 31.0) + 0.362 * g(l, 442.0, 16.0, 26.7)
      - 0.065 * g(l, 501.1, 20.4, 26.2),
    0.821 * g(l, 568.8, 46.9, 40.5) + 0.286 * g(l, 530.9, 16.3, 31.1),
    1.217 * g(l, 437.0, 11.8, 36.0) + 0.681 * g(l, 459.0, 26.0, 13.8),
  }
end

-- Ottosson's OKLab.
local M1 = { { 0.8189330101, 0.3618667424, -0.1288597137 },
             { 0.0329845436, 0.9293118715,  0.0361456387 },
             { 0.0482003018, 0.2643662691,  0.6338517070 } }
local M2 = { { 0.2104542553,  0.7936177850, -0.0040720468 },
             { 1.9779984951, -2.4285922050,  0.4505937099 },
             { 0.0259040371,  0.7827717662, -0.8086757660 } }

local function mul(M, v)
  local o = {}
  for i = 1, 3 do
    o[i] = M[i][1] * v[1] + M[i][2] * v[2] + M[i][3] * v[3]
  end
  return o
end

-- math.atan2 in LuaJIT, math.atan(y, x) from 5.3 on.
local atan2 = math.atan2 or math.atan

local function oklch(xyz)
  local lms = mul(M1, xyz)
  for i = 1, 3 do
    -- a fractional power of a negative number is NaN, so carry the sign
    local c = lms[i]
    lms[i] = c < 0 and -((-c) ^ (1 / 3)) or c ^ (1 / 3)
  end
  local lab = mul(M2, lms)
  local L, a, b = lab[1], lab[2], lab[3]
  return L, math.sqrt(a * a + b * b), atan2(b, a) * 180 / math.pi % 360
end

-- An emission line is a delta function, so the integral collapses: XYZ is the
-- colour matching function evaluated at that wavelength, nothing to sum.
local function line(nm)
  return oklch(cmf(nm))
end

-- Planck's law. Wood coals sit around 1300 K.
local H, C, K = 6.62607015e-34, 2.99792458e8, 1.380649e-23

local function planck(nm, T)
  local l = nm * 1e-9
  return (2 * H * C ^ 2 / l ^ 5) / (math.exp(H * C / (l * K * T)) - 1)
end

local function blackbody(T)
  local acc = { 0, 0, 0 }
  for nm = 360, 830 do
    local p = planck(nm, T)
    local c = cmf(nm)
    for i = 1, 3 do
      acc[i] = acc[i] + p * c[i]
    end
  end
  return oklch(acc)
end

local sources = {
  { "cinder", "CaOH band",    line, 622 },
  { "ember",  "coals 1300 K", blackbody, 1300 },
  { "brass",  "sodium D",     line, 589 },
  { "sap",    "C2 Swan",      line, 563 },
  { "frost",  "C2 Swan",      line, 474 },
}

-- Printed for a reader, returned for test/smoke.lua, which replays this file and
-- holds the shipped pigments to what it computes.
local derived = {}

for _, s in ipairs(sources) do
  local name, what, fn, arg = s[1], s[2], s[3], s[4]
  local _, _, hue = fn(arg)
  print(string.format("%-8s %-14s %6.1f°", name, what, hue))
  derived[name] = { source = what, arg = arg, hue = hue }
end

return derived
