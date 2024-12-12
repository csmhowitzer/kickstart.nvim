local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require('telescope.config').values
local M = {}

local find_proj_root = function(path)
  assert(path ~= nil, 'invalid path provided')
  return vim.fs.root(path, function(name)
    return name:match '%.csproj$' ~= nil
  end)
end

local find_sln_root = function(path)
  assert(path ~= nil, 'invalid path provided')
  return vim.fs.root(path, function(name)
    return name:match '%.sln$' ~= nil
  end)
end

local get_cwd = function(config)
  -- add more opts if we want to support diff project constraints
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if config.isProj then
    return find_proj_root(bufname)
  elseif config.isSln then
    return find_sln_root(bufname)
  else
    return vim.uv.cwd()
  end
end

local get_title = function(config)
  local title = 'Multi Grep'
  if config.isSln then
    title = 'Solution Grep'
  elseif config.isProj then
    title = 'Project Grep'
  end
  return title
end

local live_multigrep = function(config)
  config.cwd = get_cwd(config)
  config.opts = config.opts or {}

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local pieces = vim.split(prompt, '  ')
      local args = { 'rg' }
      if pieces[1] then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, '-g')
        table.insert(args, pieces[2])
      end

      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten {
        args,
        { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(config.opts),
    cwd = config.cwd,
  }

  pickers
    .new(config.opts, {
      debounce = 100,
      prompt_title = get_title(config),
      finder = finder,
      previewer = conf.grep_previewer(config.opts),
      sorter = require('telescope.sorters').empty(),
    })
    :find()
end

M.setup = function(opts)
  local config = {
    opts = opts.opts,
    isProj = opts.isProj,
    isSln = opts.isSln,
    cwd = '',
  }
  live_multigrep(config)
end

return M
