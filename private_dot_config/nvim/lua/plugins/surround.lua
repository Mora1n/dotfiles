return {
  'kylechui/nvim-surround',
  version = '*',
  keys = {
    { 'ys', mode = 'n', desc = 'Add surround' },
    { 'yss', mode = 'n', desc = 'Add surround to line' },
    { 'yS', mode = 'n', desc = 'Add surround on new lines' },
    { 'ySS', mode = 'n', desc = 'Add surround to line on new lines' },
    { 'ds', mode = 'n', desc = 'Delete surround' },
    { 'cs', mode = 'n', desc = 'Change surround' },
    { 'S', mode = 'v', desc = 'Add surround' },
    { 'gS', mode = 'v', desc = 'Add surround on new lines' },
  },
  opts = {},
}
