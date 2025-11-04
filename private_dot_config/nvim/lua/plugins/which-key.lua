return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    local wk = require('which-key')

    wk.setup({
      preset = 'modern',
      delay = 500, -- delay before showing the popup (ms)
      icons = {
        breadcrumb = '»', -- symbol used in the command line area
        separator = '➜', -- symbol used between a key and its label
        group = '+', -- symbol prepended to a group
      },
      win = {
        border = 'rounded', -- none, single, double, shadow, rounded
        padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
      },
    })

    -- Document existing key chains
    wk.add({
      -- Find group
      { '<leader>f', group = 'Find' },
      { '<leader>ff', desc = 'Find files' },
      { '<leader>fg', desc = 'Live grep' },
      { '<leader>fb', desc = 'Find buffers' },
      { '<leader>fo', desc = 'Recent files' },
      { '<leader>fw', desc = 'Grep word under cursor' },
      { '<leader>fr', desc = 'Resume last search' },
      { '<leader>f/', desc = 'Search in current buffer' },
      { '<leader>fh', desc = 'Help tags' },

      -- Comment keybindings
      { 'gc', group = 'Comment' },
      { 'gcc', desc = 'Toggle comment line' },
      { 'gbc', desc = 'Toggle block comment' },
      { 'gcO', desc = 'Comment above' },
      { 'gco', desc = 'Comment below' },
      { 'gcA', desc = 'Comment end of line' },
      { '<C-_>', desc = 'Toggle comment (Ctrl+/)' },
    })
  end,
}
