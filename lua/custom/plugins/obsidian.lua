-- return {
--   {
--     'epwalsh/obsidian.nvim',
--     dependencies = { 'nvim-lua/plenary.nvim' },
--     version = '*',
--     lazy = true,
--     ft = 'markdown',
--     --opts = {
--     --  workspaces = {
--     --    name = 'personal',
--     --    path = '~/LocalDocs/TheAbyss',
--     --  },
--     --},
--   },
-- }

return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   'BufReadPre '
  --     .. vim.fn.expand '~'
  --     .. '/vaults/personal/*.md',
  --   'BufNewFile ' .. vim.fn.expand '~' .. '/vaults/personal/*.md',
  -- },
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',

    -- see below for full list of optional dependencies 👇
  },
  -- opts = {
  config = function()
    local opt = vim.opt
    require('obsidian').setup {
      workspaces = {
        {
          name = 'personal',
          path = '~/vaults/personal',
        },
        {
          name = 'TheAbyss',
          path = '~/LocalDocs/TheAbyss',
        },
        {
          name = 'work',
          path = '~/vaults/work',
        },
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      -- see below for full list of options 👇
    }
    opt.conceallevel = 1
    -- local buf = vim.api.nvim_create_buf(false, true)
    -- local win = vim.api.nvim_open_win(buf, false, {
    --   row = 0,
    --   col = 0,
    --   width = 40,
    --   height = 50,
    --   style = 'minimal',
    --   title = 'Hi Mom',
    -- })
    -- vim.api.nvim_buf_set_keymap(win, 'n', '-', '<CMD>ObsidianNew<CR>', { desc = 'Open new obsidian note' })
    vim.keymap.set('n', '-', '<CMD>ObsidianNew<CR>', { desc = 'Open new Obsidian note' })
    vim.keymap.set('n', '-t', '<CMD>ObsidianToday<CR>', { desc = 'Opens a new Obsidian daily for [T]oday' })
  end,
}
