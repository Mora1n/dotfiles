local utils = require('config.utils')

return {
  {
    'saghen/blink.cmp',
    optional = true,
  },
  {
    name = 'native-lsp',
    dir = vim.fn.stdpath('config'),
    event = utils.events.file,
    enabled = utils.not_vscode,
    config = function()
      local lsp_dir = vim.fn.stdpath('config') .. '/lsp'
      local capabilities = utils.get_lsp_capabilities()

      -- Python virtual environment detection
      local function find_python_venv(root_dir)
        local venv_paths = { '.venv', 'venv', 'env' }
        for _, venv in ipairs(venv_paths) do
          local venv_python = root_dir .. '/' .. venv .. '/bin/python'
          if vim.fn.filereadable(venv_python) == 1 then
            return venv_python
          end
        end
        return vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. '/bin/python' or 'python'
      end

      -- Load ty.lua for Python LSP
      local ty_config = dofile(lsp_dir .. '/ty.lua')
      if ty_config and vim.fn.executable('ty') == 1 then
        vim.lsp.config('ty', {
          cmd = ty_config.cmd,
          filetypes = ty_config.filetypes,
          root_dir = utils.find_root(ty_config.root_markers),
          capabilities = capabilities,
          flags = { debounce_text_changes = 150 },
          on_attach = function(client, bufnr)
            utils.setup_lsp_keymaps(bufnr)
            utils.setup_lsp_highlight(client, bufnr)
          end,
        })

        -- Auto-start LSP for Python files
        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'python',
          callback = function(args)
            local root = utils.find_root(ty_config.root_markers)(vim.api.nvim_buf_get_name(args.buf))
            if root then
              vim.lsp.start({
                name = 'ty',
                cmd = ty_config.cmd,
                root_dir = root,
                capabilities = capabilities,
                flags = { debounce_text_changes = 150 },
              })
            end
          end,
        })
      end

      -- Load lua_ls.lua for Lua LSP
      local lua_ls_config = dofile(lsp_dir .. '/lua_ls.lua')
      if lua_ls_config and vim.fn.executable('lua-language-server') == 1 then
        vim.lsp.config('lua_ls', {
          cmd = lua_ls_config.cmd,
          filetypes = lua_ls_config.filetypes,
          root_dir = utils.find_root(lua_ls_config.root_markers),
          capabilities = capabilities,
          settings = lua_ls_config.settings,
          on_attach = function(client, bufnr)
            utils.setup_lsp_keymaps(bufnr)
            utils.setup_lsp_highlight(client, bufnr)
          end,
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'lua',
          callback = function(args)
            local root = utils.find_root(lua_ls_config.root_markers)(vim.api.nvim_buf_get_name(args.buf))
            if root then
              vim.lsp.start({
                name = 'lua_ls',
                cmd = lua_ls_config.cmd,
                root_dir = root,
                capabilities = capabilities,
                settings = lua_ls_config.settings,
              })
            end
          end,
        })
      end

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = { prefix = '●', source = 'if_many' },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = utils.border, source = 'always' },
      })
    end,
  },
}
