local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require('telescope.config').values
local utils = require 'config.plugins.utils'
local M = {}

local get_cwd = function(config)
  -- add more opts if we want to support diff project constraints
  local path = utils.get_full_path()
  if config.isProj then
    return utils.find_proj_root(path)
  elseif config.isSln then
    return utils.find_sln_root(path)
  elseif config.isDll then
    return utils.find_root '%.dll$'
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
  elseif config.isDll then
    title = 'DLL Grep'
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
    isDll = opts.isDll,
    cwd = '',
  }
  live_multigrep(config)
end

return M
