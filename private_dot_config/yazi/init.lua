-- ╭─────────────────────────────────────────────────────────╮
-- │                  Yazi Initialization                    │
-- ╰─────────────────────────────────────────────────────────╯

-- ═══════════════════════════════════════════════════════════
--  UI Enhancements
-- ═══════════════════════════════════════════════════════════

-- Integrate Starship prompt at bottom
require("starship"):setup()

-- Enable full border display
require("full-border"):setup()

-- ═══════════════════════════════════════════════════════════
--  Vim-style Relative Motions
-- ═══════════════════════════════════════════════════════════
require("relative-motions"):setup({
    show_numbers = "relative_absolute",
    show_motion = true
})
