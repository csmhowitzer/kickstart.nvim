-- INFO: Autocommand set up to format on save using csharpier
-- csharpier is a dotnet tool installed globally on the machine
--
-- Also added a user command to format the entire solution

---@source nvim/lua/config/plugins/utils.lua
local utils = require 'config.plugins.utils'

-- Restarts the LSP attached to the buffer
local run_on_exit = function()
  vim.cmd [[e]]
  vim.cmd [[LspRestart]]
end

---Runs csharpier on the current buffer
---@param path string? : the path to the file or folder to format
local run_csharpier = function(path)
  path = path or utils.get_path()
  vim.fn.jobstart({ 'dotnet', 'csharpier', path }, {
    stdout_buffered = true,
    on_exit = function()
      run_on_exit()
    end,
  })
end

---Adds, organizes, and removes using directives from C# files
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
