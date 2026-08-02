local M = {}

-- Plugins you actually run, per lazyvim.json + your colorscheme.lua.
--
-- Only what a plugin colours differently from a plain float belongs here. The
-- window surfaces themselves are deliberately absent: every one of these plugins
-- already links its window to NormalFloat and its edge to FloatBorder, so naming
-- them again would render identically while pinning the colour, and a pinned
-- colour is one `transparent = true` cannot strip. That is what used to leave
-- which-key, the Snacks picker, Noice and fzf-lua opaque over the terminal.
-- Colour NormalFloat and FloatBorder, and the windows follow.
function M.get(c)
  return {
    -- gitsigns
    GitSignsAdd          = { fg = c.ok },
    GitSignsChange       = { fg = c.info },
    GitSignsDelete       = { fg = c.error },
    GitSignsUntracked    = { fg = c.comment },
    GitSignsAddLn        = { bg = c.add },
    GitSignsChangeLn     = { bg = c.mod },
    GitSignsDeleteLn     = { bg = c.del },
    GitSignsCurrentLineBlame = { fg = c.gutter, italic = true },
    GitSignsAddInline    = { bg = c.bg3 },
    GitSignsChangeInline = { bg = c.bg3 },
    GitSignsDeleteInline = { bg = c.bg3 },

    -- snacks (picker, dashboard, notifier, input)
    SnacksNormal            = { fg = c.fg, bg = c.bg_deep },
    SnacksNormalNC          = { fg = c.fg, bg = c.bg_deep },
    SnacksWinBar            = { fg = c.ember, bold = true },
    SnacksPickerTitle       = { fg = c.ember, bold = true },
    SnacksPickerBoxTitle    = { fg = c.ember, bold = true },
    SnacksPickerInputTitle  = { fg = c.ember, bold = true },
    SnacksPickerMatch       = { fg = c.ember, bold = true },
    SnacksPickerDir         = { fg = c.comment },
    SnacksPickerFile        = { fg = c.fg },
    SnacksPickerCursorLine  = { bg = c.bg2 },
    SnacksPickerPathHidden  = { fg = c.gutter },
    SnacksPickerPathIgnored = { fg = c.gutter },
    SnacksDashboardHeader   = { fg = c.ember },
    SnacksDashboardKey      = { fg = c.cinder },
    SnacksDashboardDesc     = { fg = c.fg },
    SnacksDashboardIcon     = { fg = c.fg },
    SnacksDashboardFooter   = { fg = c.comment, italic = true },
    SnacksDashboardTitle    = { fg = c.brass },
    SnacksDashboardSpecial  = { fg = c.ember },
    SnacksIndent            = { fg = c.bg2 },
    SnacksIndentScope       = { fg = c.bg4 },
    SnacksNotifierInfo      = { fg = c.info },
    SnacksNotifierWarn      = { fg = c.warn },
    SnacksNotifierError     = { fg = c.error },
    SnacksNotifierDebug     = { fg = c.comment },
    SnacksNotifierTrace     = { fg = c.comment },

    -- blink.cmp
    BlinkCmpMenuSelection  = { bg = c.bg3, bold = true },
    BlinkCmpScrollBarThumb = { bg = c.bg4 },
    BlinkCmpScrollBarGutter = { bg = c.bg1 },
    BlinkCmpLabel          = { fg = c.fg },
    BlinkCmpLabelDeprecated = { fg = c.comment, strikethrough = true },
    BlinkCmpLabelMatch     = { fg = c.ember, bold = true },
    BlinkCmpLabelDetail    = { fg = c.comment },
    BlinkCmpKind           = { fg = c.frost },
    BlinkCmpKindFunction   = { fg = c.brass },
    BlinkCmpKindMethod     = { fg = c.brass },
    BlinkCmpKindVariable   = { fg = c.fg },
    BlinkCmpKindField      = { fg = c.ember },
    BlinkCmpKindProperty   = { fg = c.ember },
    BlinkCmpKindClass      = { fg = c.frost },
    BlinkCmpKindInterface  = { fg = c.frost },
    BlinkCmpKindKeyword    = { fg = c.cinder },
    BlinkCmpKindConstant   = { fg = c.sap },
    BlinkCmpKindSnippet    = { fg = c.ember },
    BlinkCmpDocSeparator   = { fg = c.bg3 },
    BlinkCmpSignatureHelpActiveParameter = { fg = c.ember, bold = true },
    BlinkCmpGhostText      = { fg = c.gutter, italic = true },

    -- fzf-lua
    FzfLuaTitle       = { fg = c.ember, bold = true },
    FzfLuaCursorLine  = { bg = c.bg2 },
    FzfLuaFzfMatch    = { fg = c.ember, bold = true },
    FzfLuaHeaderText  = { fg = c.cinder },
    FzfLuaPathLineNr  = { fg = c.gutter },

    -- which-key
    WhichKey          = { fg = c.ember },
    WhichKeyTitle     = { fg = c.ember, bold = true },
    WhichKeyGroup     = { fg = c.frost },
    WhichKeyDesc      = { fg = c.fg },
    WhichKeySeparator = { fg = c.gutter },
    WhichKeyValue     = { fg = c.comment },
    WhichKeyIcon      = { fg = c.brass },

    -- noice
    NoiceCmdlinePopupTitle = { fg = c.ember, bold = true },
    NoiceCmdlineIcon      = { fg = c.ember },
    NoiceCmdlineIconSearch = { fg = c.brass },
    NoiceMini             = { fg = c.fg_dim, bg = c.bg1 },
    NoiceVirtualText      = { fg = c.gutter, italic = true },
    NoiceLspProgressTitle = { fg = c.fg },
    NoiceLspProgressClient = { fg = c.frost },
    NoiceLspProgressSpinner = { fg = c.ember },

    -- neo-tree / nvim-tree
    NeoTreeNormal        = { fg = c.fg_dim, bg = c.bg_deep },
    NeoTreeNormalNC      = { fg = c.fg_dim, bg = c.bg_deep },
    NeoTreeWinSeparator  = { fg = c.bg3, bg = c.bg_deep },
    NeoTreeEndOfBuffer   = { fg = c.bg_deep, bg = c.bg_deep },
    NeoTreeRootName      = { fg = c.ember, bold = true },
    NeoTreeDirectoryName = { fg = c.frost },
    NeoTreeDirectoryIcon = { fg = c.frost },
    NeoTreeFileName      = { fg = c.fg_dim },
    NeoTreeFileIcon      = { fg = c.fg_dim },
    NeoTreeIndentMarker  = { fg = c.bg3 },
    NeoTreeGitAdded      = { fg = c.ok },
    NeoTreeGitModified   = { fg = c.info },
    NeoTreeGitDeleted    = { fg = c.error },
    NeoTreeGitUntracked  = { fg = c.comment },
    NeoTreeGitIgnored    = { fg = c.gutter },
    NeoTreeCursorLine    = { bg = c.bg1 },
    NvimTreeNormal       = { fg = c.fg_dim, bg = c.bg_deep },
    NvimTreeRootFolder   = { fg = c.ember, bold = true },
    NvimTreeFolderName   = { fg = c.frost },
    NvimTreeFolderIcon   = { fg = c.frost },
    NvimTreeIndentMarker = { fg = c.bg3 },
    NvimTreeGitDirty     = { fg = c.info },
    NvimTreeGitNew       = { fg = c.ok },
    NvimTreeGitDeleted   = { fg = c.error },

    -- flash
    FlashLabel   = { fg = c.bg0, bg = c.ember, bold = true },
    FlashMatch   = { fg = c.bg0, bg = c.brass },
    FlashCurrent = { fg = c.bg0, bg = c.ember },
    FlashBackdrop = { fg = c.gutter },

    -- trouble
    TroubleNormal   = { fg = c.fg_dim, bg = c.bg_deep },
    TroubleText     = { fg = c.fg },
    TroubleCount    = { fg = c.ember, bg = c.bg2 },
    TroubleFile     = { fg = c.frost },
    TroubleSource   = { fg = c.comment },
    TroubleCode     = { fg = c.comment },
    TroubleIndent   = { fg = c.bg3 },

    -- lazy
    LazyProgressDone = { fg = c.ok, bold = true },
    LazyProgressTodo = { fg = c.bg4 },
    LazyH1           = { fg = c.bg0, bg = c.ember, bold = true },
    LazyH2           = { fg = c.ember, bold = true },
    LazyButton       = { fg = c.fg, bg = c.bg2 },
    -- lazy paints the key hint over this button, so the ground stays dark
    LazyButtonActive = { fg = c.fg, bg = c.bg3, bold = true, underline = true },
    LazySpecial      = { fg = c.ember },
    LazyCommit       = { fg = c.sap },
    LazyReasonPlugin = { fg = c.cinder },
    LazyReasonEvent  = { fg = c.brass },
    LazyReasonKeys   = { fg = c.ember },
    LazyReasonStart  = { fg = c.ok },
    LazyReasonSource = { fg = c.sap },
    LazyReasonRuntime = { fg = c.hint },
    LazyReasonRequire = { fg = c.info },
    LazyReasonCmd    = { fg = c.frost },
    LazyReasonImport = { fg = c.fg_dim },
    LazyReasonFt     = { fg = c.sap },

    -- mason
    MasonHeader          = { fg = c.bg0, bg = c.ember, bold = true },
    MasonHighlight       = { fg = c.frost },
    MasonHighlightBlock  = { fg = c.bg0, bg = c.frost },
    MasonHighlightBlockBold = { fg = c.bg0, bg = c.frost, bold = true },
    MasonMuted           = { fg = c.comment },
    MasonMutedBlock      = { fg = c.fg_dim, bg = c.bg2 },

    -- nvim-dap / dap-ui
    DapBreakpoint       = { fg = c.error },
    DapBreakpointRejected = { fg = c.comment },
    DapLogPoint         = { fg = c.info },
    DapStopped          = { fg = c.warn },
    DapStoppedLine      = { bg = c.bg2 },
    DapUIVariable       = { fg = c.fg },
    DapUIScope          = { fg = c.frost },
    DapUIType           = { fg = c.frost },
    DapUIValue          = { fg = c.sap },
    DapUIModifiedValue  = { fg = c.ember, bold = true },
    DapUIDecoration     = { fg = c.bg3 },
    DapUIThread         = { fg = c.ok },
    DapUIStoppedThread  = { fg = c.warn },
    DapUISource         = { fg = c.frost },
    DapUILineNumber     = { fg = c.gutter },
    DapUIFloatBorder    = { fg = c.bg3 },
    DapUIWatchesEmpty   = { fg = c.comment },
    DapUIWatchesValue   = { fg = c.ok },
    DapUIWatchesError   = { fg = c.error },
    DapUIBreakpointsPath = { fg = c.frost },
    DapUIBreakpointsInfo = { fg = c.info },
    DapUIBreakpointsCurrentLine = { fg = c.ember, bold = true },

    -- neotest
    NeotestPassed   = { fg = c.ok },
    NeotestFailed   = { fg = c.error },
    NeotestRunning  = { fg = c.warn },
    NeotestSkipped  = { fg = c.comment },
    NeotestTest     = { fg = c.fg },
    NeotestNamespace = { fg = c.frost },
    NeotestFile     = { fg = c.frost },
    NeotestDir      = { fg = c.frost },
    NeotestFocused  = { fg = c.ember, bold = true },
    NeotestAdapterName = { fg = c.frost },
    NeotestIndent   = { fg = c.bg3 },
    NeotestExpandMarker = { fg = c.bg4 },
    NeotestWinSelect = { fg = c.ember },
    NeotestMarked   = { fg = c.ember, bold = true },
    NeotestTarget   = { fg = c.cinder },

    -- mini
    MiniIndentscopeSymbol = { fg = c.bg4 },
    MiniIndentscopePrefix = { nocombine = true },
    MiniHipatternsFixme = { fg = c.bg0, bg = c.error, bold = true },
    MiniHipatternsHack  = { fg = c.bg0, bg = c.warn, bold = true },
    MiniHipatternsTodo  = { fg = c.bg0, bg = c.info, bold = true },
    MiniHipatternsNote  = { fg = c.bg0, bg = c.hint, bold = true },

    -- hlchunk
    HLChunk1     = { fg = c.bg5 },
    HLIndent1    = { fg = c.bg2 },
    HLLineNum1   = { fg = c.ember },

    -- grug-far
    GrugFarHelpHeader      = { fg = c.comment },
    GrugFarHelpHeaderKey   = { fg = c.cinder },
    GrugFarInputLabel      = { fg = c.frost },
    GrugFarResultsHeader   = { fg = c.ember, bold = true },
    GrugFarResultsPath     = { fg = c.frost, underline = true },
    GrugFarResultsLineNo   = { fg = c.gutter },
    GrugFarResultsMatch    = { bg = c.bg3 },
    GrugFarResultsMatchAdded = { fg = c.ok },
    GrugFarResultsMatchRemoved = { fg = c.error },

    -- diffview
    DiffviewFilePanelTitle    = { fg = c.ember, bold = true },
    DiffviewFilePanelCounter  = { fg = c.ember },
    DiffviewFilePanelFileName = { fg = c.fg },
    DiffviewFilePanelPath     = { fg = c.comment },
    DiffviewFilePanelInsertions = { fg = c.ok },
    DiffviewFilePanelDeletions  = { fg = c.error },
    DiffviewNormal            = { fg = c.fg_dim, bg = c.bg_deep },
    DiffviewStatusAdded       = { fg = c.ok },
    DiffviewStatusModified    = { fg = c.info },
    DiffviewStatusDeleted     = { fg = c.error },
    DiffviewStatusUntracked   = { fg = c.comment },
    DiffviewDim1              = { fg = c.gutter },

    -- illuminate / treesitter-context
    IlluminatedWordText  = { bg = c.bg2 },
    IlluminatedWordRead  = { bg = c.bg2 },
    IlluminatedWordWrite = { bg = c.bg2 },
    TreesitterContext          = { bg = c.bg1 },
    TreesitterContextLineNumber = { fg = c.gutter },
    TreesitterContextBottom    = { underline = true, sp = c.bg3 },

    -- rainbow-delimiters. Seven slots out of five pigments, so the last two
    -- borrow from the semantic family. Nesting depth needs distinctness more
    -- than it needs role purity, and brackets carry no role to confuse.
    RainbowDelimiterRed    = { fg = c.cinder },
    RainbowDelimiterYellow = { fg = c.brass },
    RainbowDelimiterGreen  = { fg = c.sap },
    RainbowDelimiterCyan   = { fg = c.frost },
    RainbowDelimiterBlue   = { fg = c.info },
    RainbowDelimiterViolet = { fg = c.hint },
    RainbowDelimiterOrange = { fg = c.ember },
  }
end

return M
