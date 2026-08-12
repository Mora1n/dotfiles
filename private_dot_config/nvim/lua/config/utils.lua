-- Shared utilities for plugin configuration
local M = {}

-- Common event groups for lazy loading
M.events = {
  file = { 'BufReadPre', 'BufNewFile' },
  insert = 'InsertEnter',
  lazy = 'VeryLazy',
  start = 'VimEnter',
}

-- Check if running in VSCode
M.not_vscode = vim.g.vscode == nil

-- Common border style
M.border = 'rounded'

-- LSP keymaps setup (reusable across LSP configs)
function M.setup_lsp_keymaps(bufnr)
  local base_opts = { buffer = bufnr, noremap = true, silent = true }
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, vim.tbl_extend('force', base_opts, { desc = desc }))
  end

  map('gd', vim.lsp.buf.definition, 'Go to definition')
  map('gD', vim.lsp.buf.declaration, 'Go to declaration')
  map('gr', vim.lsp.buf.references, 'Go to references')
  map('gi', vim.lsp.buf.implementation, 'Go to implementation')
  map('K', vim.lsp.buf.hover, 'Hover documentation')
  map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
  map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
  map('<leader>cf', function()
    vim.lsp.buf.format({ async = true })
  end, 'Format buffer')
end

-- LSP document highlight setup (reusable)
function M.setup_lsp_highlight(client, bufnr)
  if client.supports_method('textDocument/documentHighlight') then
    local group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

-- Root directory finder for LSP
function M.find_root(markers)
  return function(fname)
    return vim.fs.root(fname, markers)
  end
end

-- Get LSP capabilities with blink.cmp integration
function M.get_lsp_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if pcall(require, 'blink.cmp') then
    capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
  end
  return capabilities
end

return M
