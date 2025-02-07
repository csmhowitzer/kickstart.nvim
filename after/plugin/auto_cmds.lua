-- INFO: Disable Notify Plugin when in Dadbod UI
--

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*.sql',
  callback = function()
    vim.notify = function() end -- Disable notify for markdown files
  end,
})
