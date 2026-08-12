local utils = require('config.utils')

return {
  'folke/which-key.nvim',
  event = utils.events.lazy,
  opts = {
    preset = 'modern',
    delay = 500,
    icons = {
      breadcrumb = '»',
      separator = '➜',
      group = '+',
    },
    win = {
      border = utils.border,
      padding = { 1, 2 },
    },
  },
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)

    -- Label prefix groups that do not have a concrete mapping of their own.
    wk.add({
      { '<leader>f', group = 'Find' },
      { '<leader>b', group = 'Buffer' },
      { '<leader>w', group = 'Window' },
      { '<leader>c', group = 'Code' },
      { '<leader>x', group = 'Diagnostics' },
      { 'gc', group = 'Comment', mode = { 'n', 'x' } },
      { 'gb', group = 'Block comment', mode = { 'n', 'x' } },
    })
  end,
}
