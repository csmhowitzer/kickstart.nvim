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
          name = 'TheAbyss',
          path = '~/vaults/TheAbyss',
        },
        {
          name = 'personal',
          path = '~/vaults/personal',
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
      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      ---@param url string
      follow_url_func = function(url)
        -- Open the URL in the default web browser.
        vim.fn.jobstart { 'open', url } -- Mac OS
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
        -- vim.ui.open(url) -- need Neovim 0.10.0+
      end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
      -- file it will be ignored but you can customize this behavior here.
      ---@param img string
      follow_img_func = function(img)
        vim.fn.jobstart { 'qlmanage', '-p', img } -- Mac OS quick look preview
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
      end,
      -- see below for full list of options 👇
    }

    opt.conceallevel = 2
    --local builtin = require 'obsidian.Client'
    -- The below is what works, trying another way
    vim.keymap.set('n', '--', '<CMD>ObsidianNew<CR>', { desc = 'Open [N]ew Obsidian note' })
    -- vim.keymap.set('n', '-', builtin.command('ObsidianNew', vim.fn.input 'Name: '), { desc = 'Open [N]ew Obsidian note' })
    vim.keymap.set('n', '-t', '<CMD>ObsidianToday<CR>', { desc = 'Opens a new Obsidian daily for [T]oday' })
    vim.keymap.set('n', '-s', '<CMD>ObsidianSearch<CR>', { desc = 'Obsidian [S]earch' })
    vim.keymap.set('n', '-w', '<CMD>ObsidianWorkspace<CR>', { desc = 'Obsidian Select [W]orkspace' })
    -- Also, hitting <CR> on any line in Normal mode will do this
    vim.keymap.set('n', '-c', '<CMD>ObsidianToggleCheckbox<CR>', { desc = 'Obsidian Toggle [C]heckbox' })
    vim.keymap.set('n', '-fl', '<CMD>ObsidianFollowLink<CR>', { desc = 'Obsidian [F]ollow [L]ink' })
    vim.keymap.set('v', '<leader>l', '<CMD>ObsidianLink<CR>', { desc = 'Obsidian [L]ink' })
    vim.keymap.set('v', '<leader>ln', '<CMD>ObsidianLinkNew<CR>', { desc = 'Obsidian [L]ink [N]ew' })
    vim.keymap.set('v', '<leader>e', '<CMD>ObsidianExtractNote<CR>', { desc = 'Obsidian [E]xtract Note' })
  end,
}
