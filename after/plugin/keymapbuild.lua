-- INFO: This provides a keymap to allow a build of the C# solution

vim.notify = require 'notify'

local command = { 'dotnet', 'build' }

local formatText = function(data)
  local ret = ''
  for _, t in pairs(data) do
    ret = ret .. '\n' .. t
  end
  return ret
end

local dotnetBuild = function()
  vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.notify(formatText(data), vim.log.levels.INFO, {
        title = 'Build Message',
      })
    end,
  })
end

local executeBuild = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local type = vim.filetype.match { buf = bufnr }

  if type == 'cs' then
    dotnetBuild()
  end
end

vim.keymap.set('n', '<C-b>b', function()
  executeBuild()
end, { desc = '[B]uild solution' })
