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

return M
