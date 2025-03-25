---@diagnostic disable: missing-fields

-- INFO: adjustments made to folke-snacks.nvim plugin
-- Changes:
--    - Border Style
--      - changed color
--    - Window Style
--      - the title of the scratch pad
--        - now includes file name (for list selection)
--      - shift to right side of window
--    - Re-loading Scratch Pads
--      - When you open any file that already has had a Scratch Pad this will open up the old one.
--      - You will never have a "new" one each time you open one up if one exists
--
-- TODO: Properly open a scratch pad when a list of files exists
--  - update how we open, look at notes
--  - add a markdown only scratch type

local Snacks = require 'snacks'

--- Gets the window options for the scratch pad
--- @param width number : the width of the scratch pad
--- @param height number : the height of the scratch pad
--- @return table
local winOpts = function(width, height)
  return {
    row = 1,
    col = vim.o.columns - width,
    width = width,
    height = height - 3,
    wo = { winhighlight = 'FloatBorder:SnacksInputBorder,' },
  }
end

--- Formats the buffer name for the scratch pad
--- @param name string : the buffer name
--- @return string
local fmt_buf_name = function(name)
  return 'Scratch Pad (' .. name .. ')'
end

--- Gets initial values for the scratch pad
--- @param bufnr number : the buffer number
--- @return table
local buffer_vals = function(bufnr)
  local sliceW = math.floor(vim.o.columns / 3)
  local maxW = 100

  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  local ft = vim.filetype.match { filename = name }
  local icon = Snacks.util.icon(ft, 'filetype')

  path = path and vim.fn.fnamemodify(path, ':p:~')

  local pad = {
    width = sliceW < maxW and sliceW or maxW,
    height = vim.api.nvim_win_get_height(0) - 3,
    path = path,
    name = name,
    fmtName = fmt_buf_name(name),
    ft = ft,
    icon = icon,
    file = nil,
  }

  return pad
end

--- Gets the scratch pad filename from the window name
--- @param winName string : the window name
--- @return string
local get_scratch_filename = function(winName)
  local filtered = string.gsub(winName, 'Scratch Pad %(', '')
  filtered = string.gsub(filtered, '%)', '')
  return filtered
end

--- Opens a new scratch pad
--- @param vals table : the buffer values
--- @return table
local open_new_scratch_pad = function(vals)
  Snacks.scratch {
    ft = vals.ft,
    name = vals.fmtName,
    win = {
      row = 1,
      col = vim.o.columns - vals.width,
      width = vals.width,
      height = vals.height - 3,
      wo = { winhighlight = 'FloatBorder:SnacksInputBorder,' },
    },
  }
  vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
end

--- Opens a scratch pad
--- @param padVals table : the buffer values
--- @return table
local open_scratch = function(padVals)
  Snacks.scratch.open {
    icon = padVals.icon,
    file = padVals.file,
    name = padVals.fmtName,
    ft = padVals.ft,
    win = winOpts(padVals.width, padVals.height),
  }
  vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
end

--- Finds the scratch pad for the current buffer if one exists
--- @param buffers table : the list of scratch pads
--- @param vals table : the buffer values
--- @return table?
local reload_scratch_pad = function(buffers, vals)
  assert(vals.path, 'no path provided')
  assert(vals.name, 'no filename provided')

  local scratchPad = {}

  for _, item in ipairs(buffers) do
    local wd = item.cwd and vim.fn.fnamemodify(item.cwd, ':p:~') or '' -- ternary
    local fileName = get_scratch_filename(item.name)

    if fileName == vals.name and wd == vals.path then
      item.icon = item.icon or Snacks.util.icon(item.ft, 'filetype')
      item.branch = item.branch and ('branch:%s'):format(item.branch) or ''
      scratchPad.name = item.name
      scratchPad.icon = item.icon
      scratchPad.file = item.file
      scratchPad.ft = item.ft
      break
    end
  end

  if scratchPad ~= {} and scratchPad.name ~= nil then
    return scratchPad
  else
    return nil
  end
end

--- Deletes the current scratch pad
local delete_current_scratch_pad = function()
  local buffers = Snacks.scratch.list()
  local bufnr = vim.api.nvim_get_current_buf()
  local vals = buffer_vals(bufnr)

  for _, item in ipairs(buffers) do
    local wd = item.cwd and vim.fn.fnamemodify(item.cwd, ':p:~') or '' -- ternary
    local fileName = get_scratch_filename(item.name)

    if fileName == vals.name and wd == vals.path then
      if item.file and vim.fn.filereadable(item.file) == 1 then
        vim.fn.delete(item.file)
        break
      end
    end
  end
end

--- Toggles display of the scratch pad. Reloads an existing scratch pad if one exists.
--- @param fileType? string : the file type to open the scratch pad as
local toggle_scratch_pad = function(fileType)
  fileType = fileType or nil
  local buffers = Snacks.scratch.list()
  local bufnr = vim.api.nvim_get_current_buf()
  local vals = buffer_vals(bufnr)

  local pad = nil
  if #buffers > 0 then
    pad = reload_scratch_pad(buffers, vals)
  end

  if pad ~= nil then
    if fileType ~= nil then
      pad.ft = fileType
      pad.icon = Snacks.util.icon(fileType, 'filetype')
    end
    vals.fmtName = pad.name
    vals.ft = pad.ft
    vals.file = pad.file
    vals.icon = pad.icon
    open_scratch(vals)
  else
    if fileType ~= nil then
      vals.ft = fileType
    end
    open_new_scratch_pad(vals)
  end
end

--- Shows a list of scratch pads to select from
--- @see Snacks.scratch.select
local show_scratch_select = function()
  Snacks.scratch.select()
end

-- keymaps
vim.keymap.set('n', '==', function()
  toggle_scratch_pad()
end, { desc = 'Toggle Scratch Buffer' })

vim.keymap.set('n', '===', function()
  show_scratch_select()
end, { desc = 'Select Scratch Buffer' })

vim.keymap.set('n', '=m', function()
  toggle_scratch_pad 'markdown'
end, { desc = 'Toggle Scratch Buffer (Markdown)' })

vim.keymap.set('n', '=d', function()
  delete_current_scratch_pad()
end, { desc = 'Delete Scratch Buffer' })

-- colors
vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', { fg = '#a6d189' })
