return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects', -- 增强文本对象
  },
  config = function()
    require('nvim-treesitter.configs').setup({
      -- 安装常用语言解析器
      ensure_installed = {
        -- 核心
        'c', 'lua', 'vim', 'vimdoc', 'query',
        -- Web 开发
        'javascript', 'typescript', 'tsx', 'html', 'css', 'json',
        -- Python
        'python',
        -- 其他常用
        'bash', 'markdown', 'markdown_inline', 'regex',
        'yaml', 'toml',
      },
      sync_install = false,
      auto_install = true,

      -- 语法高亮
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      -- 增量选择
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<S-CR>',
          node_decremental = '<BS>',
        },
      },

      -- 智能缩进
      indent = {
        enable = true,
        -- Python 缩进由 vim-python-pep8-indent 处理
        disable = { 'python' },
      },

      -- 文本对象
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
      },
    })
  end,
}
