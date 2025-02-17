return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '==',
        function()
          local width = 70
          local height = 40
          Snacks.scratch {
            win = {
              row = 1,
              col = vim.o.columns - width,
              width = width,
              height = height - 3,
              wo = { winhighlight = 'FloatBorder:SnacksInputBorder,' },
            },
          }
          vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '===',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
    },
    ---@type snacks.Config
    opts = {
      scratch = {
        name = 'Scratch Pad',
        win = {},
      },
    },
  },
}
