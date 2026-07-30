local M = {}

-- Legacy vim syntax groups. One role, one pigment. See palette.lua.
--
-- Punctuation deliberately takes fg_dim: colouring operators makes a line
-- louder than its own logic. Every literal value takes sap, so a number and a
-- string are the same kind of thing on screen, because they are.
function M.get(c)
  return {
    Comment      = { fg = c.comment, italic = true },

    Constant     = { fg = c.sap },
    String       = { fg = c.sap },
    Character    = { fg = c.sap },
    Number       = { fg = c.sap },
    Float        = { fg = c.sap },
    Boolean      = { fg = c.sap },

    Identifier   = { fg = c.fg },
    Function     = { fg = c.brass },

    Statement    = { fg = c.cinder },
    Conditional  = { fg = c.cinder },
    Repeat       = { fg = c.cinder },
    Label        = { fg = c.cinder },
    Keyword      = { fg = c.cinder },
    Exception    = { fg = c.cinder },
    Operator     = { fg = c.fg_dim },

    PreProc      = { fg = c.cinder },
    Include      = { fg = c.cinder },
    Define       = { fg = c.cinder },
    Macro        = { fg = c.ember },
    PreCondit    = { fg = c.cinder },

    Type         = { fg = c.frost },
    StorageClass = { fg = c.cinder },
    Structure    = { fg = c.frost },
    Typedef      = { fg = c.frost },

    Special      = { fg = c.ember },
    SpecialChar  = { fg = c.ember },
    Tag          = { fg = c.cinder },
    Delimiter    = { fg = c.fg_dim },
    SpecialComment = { fg = c.comment, italic = true },
    Debug        = { fg = c.error },

    Underlined   = { underline = true },
    Bold         = { bold = true },
    Italic       = { italic = true },
    Ignore       = { fg = c.gutter },
    Error        = { fg = c.error },
    Todo         = { fg = c.bg0, bg = c.warn, bold = true },

    -- markdown / help, the two filetypes a colorscheme gets judged on
    markdownH1   = { fg = c.ember, bold = true },
    markdownH2   = { fg = c.brass, bold = true },
    markdownH3   = { fg = c.frost, bold = true },
    markdownCode = { fg = c.sap },
    markdownCodeBlock = { fg = c.sap },
    markdownLinkText = { fg = c.frost, underline = true },
    markdownUrl  = { fg = c.comment },
    helpHyperTextJump = { fg = c.frost, underline = true },
    helpCommand  = { fg = c.brass },
    helpExample  = { fg = c.sap },
  }
end

return M
