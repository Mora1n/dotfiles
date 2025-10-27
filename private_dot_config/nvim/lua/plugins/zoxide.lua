return {
  'nanotee/zoxide.vim',
  event = 'VeryLazy',
  config = function()
    -- Set zoxide command prefix (optional)
    vim.g.zoxide_prefix = 'z'

    -- Key mappings for zoxide
    vim.keymap.set('n', '<leader>z', '<cmd>Z<cr>', { desc = 'Zoxide jump' })
    vim.keymap.set('n', '<leader>zi', '<cmd>Zi<cr>', { desc = 'Zoxide interactive' })
  end,
}
