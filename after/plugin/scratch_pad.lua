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

local Snacks = require 'snacks'

local winOpts = function(width, height)
  return {
    row = 1,
    col = vim.o.columns - width,
    width = width,
    height = height - 3,
    wo = { winhighlight = 'FloatBorder:SnacksInputBorder,' },
  }
end

local fmt_buf_name = function(name)
  return 'Scratch Pad (' .. name .. ')'
end

local buffer_vals = function(bufnr)
  local sliceW = math.floor(vim.o.columns / 3)
  local maxW = 100

  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')

  path = path and vim.fn.fnamemodify(path, ':p:~')

  local pad = {
    width = sliceW < maxW and sliceW or maxW,
    height = vim.api.nvim_win_get_height(0) - 3,
    path = path,
    name = name,
    fmtName = fmt_buf_name(name),
  }

  return pad
end

local get_scratch_filename = function(winName)
  local filtered = string.gsub(winName, 'Scratch Pad %(', '')
  filtered = string.gsub(filtered, '%)', '')
  return filtered
end

local open_scratch = function(buffer, vals)
  Snacks.scratch.open {
    icon = buffer.icon,
    file = buffer.file,
    name = buffer.name,
    ft = buffer.ft,
    win = winOpts(vals.width, vals.height),
  }
  vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
end

local reload_scratch_pad = function(buffers, vals)
  assert(vals.path, 'no path provided')
  assert(vals.name, 'no filename provided')

  local scratchPad = {}

  for _, item in ipairs(buffers) do
    local wd = item.cwd and vim.fn.fnamemodify(item.cwd, ':p:~') or ''
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

  if scratchPad ~= {} and scratchPad.name ~= '' then
    open_scratch(scratchPad, vals)
  end

  return scratchPad
end

local open_new_scratch_pad = function(vals)
  Snacks.scratch {
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

local toggle_scratch_pad = function()
  local buffers = Snacks.scratch.list()
  local bufnr = vim.api.nvim_get_current_buf()
  local vals = buffer_vals(bufnr)

  if #buffers > 0 then
    reload_scratch_pad(buffers, vals)
  else
    open_new_scratch_pad(vals)
  end
end

local show_scratch_select = function()
  Snacks.scratch.select()
end

local delete_scratch_file = function()
  local buffers = Snacks.scratch.list()
end

-- keymaps
vim.keymap.set('n', '==', function()
  toggle_scratch_pad()
end, { desc = 'Toggle Scratch Buffer' })

vim.keymap.set('n', '===', function()
  show_scratch_select()
end, { desc = 'Select Scratch Buffer' })

vim.api.nvim_set_hl(0, 'SnacksDashboardHeader', { fg = '#a6d189' })
