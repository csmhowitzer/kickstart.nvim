-- INFO: This provides a keymap to allow a build of the C# solution

local buildSlnCmd = { 'dotnet', 'build' }
local cleanSlnCmd = { 'dotnet', 'msbuild', '-t:clean' }
local rebuildSlnCmd = { 'dotnet', 'msbuild', '-t:rebuild' }
local addPackageCmd = { 'dotnet', 'add', '[PROJECT]', 'package', '<package name>' }

-- NOTE: This is the dotnet sdk flavor of Clean/Rebuild as this commadn is not directly present in
-- the current dotnet sdk
--local rebuildSlnCmd = { 'dotnet', 'build', '--no-incremental' }

-- find the .csproj root folder for the given file the buffer resides in
local find_proj_root = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufPath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
  vim.api.nvim_set_current_dir(bufPath)
  return vim.fs.root(bufPath, function(name)
    return name:match '%.csproj$' ~= nil
  end)
end

vim.notify = require 'notify'

local formatText = function(data)
  local ret = ''
  for _, t in pairs(data) do
    ret = ret .. '\n' .. t
  end
  return ret
end

local dotnetCmd = function(command)
  vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.notify(formatText(data), vim.log.levels.INFO, {
        title = 'DotNet CLI Message',
      })
    end,
  })
end

local executeBuild = function(command)
  local bufnr = vim.api.nvim_get_current_buf()
  local type = vim.filetype.match { buf = bufnr }

  if type == 'cs' then
    dotnetCmd(command)
  end
end

vim.keymap.set('n', '<C-b>b', function()
  executeBuild(buildSlnCmd)
end, { desc = '[B]uild Solution' })

vim.keymap.set('n', '<C-b>r', function()
  executeBuild(rebuildSlnCmd)
end, { desc = '[R]ebuild Solution' })

vim.keymap.set('n', '<C-b>c', function()
  executeBuild(cleanSlnCmd)
end, { desc = '[C]lean Solution' })

vim.keymap.set('n', '<leader>dap', function()
  vim.ui.input({ prompt = 'Package name: ' }, function(input)
    addPackageCmd[3] = find_proj_root()
    addPackageCmd[5] = input
    executeBuild(addPackageCmd)
  end)
end, { desc = '[B]uild Solution' })
