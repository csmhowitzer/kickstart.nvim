-- INFO: Autocommand set up to format on save using csharpier
-- csharpier is a dotnet tool installed globally on the machine
--
-- Also added a user command to format the entire solution

local utils = require 'after.plugin.utils'

local run_on_exit = function()
  vim.cmd [[e]]
  vim.cmd [[LspRestart]]
end

local run_csharpier = function(path)
  vim.fn.jobstart({ 'dotnet', 'csharpier', path }, {
    stdout_buffered = true,
    on_exit = function()
      run_on_exit()
    end,
  })
end

local run_csharp_nvim = function()
  require('csharp').fix_usings()
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('CSLspActions', {
    clear = true,
  }),
  pattern = '*.cs',
  callback = function()
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('CSFmtOnSave', {
        clear = true,
      }),
      pattern = '*.cs',
      callback = function()
        run_csharpier(utils.get_path())
        run_csharp_nvim()
      end,
    })
  end,
})

vim.api.nvim_create_user_command('CSCleanUp', function()
  run_csharpier(utils.find_sln_root())
end, {})
