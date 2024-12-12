-- local thing = vim.system({ 'echo hello' }, { text = true }):wait()

-- local fname = vim.fn.input('Startup Proj: ', '', 'file')

-- NOTE: The thing we want
-- we need the absolute path so we can enter for our dll
--  The goal was mimic Startup Project and find the dll

-- IDEA: May need to rethink this
-- DAP requires the .dll for the project that will be debugged
-- So what needs to be answered?
-- 1. What is the project name?
--    - we cover this with the simple input script up above where we get `fname`
-- 2. Via knowledge about .NET proj structure we can assume <fname>/bin/Debug will be what we need
--    - this will require changing the .csproj Output Path to point to the path we want it to go to
--      - currently it is ./bin/Debug/net8.0 but version will change and so a common path for all versions
--        should be adopted
-- 2a. We will need to find out the dotnet SDK args needed to assign the output path
--    - for now, we can just manually update the .csproj file
-- 3. Can we or SHOULD WE assume the project file name without prompting for it?
--    TO ASSUME:
--    - If we assume the proj-name then the expected debugger flow will be pressing <F5> and auto-attach
--      to the project's dll
--    - The only way to ASSUME will be to go up to the SLN level and then back down 1 from current file
--    TO PROMPT:
--    - If we prompt for the project name we can always find the starting point
--

function TestMe()
  -- local dap_file = vim.fn.exepath 'netcoredbg'
  -- local test = vim.fn.exepath 'dotnet'
  -- if dap_file ~= '' then
  --   print(test)
  -- else
  --   print 'nothing found'
  -- end
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h') -- get bufnr dir path
  path = '/Users/wwmac/Documents/projects/examples/csharp/Kata/SimpleSetup/SimpleSetupRunner/Program.cs'
  local root = vim.fs.root(path, function(name, path)
    return name:match '%.csproj$' ~= nil
  end)
  print(bufnr)
  print(path)
  print(root)
end
