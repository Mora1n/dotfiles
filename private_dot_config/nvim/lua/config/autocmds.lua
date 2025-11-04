-- [[ Autocommands ]]

-- Toggle relative line numbers based on mode
local number_toggle = vim.api.nvim_create_augroup('NumberToggle', { clear = true })

vim.api.nvim_create_autocmd('InsertEnter', {
  group = number_toggle,
  pattern = '*',
  callback = function()
    vim.opt.relativenumber = false
  end,
  desc = 'Use absolute numbers in insert mode',
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = number_toggle,
  pattern = '*',
  callback = function()
    vim.opt.relativenumber = true
  end,
  desc = 'Use relative numbers in normal mode',
})

-- Highlight yanked text
local highlight_yank = vim.api.nvim_create_augroup('HighlightYank', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_yank,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
  desc = 'Highlight yanked text',
})

-- Jump to last edit position when opening files
local last_position = vim.api.nvim_create_augroup('LastPosition', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = last_position,
  pattern = '*',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = 'Jump to last edit position',
})

-- Auto-create directories when saving files
local auto_mkdir = vim.api.nvim_create_augroup('AutoMkdir', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = auto_mkdir,
  pattern = '*',
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
  desc = 'Auto-create directories when saving',
})

-- Remove trailing whitespace on save
local trim_whitespace = vim.api.nvim_create_augroup('TrimWhitespace', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = trim_whitespace,
  pattern = '*',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
  desc = 'Remove trailing whitespace on save',
})

-- Python-specific settings
local python_settings = vim.api.nvim_create_augroup('PythonSettings', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = python_settings,
  pattern = 'python',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
  desc = 'Set Python indentation to 4 spaces',
})
