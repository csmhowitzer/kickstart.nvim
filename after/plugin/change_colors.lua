-- will want to update this to auto run on load rather than functions to call

function ToggleThru()
  -- we want to change transparent background

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = '#6078A0' })
  -- vim.api.nvim_set_hl(0, 'CursorLineNr', )
  vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = '#6078A0' })
end

function ToggleDark()
  -- we want to change transparent background

  -- catppuccin palletttte original bg color #1e1e2e
  vim.api.nvim_set_hl(0, 'Normal', { bg = '#060609' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#060609' })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = '#060609' })
end

vim.keymap.set('n', '<leader>tt', '<cmd>lua ToggleThru()<CR>', { desc = 'Toggle Transparent background (transparent)' })
vim.keymap.set('n', '<leader>td', '<cmd>lua ToggleDark()<CR>', { desc = 'Toggle Transparent background (dark color)' })

function DefaultSchemeSettings()
  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'SignColumn', { fg = '#CB444A' }) -- a pinkish color

  -- You can configure highlights by doing something like
  vim.cmd.hi 'Comment gui=italic'
end

vim.keymap.set('n', '<leader>cp1', function()
  require('catppuccin').setup {
    flavour = 'mocha',
  }
  vim.cmd.colorscheme 'catppuccin'
  ToggleThru()
  DefaultSchemeSettings()
end, { desc = 'Set style to Mocha' })
vim.keymap.set('n', '<leader>cp2', function()
  require('catppuccin').setup {
    flavour = 'latte',
  }
  vim.cmd.colorscheme 'catppuccin'
  ToggleThru()
  DefaultSchemeSettings()
end, { desc = 'Set style to Latte' })
vim.keymap.set('n', '<leader>cp3', function()
  require('catppuccin').setup {
    flavour = 'macchiato',
  }
  vim.cmd.colorscheme 'catppuccin'
  ToggleThru()
  DefaultSchemeSettings()
end, { desc = 'Set style to Macchiato' })
vim.keymap.set('n', '<leader>cp4', function()
  require('catppuccin').setup {
    flavour = 'frappe',
  }
  vim.cmd.colorscheme 'catppuccin'
  ToggleThru()
  DefaultSchemeSettings()
end, { desc = 'Set style to Frappe' })
