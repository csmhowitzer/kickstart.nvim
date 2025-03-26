-- Helper class with useful utility functions
---@module 'utils'
local M = {}

-- Get the current buffer's file name without extension
---@return string
function M.get_current_filename()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t:r')
end

-- Get the current buffer's full path
---@return string
function M.get_full_path()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(bufnr)
end

-- Check if a file exists
---@param path string: path to the file
---@return boolean
function M.file_exists(path)
  local f = io.open(path, 'r')
  if f then
    io.close(f)
    return true
  end
  return false
end

-- Find project root based on pattern
---@param pattern string: pattern to match (e.g., "%.git$", "%.sln$")
---@return string?
function M.find_root(pattern)
  local path = M.get_full_path()
  local dir = vim.fn.fnamemodify(path, ':h')
  return vim.fs.root(dir, function(name)
    return name:match(pattern) ~= nil
  end)
end

-- Check if current file is of specific type
---@param filetype string: filetype to check
---@return boolean
function M.is_filetype(filetype)
  return vim.bo.filetype == filetype
end

---Get path returns the current buffer's absolute folder path
---@return string
function M.get_path()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
end

---Find the .csproj root folder for the given file the buffer resides in
---@param path string? : path to find proj root for
---@return string?
function M.find_proj_root(path)
  path = path or M.get_path()
  assert(path ~= nil, 'invalid path provided')
  vim.api.nvim_set_current_dir(path)
  return vim.fs.root(path, function(name)
    return name:match '%.csproj$' ~= nil
  end)
end

---Find the .sln root folder for the given C# buffer
---@param path string? : path to find sln root for
---@return string?
function M.find_sln_root(path)
  path = path or M.get_path()
  assert(path ~= nil, 'invalid path provided')
  return vim.fs.root(path, function(name)
    return name:match '%.sln$' ~= nil
  end)
end

---Sets the current working directory to the current buffer
---@param path string? : path to set cwd to
function M.set_cwd(path)
  path = path or M.get_path()
  assert(path ~= nil, 'invalid path provided')
  vim.api.nvim_set_current_dir(path)
end

---Reads the content of a file.
---@param path string : path to the file
---@return string?
function M.read_file_content(path)
  local f = io.open(path, 'r')
  if not f then
    return
  end
  local content = f:read '*all'
  f:close()
  return content
end

---Create a file on the home path if it doens't exist
---@param path string : path to the file
---@return boolean
---@return string?
---@Usage create_home_dir_if_not_exists('.config/nvim/init.lua')
function M.create_home_dir_if_not_exists(path)
  if not M.file_exists(path) then
    assert(path ~= nil, 'invalid path provided')
    if path == nil then
      return false, 'no path provided'
    end

    local home = vim.fn.expand '~'
    if path:sub(1, #home) == home then
      path = path:sub(#home + 2)
    end

    local full_path = vim.fn.expand '~' .. '/' .. path
    local home_path = vim.fn.fnamemodify(full_path, ':h')

    vim.fn.mkdir(home_path, 'p')

    return true
  end
  return false, 'file already exists'
end

-- Create a floating confirmation dialog
---@param message string: message to display in the dialog
---@param callback function: function to call with the result (boolean)
function M.confirm_dialog(message, callback)
  local width = 50
  local height = 3
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- Calculate centered position
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Set buffer content
  local content = {
    message,
    '',
    '[Y]es   [N]o',
  }
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)

  -- Set buffer options
  -- vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  -- vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')

  -- Create window
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  }
  local winnr = vim.api.nvim_open_win(bufnr, true, win_opts)

  -- Set window options
  -- vim.api.nvim_win_set_option(winnr, 'winblend', 10)

  -- Handle keypress
  local close_window = function()
    vim.api.nvim_win_close(winnr, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end

  vim.keymap.set('n', 'y', function()
    close_window()
    callback(true)
  end, { buffer = bufnr, nowait = true })

  vim.keymap.set('n', 'Y', function()
    close_window()
    callback(true)
  end, { buffer = bufnr, nowait = true })

  vim.keymap.set('n', 'n', function()
    close_window()
    callback(false)
  end, { buffer = bufnr, nowait = true })

  vim.keymap.set('n', 'N', function()
    close_window()
    callback(false)
  end, { buffer = bufnr, nowait = true })

  vim.keymap.set('n', '<Esc>', function()
    close_window()
    callback(false)
  end, { buffer = bufnr, nowait = true })
end

return M
