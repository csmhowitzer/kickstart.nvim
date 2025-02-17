return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '==',
        function()
          local oneThird = math.floor(vim.o.columns / 3)
          local maxWW = 100
          local width = oneThird < maxWW and oneThird or maxWW
          local height = vim.api.nvim_win_get_height(0) - 3
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
