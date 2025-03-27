return {
  {
    dir = 'after/plugin/augment_chat.lua',
    name = 'augment_chat',
    config = function()
      require('augment_chat').setup()
    end,
  },
}
