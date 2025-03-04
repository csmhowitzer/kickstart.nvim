-- INFO: This provides a keymap to allow a build of the C# solution

local buildSlnCmd = { 'dotnet', 'build' }
local cleanSlnCmd = { 'dotnet', 'msbuild', '-t:clean' }
local rebuildSlnCmd = { 'dotnet', 'msbuild', '-t:rebuild' }
local addPackageCmd = { 'dotnet', 'add', '[PROJECT]', 'package', '<package name>' }
local addProjRefCmd = { 'dotnet', 'add', 'reference', '[PROJECT_PATH]' }

-- NOTE: This is the dotnet sdk flavor of Clean/Rebuild as this commadn is not directly present in
-- the current dotnet sdk
--local rebuildSlnCmd = { 'dotnet', 'build', '--no-incremental' }

vim.notify = require 'notify'

---formats the text to bed displayed by the notify popupcomment
---@param data any : the console output from the command
---@return string
local formatText = function(data)
  local ret = ''
  for _, t in pairs(data) do
    ret = ret .. '\n' .. t
  end
  return ret
end

---get path returns the current buffer's absolute folder pathcomment
---@return string
local get_path = function()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
end

---find the .csproj root folder for the given file the buffer resides incomment
---@return string?
local find_proj_root = function()
  local bufPath = get_path()
  assert(bufPath ~= nil, 'invalid path provided')
  vim.api.nvim_set_current_dir(bufPath)
  return vim.fs.root(bufPath, function(name)
    return name:match '%.csproj$' ~= nil
  end)
end

---find the .sln root folder for the given buffercomment
---@return string?
local find_sln_root = function()
  local path = get_path()
  assert(path ~= nil, 'invalid path provided')
  return vim.fs.root(path, function(name)
    return name:match '%.sln$' ~= nil
  end)
end

---commands that will be ran after the dotnet command is calledcomment
---@param reloadBuf any
local run_on_exit = function(reloadBuf)
  if reloadBuf then
    vim.cmd [[e]]
    vim.cmd [[LspRestart]]
  end
end

---Runs the specified dotnet sdk command
---@param command any
---@param reloadBuf any
local dotnetCmd = function(command, reloadBuf)
  vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.notify(formatText(data), vim.log.levels.INFO, {
        title = 'DotNet CLI Message',
      })
    end,
    on_exit = function()
      run_on_exit(reloadBuf)
    end,
  })
end

--- Executes the input command
---@param command any : the dotnet command to run, each word is a item in the table
---@param reloadBuf? boolean : reloads the buffer after the command executes
local executeCmd = function(command, reloadBuf)
  local bufnr = vim.api.nvim_get_current_buf()
  local type = vim.filetype.match { buf = bufnr }

  if type == 'cs' then
    dotnetCmd(command, reloadBuf)
  end
end

---Formats the selected list item
---@param selected any : the list item
---@return string
local format_selection = function(selected)
  local list = vim.split(selected, '/')
  return string.gsub(list[#list], '.csproj', '')
end

---Sets the current working directory to the current buffer
local set_cwd = function()
  local bufPath = get_path()
  assert(bufPath ~= nil, 'invalid path provided')
  vim.api.nvim_set_current_dir(bufPath)
end

---Opens a list of C# projects to add as a reference to the current project
local select_cs_proj_ref = function()
  local root = find_sln_root()
  local files = vim.fs.find(function(name)
    return name:match '%.csproj$' ~= nil
  end, { limit = math.huge, type = 'file', path = root })
  vim.ui.select(files, {
    prompt = 'Select C# Project',
    format_item = function(item)
      return format_selection(item)
    end,
  }, function(selected)
    if selected then
      local projName = format_selection(selected)
      set_cwd()
      addProjRefCmd[4] = '../' .. projName .. '/' .. projName .. '.csproj'
      executeCmd(addProjRefCmd)
    end
  end)
end

vim.keymap.set('n', '<C-b>b', function()
  executeCmd(buildSlnCmd)
end, { desc = '[B]uild Solution' })

vim.keymap.set('n', '<C-b>r', function()
  executeCmd(rebuildSlnCmd)
end, { desc = '[R]ebuild Solution' })

vim.keymap.set('n', '<C-b>c', function()
  executeCmd(cleanSlnCmd)
end, { desc = '[C]lean Solution' })

vim.keymap.set('n', '<leader>dap', function()
  vim.ui.input({ prompt = 'Package name: ' }, function(input)
    addPackageCmd[3] = find_proj_root()
    addPackageCmd[5] = input
    executeCmd(addPackageCmd)
  end)
end, { desc = '[B]uild Solution' })

-- keymaps that are CS only
-- keymaps that aren't CLI functions
vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
  group = vim.api.nvim_create_augroup('CS_Only_Keymaps', {
    clear = true,
  }),
  pattern = { '*.cs', '*.csproj', '*.sln' },
  callback = function()
    vim.keymap.set('n', '<leader>gd', function()
      require('csharp').go_to_definition()
    end, { desc = '[G]oto [D]efinition (Roslyn)' })
    vim.keymap.set('n', '<leader>dbg', function()
      require('csharp').debug_project()
    end, { desc = '[D]e[b]u[g] project' })
    vim.keymap.set('n', '<leader>drp', function()
      select_cs_proj_ref()
    end, { desc = '[D]otnet [P]roject [R]eference' })
  end,
})

-- general keymaps
vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle, { desc = '[U]ndotree [T]oggle' })
