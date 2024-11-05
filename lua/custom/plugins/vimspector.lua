-- This is for Vimspector; which is used for Xunit debugging
-- https://alpha2phi.medium.com/neovim-for-beginners-debugging-using-vimspector-3b6762dbd115
-- https://github.com/puremourning/vimspector?tab=readme-ov-file#neovim-limitations
--
return {
  {
    'puremourning/vimspector',
    cmd = {
      'VimspectorInstall',
      'VimspectorUpdate',
    },
    fn = {
      'vimspector#Launch()',
      'vimspector#ToggleBreakpoint',
      'vimspector#Continue',
    },
    config = function()
      require('config.vimspector').setup {
        --local utils = require "utils"
        --local vimspector_csharp =
      }
    end,
  },
}
