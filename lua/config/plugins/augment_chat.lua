-- INFO: Augment Chat with persistent history using scratch pad approach
local Snacks = require 'snacks'
local utils = require 'config.plugins.utils'

local M = {}

-- Configuration
local CHAT_CONFIG = {
  width = math.min(math.floor(vim.o.columns / 3), 100),
  height = vim.api.nvim_win_get_height(0) - 3,
  history_path = vim.fn.expand '~/.augment/chat_history',
}

-- Ensure history directory existso
local setup_history_dir = function()
  if not utils.file_exists(CHAT_CONFIG.history_path) then
    vim.fn.mkdir(CHAT_CONFIG.history_path, 'p')
  end
end

-- Get chat history file path for current conversation
local get_history_file = function(conversation_id)
  return string.format('%s/%s.json', CHAT_CONFIG.history_path, conversation_id or 'default')
end

-- Save chat history to file
local save_history = function(conversation_id, messages)
  local file_path = get_history_file(conversation_id)
  local content = vim.json.encode(messages)
  utils.write_file_content(file_path, content)
end

-- Find the AugmentChatHistory buffer
local find_history_buffer = function()
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) then
      local bufnr = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name:match 'AugmentChatHistory$' then
        return bufnr
      end
    end
  end
  return nil
end

-- Get content from history buffer
local get_history_content = function()
  local bufnr = find_history_buffer()
  if not bufnr then
    return {}
  end
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

-- Save the current chat content before closing
local save_current_chat = function()
  local chat_content = get_history_content()
  if #chat_content == 0 then
    return
  end
  local conversation_id = vim.b.augment_chat_id or 'default'
  save_history(conversation_id, chat_content)
end

-- Load chat history from file
local load_history = function(conversation_id)
  local file_path = get_history_file(conversation_id)
  if utils.file_exists(file_path) then
    local content = utils.read_file_content(file_path)
    local ok, decoded = pcall(vim.json.decode, content)
    return ok and decoded or {}
  end
  return {}
end

-- Display chat in scratch pad
local display_chat = function(conversation_id)
  vim.b.augment_chat_id = conversation_id
  local history = load_history(conversation_id)

  Snacks.scratch {
    name = 'Augment Chat',
    ft = 'markdown',
    content = history,
    win = {
      row = 1,
      col = vim.o.columns - CHAT_CONFIG.width,
      width = CHAT_CONFIG.width,
      height = CHAT_CONFIG.height,
      wo = { winhighlight = 'FloatBorder:SnacksInputBorder' },
    },
  }

  vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
end

-- Initialize module
function M.setup()
  setup_history_dir()

  -- Commands
  vim.api.nvim_create_user_command('AugmentChat', function()
    display_chat()
  end, {})

  vim.api.nvim_create_user_command('AugmentChatNew', function()
    local conversation_id = vim.fn.strftime '%Y%m%d_%H%M%S'
    display_chat(conversation_id)
  end, {})

  -- Optional: Add keymaps
  -- vim.keymap.set('n', '<leader>ac', ':AugmentChat<CR>', { desc = 'Open Augment Chat' })
  -- vim.keymap.set('n', '<leader>an', ':AugmentChatNew<CR>', { desc = 'New Augment Chat' })

  vim.api.nvim_create_autocmd('BufWinLeave', {
    group = vim.api.nvim_create_augroup('AugmentChat', { clear = true }),
    pattern = 'Augment Chat',
    callback = function()
<<<<<<< HEAD
      print 'hi!'
=======
>>>>>>> 28dfff0 (refactorign augment chat;')
      setup_history_dir()
      save_current_chat()
    end,
  })
end

return M
