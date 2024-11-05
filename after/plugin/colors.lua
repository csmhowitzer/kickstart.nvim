function ToggleThru()
  -- we want to change transparent background

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = 'none' })
end

function ToggleDark()
  -- we want to change transparent background

  vim.api.nvim_set_hl(0, 'Normal', { bg = '#1e1e2e' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1e1e2e' })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = '#1e1e2e' })
end

vim.keymap.set('n', '<leader>tt', '<cmd>lua ToggleThru()<CR>', { desc = 'Toggle Transparent background (transparent)' })
vim.keymap.set('n', '<leader>td', '<cmd>lua ToggleDark()<CR>', { desc = 'Toggle Transparent background (dark color)' })
