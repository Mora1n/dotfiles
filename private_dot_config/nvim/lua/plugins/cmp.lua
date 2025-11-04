return {
  -- 核心补全插件
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- 补全源
    'hrsh7th/cmp-buffer',       -- 缓冲区补全
    'hrsh7th/cmp-path',         -- 路径补全
    'hrsh7th/cmp-cmdline',      -- 命令行补全

    -- 代码片段引擎
    'L3MON4D3/LuaSnip',         -- 片段引擎
    'saadparwaiz1/cmp_luasnip', -- 片段补全源
    'rafamadriz/friendly-snippets', -- 预定义片段集合

    -- 图标支持
    'onsails/lspkind.nvim',     -- 补全菜单图标
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    -- 加载预定义片段
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup({
      -- 片段引擎配置
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- 补全窗口样式
      window = {
        completion = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
        }),
        documentation = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
        }),
      },

      -- 快捷键映射
      mapping = cmp.mapping.preset.insert({
        -- 滚动文档
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- 手动触发补全
        ['<C-Space>'] = cmp.mapping.complete(),

        -- 关闭补全菜单
        ['<C-e>'] = cmp.mapping.abort(),

        -- 确认选择
        ['<CR>'] = cmp.mapping.confirm({ select = true }),

        -- Tab 补全
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),

        -- Shift-Tab 反向补全
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),

      -- 补全源配置
      sources = cmp.config.sources({
        { name = 'luasnip', priority = 1000 },
        { name = 'buffer', priority = 750, keyword_length = 3 },
        { name = 'path', priority = 500 },
      }),

      -- 格式化（显示图标和类型）
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
          show_labelDetails = true,
          before = function(entry, vim_item)
            return vim_item
          end,
        }),
      },

      -- 实验性功能
      experimental = {
        ghost_text = true, -- 显示幽灵文本（预览补全）
      },
    })

    -- 命令行 '/' 搜索补全
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })

    -- 命令行 '?' 搜索补全
    cmp.setup.cmdline('?', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })

    -- 命令行 ':' 命令补全
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
      }, {
        { name = 'cmdline', keyword_length = 2 },
      }),
    })
  end,
}
