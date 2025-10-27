return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  config = function()
    require('fzf-lua').setup({
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          default = 'bat',
          border = 'border',
          wrap = 'nowrap',
          hidden = 'nohidden',
          vertical = 'down:45%',
          horizontal = 'right:60%',
          layout = 'flex',
        },
      },
    })

    -- Key mappings
    vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
    vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>', { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'Find buffers' })
    vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<cr>', { desc = 'Help tags' })
    vim.keymap.set('n', '<leader>fo', '<cmd>FzfLua oldfiles<cr>', { desc = 'Recent files' })
    vim.keymap.set('n', '<leader>fc', '<cmd>FzfLua commands<cr>', { desc = 'Commands' })
    vim.keymap.set('n', '<leader>fk', '<cmd>FzfLua keymaps<cr>', { desc = 'Keymaps' })
  end,
}
