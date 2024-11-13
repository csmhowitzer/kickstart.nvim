-- get a template for a test function via treesitter playground
local test_function_query_string = [[
    (
      (method_declaration 
        returns: (predefined_type) @ret
        name: (identifier) @methodname
        parameters: (parameter_list) 
      )
      (#eq? @ret "void")
      (#eq? @methodname "%s")
    )
]]

local find_test_line = function(cs_bufnr, name)
  local formatted = string.format(test_function_query_string, name)
  local query = vim.treesitter.query.parse('c_sharp', formatted)
  local parser = vim.treesitter.get_parser(cs_bufnr, 'c_sharp', {})
  local tree = parser:parse()[1]
  local root = tree:root()

  for id, node in query:iter_captures(root, cs_bufnr, 0, -1) do
    if id == 1 then
      local range = { node:range() }
      return range[1]
    end
  end
end

local make_key = function(entry)
  assert(entry.extra.method, 'Must have name: ' .. vim.inspect(entry))
  assert(entry.extra.type, 'Must have type: ' .. vim.inspect(entry))
  return string.format('%s/%s', entry.extra.method, entry.extra.type)
end

local add_csharp_test = function(state, entry)
  state.tests[make_key(entry)] = {
    name = entry.extra.method,
    dur = entry.duration,
    line = find_test_line(state.bufnr, entry.extra.method),
    output = {},
  }
end

local fmtMessage = function(msg)
  return vim.split(msg, '\\\\n')
end
local fmtStackTrace = function(stackTrace)
  return vim.split(string.gsub(stackTrace, ' in ', ' \\n--> in '), '\\n')
end

local add_csharp_output = function(state, entry)
  assert(state.tests, 'no tests loaded yet')
  if entry.status == 'failed' then
    table.insert(state.tests[make_key(entry)].output, '------------')
    for _, i in ipairs(fmtMessage(entry.message)) do
      table.insert(state.tests[make_key(entry)].output, i)
    end
    table.insert(state.tests[make_key(entry)].output, '------------')
    for _, i in ipairs(fmtStackTrace(entry.trace)) do
      table.insert(state.tests[make_key(entry)].output, vim.trim(i))
    end
  end
end

local mark_success = function(state, entry)
  state.tests[make_key(entry)].success = entry.status == 'passed'
end

local ns = vim.api.nvim_create_namespace 'live-tests'
local group = vim.api.nvim_create_augroup('AutoTest', { clear = true })
local hl_group = vim.api.nvim_set_hl(ns, 'PassedTest', { fg = '#2ECC71', italic = true })

local attach_to_buffer = function(bufnr, command)
  local state = {
    bufnr = bufnr,
    tests = {},
  }
  vim.api.nvim_buf_create_user_command(bufnr, 'CSTestDiag', function()
    local line = vim.fn.line '.' - 1
    for _, test in pairs(state.tests) do
      if test.line == line then
        vim.cmd.new()
        vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, test.output)
      end
    end
  end, {})
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = '*_tests.cs', -- only for C# test classes right now
    callback = function()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

      state = {
        bufnr = bufnr,
        tests = {},
      }

      vim.fn.jobstart(command, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if not data then
            print 'no output text to parse through'
            return
          end

          -- INFO: need to remove odd chars added when grabbing the result from the test output
          local s = vim.inspect(data)
          local sub1 = string.sub(s, 7)
          local len = string.len(sub1)
          local sub2 = string.sub(sub1, 1, len - 9)

          local decoded = vim.json.decode(sub2)
          if decoded.results.tests ~= {} then
            for _, t in pairs(decoded.results.tests) do
              -- this is where we parse through the decoded lua table
              add_csharp_test(state, t)
              add_csharp_output(state, t)
              mark_success(state, t)
              local test = state.tests[make_key(t)]
              if test.success and test.line then
                local flavor = '\t  ' .. test.dur .. 'ms'
                local text = { flavor, 'String' }
                local opts = {
                  virt_text = { text },
                }
                vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, opts)
              end
            end
          else
            error('Failed to handle' .. vim.inspect(data))
          end
        end,
        on_exit = function()
          local failed = {}
          for _, t in pairs(state.tests) do
            if t.line then
              if not t.success then
                table.insert(failed, {
                  bufnr = bufnr,
                  lnum = t.line,
                  col = 0,
                  severity = vim.diagnostic.severity.ERROR,
                  source = 'cs-test',
                  message = 'Test Failed ' .. t.dur .. 'ms',
                  user_data = {},
                })
              end
            end
          end
          vim.diagnostic.set(ns, bufnr, failed, {})
        end,
      })
    end,
  })
end

vim.api.nvim_create_user_command('CSTestOnSave', function()
  attach_to_buffer(vim.api.nvim_get_current_buf(), { 'dotnet', 'run', '-silent', '-ctrf', '/dev/stdout' })
end, {}) -- { 'dotnet', 'run', '-silent', '-ctrf', '/dev/stdout' }
