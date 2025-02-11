-- INFO: Autocommand set up to format on save using csharpier
-- csharpier is a dotnet tool installed globally on the machine
--
-- Also added a user command to format the entire solution

local find_sln_root = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
  assert(path ~= nil, 'invalid path provided')
  return vim.fs.root(path, function(name)
    return name:match '%.sln$' ~= nil
  end)
end

local run_csharpier = function(path)
  vim.fn.jobstart({ 'dotnet', 'csharpier', path }, {
    stdout_buffered = true,
    on_exit = function()
      vim.cmd [[e]]
      vim.cmd [[LspRestart]]
    end,
  })
end

vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('CSFmtOnSave', {
    clear = true,
  }),
  pattern = '*.cs',
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufName = vim.api.nvim_buf_get_name(bufnr)
    run_csharpier(bufName)
  end,
})

vim.api.nvim_create_user_command('CSFmtCSharpier', function()
  run_csharpier(find_sln_root())
end, {})
