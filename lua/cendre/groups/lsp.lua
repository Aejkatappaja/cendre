local M = {}

function M.get(c)
  return {
    -- Diagnostics are their own family. Every one of these carries more chroma
    -- than any syntax pigment, so an error never wears the same red as a keyword.
    DiagnosticError = { fg = c.error },
    DiagnosticWarn  = { fg = c.warn },
    DiagnosticInfo  = { fg = c.info },
    DiagnosticHint  = { fg = c.hint },
    DiagnosticOk    = { fg = c.ok },

    DiagnosticVirtualTextError = { fg = c.error, bg = c.del },
    DiagnosticVirtualTextWarn  = { fg = c.warn, bg = c.bg1 },
    DiagnosticVirtualTextInfo  = { fg = c.info, bg = c.mod },
    DiagnosticVirtualTextHint  = { fg = c.hint, bg = c.bg1 },
    DiagnosticVirtualTextOk    = { fg = c.ok, bg = c.add },

    DiagnosticUnderlineError = { undercurl = true, sp = c.error },
    DiagnosticUnderlineWarn  = { undercurl = true, sp = c.warn },
    DiagnosticUnderlineInfo  = { undercurl = true, sp = c.info },
    DiagnosticUnderlineHint  = { undercurl = true, sp = c.hint },
    DiagnosticUnderlineOk    = { undercurl = true, sp = c.ok },

    DiagnosticFloatingError = { fg = c.error, bg = c.bg_deep },
    DiagnosticFloatingWarn  = { fg = c.warn, bg = c.bg_deep },
    DiagnosticFloatingInfo  = { fg = c.info, bg = c.bg_deep },
    DiagnosticFloatingHint  = { fg = c.hint, bg = c.bg_deep },
    DiagnosticFloatingOk    = { fg = c.ok, bg = c.bg_deep },

    DiagnosticSignError = { fg = c.error },
    DiagnosticSignWarn  = { fg = c.warn },
    DiagnosticSignInfo  = { fg = c.info },
    DiagnosticSignHint  = { fg = c.hint },
    DiagnosticSignOk    = { fg = c.ok },

    DiagnosticDeprecated = { fg = c.comment, strikethrough = true },
    DiagnosticUnnecessary = { fg = c.gutter },

    LspReferenceText  = { bg = c.bg2 },
    LspReferenceRead  = { bg = c.bg2 },
    LspReferenceWrite = { bg = c.bg2, underline = true },
    LspSignatureActiveParameter = { fg = c.ember, bold = true },
    LspInlayHint      = { fg = c.gutter, bg = c.bg1, italic = true },
    LspCodeLens       = { fg = c.comment, italic = true },
    LspCodeLensSeparator = { fg = c.bg3 },
    LspInfoBorder     = { fg = c.bg3, bg = c.bg_deep },

    -- semantic tokens: follow the same role mapping as treesitter
    ["@lsp.type.class"]         = { fg = c.frost },
    ["@lsp.type.decorator"]     = { fg = c.ember },
    ["@lsp.type.enum"]          = { fg = c.frost },
    ["@lsp.type.enumMember"]    = { fg = c.sap },
    ["@lsp.type.function"]      = { fg = c.brass },
    ["@lsp.type.interface"]     = { fg = c.frost },
    ["@lsp.type.macro"]         = { fg = c.ember },
    ["@lsp.type.method"]        = { fg = c.brass },
    ["@lsp.type.namespace"]     = { fg = c.frost },
    ["@lsp.type.parameter"]     = { fg = c.ember },
    ["@lsp.type.property"]      = { fg = c.ember },
    ["@lsp.type.struct"]        = { fg = c.frost },
    ["@lsp.type.type"]          = { fg = c.frost },
    ["@lsp.type.typeParameter"] = { fg = c.frost },
    ["@lsp.type.variable"]      = { fg = c.fg },
    ["@lsp.type.keyword"]       = { fg = c.cinder },
    ["@lsp.type.comment"]       = { fg = c.comment, italic = true },
    ["@lsp.type.string"]        = { fg = c.sap },
    ["@lsp.type.number"]        = { fg = c.sap },
    ["@lsp.type.operator"]      = { fg = c.fg_dim },
    -- readonly is not a role. A constant's name reads as a name, and only the
    -- value it holds takes a pigment.
    ["@lsp.mod.deprecated"]     = { strikethrough = true },
    ["@lsp.typemod.function.defaultLibrary"] = { fg = c.brass },
    ["@lsp.typemod.variable.defaultLibrary"] = { fg = c.frost },
  }
end

return M
