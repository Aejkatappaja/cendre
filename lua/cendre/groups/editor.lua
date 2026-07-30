local M = {}

function M.get(c)
  return {
    Normal       = { fg = c.fg, bg = c.bg0 },
    NormalNC     = { fg = c.fg, bg = c.bg0 },
    NormalFloat  = { fg = c.fg, bg = c.bg_deep },
    FloatBorder  = { fg = c.bg3, bg = c.bg_deep },
    FloatTitle   = { fg = c.ember, bold = true },
    FloatFooter  = { fg = c.comment, bg = c.bg_deep },

    Cursor       = { fg = c.bg0, bg = c.ember },
    lCursor      = { fg = c.bg0, bg = c.ember },
    CursorIM     = { fg = c.bg0, bg = c.ember },
    TermCursor   = { fg = c.bg0, bg = c.ember },
    CursorLine   = { bg = c.bg1 },
    CursorColumn = { bg = c.bg1 },
    ColorColumn  = { bg = c.bg1 },
    CursorLineNr = { fg = c.ember, bold = true },
    LineNr       = { fg = c.gutter },
    LineNrAbove  = { fg = c.gutter },
    LineNrBelow  = { fg = c.gutter },
    SignColumn   = { fg = c.gutter, bg = c.bg0 },
    FoldColumn   = { fg = c.gutter, bg = c.bg0 },
    Folded       = { fg = c.comment, bg = c.bg1 },

    Visual       = { bg = c.vis },
    VisualNOS    = { bg = c.vis },
    Search       = { fg = c.bg0, bg = c.brass },
    IncSearch    = { fg = c.bg0, bg = c.ember },
    CurSearch    = { fg = c.bg0, bg = c.ember },
    Substitute   = { fg = c.bg0, bg = c.error },
    MatchParen   = { fg = c.ember, bold = true },

    Pmenu        = { fg = c.fg, bg = c.bg1 },
    PmenuSel     = { fg = c.bg0, bg = c.ember, bold = true },
    PmenuKind    = { fg = c.frost, bg = c.bg1 },
    PmenuKindSel = { fg = c.bg0, bg = c.ember },
    PmenuExtra   = { fg = c.comment, bg = c.bg1 },
    PmenuExtraSel = { fg = c.bg0, bg = c.ember },
    PmenuSbar    = { bg = c.bg2 },
    PmenuThumb   = { bg = c.bg4 },
    WildMenu     = { fg = c.bg0, bg = c.ember },

    StatusLine   = { fg = c.fg_dim, bg = c.bg2 },
    StatusLineNC = { fg = c.gutter, bg = c.bg1 },
    TabLine      = { fg = c.comment, bg = c.bg1 },
    TabLineFill  = { bg = c.bg1 },
    TabLineSel   = { fg = c.fg, bg = c.bg0, bold = true },
    WinBar       = { fg = c.fg_dim, bg = c.none },
    WinBarNC     = { fg = c.gutter, bg = c.none },

    WinSeparator = { fg = c.bg3, bg = c.bg0 },
    VertSplit    = { fg = c.bg3, bg = c.bg0 },

    -- messages
    ModeMsg      = { fg = c.ember, bold = true },
    MoreMsg      = { fg = c.info },
    Question     = { fg = c.info },
    ErrorMsg     = { fg = c.error, bold = true },
    WarningMsg   = { fg = c.warn },
    MsgArea      = { fg = c.fg_dim },
    MsgSeparator = { fg = c.bg3 },

    NonText      = { fg = c.bg4 },
    Whitespace   = { fg = c.bg3 },
    SpecialKey   = { fg = c.bg4 },
    EndOfBuffer  = { fg = c.bg1 },
    Conceal      = { fg = c.comment },
    Directory    = { fg = c.frost },
    Title        = { fg = c.ember, bold = true },
    QuickFixLine = { bg = c.bg2, bold = true },
    qfLineNr     = { fg = c.gutter },
    qfFileName   = { fg = c.frost },

    -- diff
    DiffAdd      = { bg = c.add },
    DiffDelete   = { bg = c.del },
    DiffChange   = { bg = c.mod },
    DiffText     = { bg = c.bg3, bold = true },
    diffAdded    = { fg = c.ok },
    diffRemoved  = { fg = c.error },
    diffChanged  = { fg = c.info },
    diffOldFile  = { fg = c.warn },
    diffNewFile  = { fg = c.ok },
    diffFile     = { fg = c.frost },
    diffLine     = { fg = c.comment },
    diffIndexLine = { fg = c.comment },

    -- spell
    SpellBad     = { undercurl = true, sp = c.error },
    SpellCap     = { undercurl = true, sp = c.warn },
    SpellLocal   = { undercurl = true, sp = c.info },
    SpellRare    = { undercurl = true, sp = c.hint },
  }
end

return M
