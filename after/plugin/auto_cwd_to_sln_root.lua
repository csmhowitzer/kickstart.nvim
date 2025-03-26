-- INFO: Auto-Switch cwd when entering a new .cs file
-- On BufEnter
--    switch the cwd to the .sln root path

local utils = require 'config.plugins.utils'

-- autocommand .cs files
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('CS_Cwd_Switch', {
    clear = true,
  }),
  pattern = '*.cs',
  callback = function()
    local slnPath = utils.find_sln_root()
    if slnPath ~= nil and slnPath ~= '' then
    end
  end,
})

-- autocommand front-end files
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('FE_Cwd_Switch', {
    clear = true,
  }),
  pattern = '*.js, *.jsx, *.ts, *.tsx, *.vue',
  callback = function()
    utils.set_cwd()
  end,
})

-- autocommand .md files
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('MD_Cwd_Switch', {
    clear = true,
  }),
  pattern = '*.md',
  callback = function()
    utils.set_cwd()
  end,
})
