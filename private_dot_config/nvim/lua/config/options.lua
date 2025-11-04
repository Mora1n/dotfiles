-- [[ Setting options ]]
-- See `:help option-list`

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse & UI
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- Clipboard
vim.opt.clipboard = 'unnamedplus'

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.copyindent = true
vim.opt.breakindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Scrolling
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Files & Buffers
vim.opt.undofile = true
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Whitespace display
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Line wrapping
vim.opt.wrap = false
vim.opt.linebreak = true

-- Completion
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.pumheight = 10

-- Misc
vim.opt.confirm = true
vim.opt.encoding = 'utf-8'
vim.opt.backspace = 'indent,eol,start'
