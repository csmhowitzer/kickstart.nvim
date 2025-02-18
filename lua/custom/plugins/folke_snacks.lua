local winOpts = function(width, height)
  return {
    row = 1,
    col = vim.o.columns - width,
    width = width,
    height = height - 3,
    wo = { winhighlight = 'FloatBorder:SnacksInputBorder,' },
  }
end

local FormatWinName = function(name)
  return 'Scratch Pad (' .. name .. ')'
end

local GetFnameFromWinName = function(winName)
  local filtered = string.gsub(winName, 'Scratch Pad %(', '')
  filtered = string.gsub(filtered, '%)', '')
  return filtered
end

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

          local buffers = Snacks.scratch.list()
          local bufnr = vim.api.nvim_get_current_buf()
          local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')

          if #buffers > 0 then
            local selected = {}
            for _, item in ipairs(buffers) do
              path = path and vim.fn.fnamemodify(path, ':p:~')
              item.cwd = item.cwd and vim.fn.fnamemodify(item.cwd, ':p:~') or ''

              --local clean = GetFnameFromWinName(item.name)

              if GetFnameFromWinName(item.name) == name and item.cwd == path then
                --print('name: ' .. item.name .. 'path: ' .. path .. 'cwd: ' .. item.cwd .. 'buf: ' .. name .. 'clean: ' .. clean)
                item.icon = item.icon or Snacks.util.icon(item.ft, 'filetype')
                item.branch = item.branch and ('branch:%s'):format(item.branch) or ''
                selected.name = item.name
                selected.icon = item.icon
                selected.file = item.file
                selected.ft = item.ft
              end
            end

            if selected ~= nil and selected ~= {} and selected.name ~= '' then
              --print('name: ' .. selected.name .. ' icone: ' .. selected.icon .. ' ft: ' .. selected.ft .. ' file: ' .. selected.file)
              Snacks.scratch.open {
                icon = selected.icon,
                file = selected.file,
                name = selected.name,
                ft = selected.ft,
                win = winOpts(width, height),
              }
              vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
            end
          else
            Snacks.scratch {
              name = FormatWinName(name),
              win = {
                row = 1,
                col = vim.o.columns - width,
                width = width,
                height = height - 3,
                wo = { winhighlight = 'FloatBorder:SnacksInputBorder,' },
              },
            }
            vim.api.nvim_set_hl(0, 'SnacksInputBorder', { fg = '#F7DC6F' })
          end
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
        win = {},
      },
    },
  },
}
