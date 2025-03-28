-- INFO: Autocommand set up to format on save using csharpier
-- csharpier is a dotnet tool installed globally on the machine
--
-- Also added a user command to format the entire solution

---@source nvim/lua/config/plugins/utils.lua
local utils = require 'config.plugins.utils'

---@class CSharpFormatter
local M = {}

-- LSP management
function M.restart_lsp()
  vim.cmd [[e]]
  vim.cmd [[LspRestart]]
end

-- Formatters
---@param path string? Path to file or folder to format
function M.format_with_csharpier(path)
  path = path or utils.get_path()
  vim.fn.jobstart({ 'dotnet', 'csharpier', path }, {
    stdout_buffered = true,
    on_exit = function()
      M.restart_lsp()
    end,
  })
end

function M.organize_usings()
  require('csharp').fix_usings()
end

-- Setup autocommands
function M.setup_format_on_save()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('CSLspAction', { clear = true }),
    pattern = '*.cs',
    callback = function()
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('CSFmtOnSave', { clear = true }),
        pattern = '*.cs',
        callback = function()
          M.format_with_csharpier()
          M.organize_usings()
        end,
      })
    end,
  })
end

-- User commands
function M.setup_commands()
  vim.api.nvim_create_user_command('CSCleanUp', function()
    M.format_with_csharpier(utils.find_sln_root())
  end, { desc = 'Formats C# files for a given solution' })
end

-- Initialize
M.setup_format_on_save()
M.setup_commands()

return M
