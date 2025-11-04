return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local autopairs = require('nvim-autopairs')

    autopairs.setup({
      check_ts = true, -- 使用 treesitter 检查
      ts_config = {
        lua = { 'string' }, -- 在 lua 字符串中不自动配对
        javascript = { 'template_string' },
        java = false, -- 不在 java 中检查 treesitter
      },
      disable_filetype = { "TelescopePrompt", "vim" },
      fast_wrap = {
        map = '<M-e>', -- Alt+e 快速包裹
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey = 'Comment',
      },
    })

    -- 与 nvim-cmp 集成
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')

    -- 在确认补全时自动插入括号
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
