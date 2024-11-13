-- autocommand
-- Markdown format:
-- Sets line wrapping to 80 chars
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('MDFmt', {
    clear = true,
  }),
  pattern = '*.md',
  callback = function()
    local width = 80
    local bufnr = vim.api.nvim_get_current_buf()
    print('Markdown file bufnr: ' .. bufnr .. ' cw: ' .. width)
    vim.api.nvim_buf_set_option(bufnr, 'colorcolumn', tostring(width))
    vim.api.nvim_buf_set_option(bufnr, 'textwidth', width)
  end,
})