-- INFO: Auto-Switch cwd when entering a new .cs file
-- On BufEnter
--    switch the cwd to the .sln root path

local find_sln_root = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
  assert(path ~= nil, 'invalid path provided')
  return vim.fs.root(path, function(name)
    return name:match '%.sln$' ~= nil
  end)
end

-- autocommand
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('CS_Cwd_Switch', {
    clear = true,
  }),
  pattern = '*.cs',
  callback = function()
    local slnPath = find_sln_root()
    vim.api.nvim_set_current_dir(slnPath)
  end,
})
