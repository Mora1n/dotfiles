local number_toggle_augroup = vim.api.nvim_create_augroup('NumberToggle', { clear = true })

-- Use relative numbers in normal mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = number_toggle_augroup,
  pattern = "*",
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = true
    end
  end,
})

-- Use absolute numbers in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  group = number_toggle_augroup,
  pattern = "*",
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
    end
  end,
})

-- Performance optimizations for large files
local perf_augroup = vim.api.nvim_create_augroup('PerformanceOptimizations', { clear = true })

-- Disable cursorline in insert mode for better performance
vim.api.nvim_create_autocmd('InsertEnter', {
  group = perf_augroup,
  pattern = '*',
  callback = function()
    vim.opt.cursorline = false
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = perf_augroup,
  pattern = '*',
  callback = function()
    vim.opt.cursorline = true
  end,
})
