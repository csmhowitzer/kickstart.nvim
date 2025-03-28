return {
  {
    dir = vim.fn.stdpath 'config' .. '/lua/config/plugins/augment_chat.lua',
    name = 'augment_chat',
    config = function()
      require('augment_chat').setup()
    end,
  },
}
