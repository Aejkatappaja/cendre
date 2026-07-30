local M = {}

function M.get(c)
  return {
    -- identifiers. A declared name stays uncoloured: what a thing is called is
    -- not a role, and leaving names in fg is what lets the five pigments read.
    ["@variable"]              = { fg = c.fg },
    ["@variable.builtin"]      = { fg = c.cinder },
    -- ember carries everything you reach through a dot or a signature, which is
    -- most of what you actually read, so that is where the warmth goes
    ["@variable.parameter"]    = { fg = c.ember },
    ["@variable.parameter.builtin"] = { fg = c.ember },
    ["@variable.member"]       = { fg = c.ember },
    ["@property"]             = { fg = c.ember },
    ["@field"]                = { fg = c.ember },

    -- constants: the name is not coloured, the value is
    ["@constant"]              = { fg = c.fg },
    ["@constant.builtin"]      = { fg = c.sap },
    ["@constant.macro"]        = { fg = c.ember },
    ["@number"]                = { fg = c.sap },
    ["@number.float"]          = { fg = c.sap },
    ["@boolean"]               = { fg = c.sap },

    -- strings, and every other literal, share one pigment
    ["@string"]                = { fg = c.sap },
    ["@string.documentation"]  = { fg = c.sap },
    ["@string.regexp"]         = { fg = c.ember },
    ["@string.escape"]         = { fg = c.ember },
    ["@string.special"]        = { fg = c.ember },
    ["@string.special.url"]    = { fg = c.frost, underline = true },
    ["@string.special.path"]   = { fg = c.frost },
    ["@character"]             = { fg = c.sap },
    ["@character.special"]     = { fg = c.ember },

    -- functions. Brass is the lightest thing in the palette because a call is
    -- what you scan a file for.
    ["@function"]              = { fg = c.brass },
    ["@function.builtin"]      = { fg = c.brass },
    ["@function.call"]         = { fg = c.brass },
    ["@function.method"]       = { fg = c.brass },
    ["@function.method.call"]  = { fg = c.brass },
    ["@function.macro"]        = { fg = c.ember },
    ["@constructor"]           = { fg = c.frost },

    -- keywords
    ["@keyword"]               = { fg = c.cinder },
    ["@keyword.function"]      = { fg = c.cinder },
    ["@keyword.operator"]      = { fg = c.cinder },
    ["@keyword.import"]        = { fg = c.cinder },
    ["@keyword.type"]          = { fg = c.cinder },
    ["@keyword.modifier"]      = { fg = c.cinder },
    ["@keyword.repeat"]        = { fg = c.cinder },
    ["@keyword.conditional"]   = { fg = c.cinder },
    ["@keyword.conditional.ternary"] = { fg = c.fg_dim },
    ["@keyword.exception"]     = { fg = c.cinder },
    ["@keyword.coroutine"]     = { fg = c.cinder },
    ["@keyword.debug"]         = { fg = c.error },
    ["@keyword.directive"]     = { fg = c.cinder },
    ["@keyword.directive.define"] = { fg = c.cinder },
    ["@keyword.return"]        = { fg = c.cinder },
    ["@label"]                 = { fg = c.cinder },

    -- types. frost is the dimmest and least saturated thing here, so a type
    -- annotation sits behind the code it annotates instead of in front of it.
    ["@type"]                  = { fg = c.frost },
    ["@type.builtin"]          = { fg = c.frost },
    ["@type.definition"]       = { fg = c.frost },
    ["@attribute"]             = { fg = c.ember },
    ["@attribute.builtin"]     = { fg = c.ember },
    ["@module"]                = { fg = c.frost },
    ["@module.builtin"]        = { fg = c.frost },

    -- operators, punctuation: quiet on purpose
    ["@operator"]              = { fg = c.fg_dim },
    ["@punctuation.delimiter"] = { fg = c.fg_dim },
    ["@punctuation.bracket"]   = { fg = c.fg_dim },
    ["@punctuation.special"]   = { fg = c.ember },

    -- comments
    ["@comment"]               = { fg = c.comment, italic = true },
    ["@comment.documentation"] = { fg = c.comment, italic = true },
    ["@comment.error"]         = { fg = c.bg0, bg = c.error, bold = true },
    ["@comment.warning"]       = { fg = c.bg0, bg = c.warn, bold = true },
    ["@comment.todo"]          = { fg = c.bg0, bg = c.info, bold = true },
    ["@comment.note"]          = { fg = c.bg0, bg = c.hint, bold = true },

    -- markup. Six heading levels out of five pigments, so the last one steps
    -- down to fg_dim rather than repeating a pigment.
    ["@markup"]                = { fg = c.fg },
    ["@markup.strong"]         = { bold = true },
    ["@markup.italic"]         = { italic = true },
    ["@markup.strikethrough"]  = { strikethrough = true },
    ["@markup.underline"]      = { underline = true },
    ["@markup.heading"]        = { fg = c.ember, bold = true },
    ["@markup.heading.1"]      = { fg = c.ember, bold = true },
    ["@markup.heading.2"]      = { fg = c.brass, bold = true },
    ["@markup.heading.3"]      = { fg = c.frost, bold = true },
    ["@markup.heading.4"]      = { fg = c.sap, bold = true },
    ["@markup.heading.5"]      = { fg = c.cinder, bold = true },
    ["@markup.heading.6"]      = { fg = c.fg_dim, bold = true },
    ["@markup.quote"]          = { fg = c.comment, italic = true },
    ["@markup.math"]           = { fg = c.sap },
    ["@markup.link"]           = { fg = c.frost },
    ["@markup.link.label"]     = { fg = c.frost },
    ["@markup.link.url"]       = { fg = c.comment, underline = true },
    ["@markup.raw"]            = { fg = c.sap },
    ["@markup.raw.block"]      = { fg = c.sap },
    ["@markup.list"]           = { fg = c.ember },
    ["@markup.list.checked"]   = { fg = c.ok },
    ["@markup.list.unchecked"] = { fg = c.comment },

    -- tags (html, jsx, svelte, vue). An attribute is a field, so it is ember.
    ["@tag"]                   = { fg = c.cinder },
    ["@tag.builtin"]           = { fg = c.cinder },
    ["@tag.attribute"]         = { fg = c.ember },
    ["@tag.delimiter"]         = { fg = c.fg_dim },

    -- diff
    ["@diff.plus"]             = { fg = c.ok },
    ["@diff.minus"]            = { fg = c.error },
    ["@diff.delta"]            = { fg = c.info },

    -- misc
    ["@none"]                  = { fg = c.fg },
    ["@error"]                 = { fg = c.error },
  }
end

return M
