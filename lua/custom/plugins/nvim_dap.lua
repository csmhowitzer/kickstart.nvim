-- TODO: Maybe making it too difficult to allow a choice to find the dll to bind to
-- but would like the debugger to run and know the dll to use
-- best approach probably would be no user input, as that is how it is in other tools

--return {}
--arm64 is the M1 chip; which this machine has
--not needed for laptop, maybe make this a choice?
return {
  {
    -- Mac Mini only
    --'Cliffback/netcoredbg-macOS-arm64.nvim',
    'mfussenegger/nvim-dap',
    dependencies = {
      'mfussenegger/nvim-dap',
      'leoluz/nvim-dap-go',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'folke/neodev.nvim',
    },

    config = function()
      local dap = require 'dap'
      local ui = require 'dapui'

      require('dapui').setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },

        mappings = {
          -- Use a table to apply multiple mappings
          expand = { '<CR>', '<2-LeftMouse>' },
          open = 'o',
          remove = 'd',
          edit = 'e',
          repl = 'r',
          toggle = 't',
        },
        element_mappings = {},
        expand_lines = vim.fn.has 'nvim-0.7' == 1,
        force_buffers = true,
        layouts = {
          {
            -- You can change the order of elements in the sidebar
            elements = {
              -- Provide IDs as strings or tables with "id" and "size" keys
              {
                id = 'scopes',
                size = 0.25, -- Can be float or integer > 1
              },
              { id = 'breakpoints', size = 0.25 },
              { id = 'stacks', size = 0.25 },
              { id = 'watches', size = 0.25 },
            },
            size = 40,
            position = 'left', -- Can be "left" or "right"
          },
          {
            elements = {
              'repl',
              'console',
            },
            size = 10,
            position = 'bottom', -- Can be "bottom" or "top"
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = 'single',
          mappings = {
            ['close'] = { 'q', '<Esc>' },
          },
        },
        controls = {
          -- Requires Neovim nightly (or 0.8 when released)
          enabled = vim.fn.exists '+winbar' == 1,
          -- Display controls in this element
          element = 'repl',
          icons = {
            pause = '',
            play = '',
            step_into = '', --'',
            step_over = '󰆷', --''
            step_out = '', --''
            step_back = '',
            run_last = '󰜉',
            terminate = '□',
            disconnect = '󰅛', --'󰿅',
          },
        },
        render = {
          max_type_length = nil, -- Can be integer or nil.
          max_value_lines = 100, -- Can be integer or nil.
          indent = 1,
        },
      }

      require('dap-go').setup()
      require('nvim-dap-virtual-text').setup { enabled = true }

      -- Handled by nvim-dap-go
      -- dap.adapters.go = {
      --  type = "server",
      --  port = "${port}",
      --  executable = {
      --    command = "dlv",
      --    args = { "dap", "-l", "127.0.0.1:${port}" },
      --  },
      --}

      -- Credit for setup
      -- https://aaronbos.dev/posts/debugging-csharp-neovim-nvim-dap
      -- Also TJ's video

      local coreclr = vim.fn.exepath 'netcoredbg'
      local dotnet = vim.fn.exepath 'dotnet'

      local workspace = ''
      local currentNetVer = ''
      local projName = ''

      -- Prompts the user to provide the name of the project
      -- C# / .NET specific if you have a solution set up
      -- Specifically asking for the project that the debugger should start from
      -- local getProjName = function()
      --   if projName == '' then
      --     projName = vim.fn.input 'Startup ProjName: '
      --     return projName
      --   else
      --     return projName
      --   end
      -- end

      -- Prompts the user to provide the workspace name for the project
      -- this would be the root file of the solution
      -- Again, in a .NET setup
      -- local getWorkspace = function()
      --   if workspace == '' then
      --     workspace = vim.fn.input('Workspace: ', vim.fn.getcwd() .. '/', 'file')
      --     return workspace
      --   else
      --     return workspace
      --   end
      -- end

      -- just a placeholder func to get the name of the folder for the .NET
      -- version.
      -- This is needed in modern .NET proj's to find the binaries
      -- local getNetVer = function()
      --   currentNetVer = 'net8.0'
      --   return currentNetVer
      -- end

      -- Piece everything together
      -- Workspace path (cwd basically)
      -- .NET version
      -- Project Name (startup proj)
      -- local getDLLPath = function()
      --   if workspace == '' then
      --     getWorkspace()
      --   end
      --   if currentNetVer == '' then
      --     getNetVer()
      --   end
      --   if projName == '' then
      --     getProjName()
      --   end
      --   local str = workspace .. projName .. '/bin/Debug/' .. currentNetVer .. '/' .. projName .. '.dll'
      --   print('DAP attaching to: ' .. str)
      --   return str
      -- end

      -- Shortcut for searching only from the root of a project (currently only csharp)
      -- TODO: add lang support for Go, ReactJS, etc...
      local getDLLPath = function()
        local conf = {
          opts = require('telescope.themes').get_dropdown(),
          isProj = false,
          isSln = false,
          isDll = true,
        }
        require('config.telescope.multigrep').setup(conf)
      end

      local getWorkspace = function()
        local conf = {
          opts = require('telescope.themes').get_dropdown(),
          isProj = false,
          isSln = true,
          isDll = false,
        }
        require('config.telescope.multigrep').setup(conf)
      end

      if coreclr ~= '' and dotnet ~= '' then
        dap.adapters.coreclr = {
          type = 'executable',
          command = coreclr,
          args = { '--interpreter=vscode' },
        }
        dap.configurations.cs = {
          {
            type = 'coreclr',
            justMyCode = false,
            stopatEntry = false,
            name = 'launch - netcoredbg',
            request = 'launch',
            --this may be needed for api type of configuration
            --args = { '/p:EnvironmentName=Development', '--urls=http://localhost:5004', '--environment=Development' },
            program = function()
              local path = getDLLPath()
              print('DLL Path: ' .. path)
              return path
            end,
            env = {
              ASPNETCORE_ENVIRONMENT = function()
                return 'Development'
              end,
            },
            cwd = function()
              local wd = getWorkspace()
              print('WD: ' .. wd)
              return wd
            end,
          },
          --   {
          --     type = 'coreclr',
          --     --justMycode = false,
          --     stopAtEntry = false,
          --     name = 'launch - netcoredbg - test',
          --     preLaunchTask = 'build',
          --     request = 'attach',
          --     program = '/usr/local/share/dotnet/dotnet',
          --     processId = function()
          --       return vim.fn.input 'Project Id: '
          --     end,
          --     cwd = getWorkspace(),
          --     args = {
          --       'exec',
          --       '--runtimeconfig',
          --       getWorkspace() .. 'bin/Debug/' .. getNetVer() .. '/' .. getProjName() .. '.runtimeconfig.json',
          --       '--additionalprobingpath',
          --       '/Users/wwmac/.nuget/packages',
          --       '/Users/wwmac/.nuget/packages/dotnet-xunit/2.3.1/lib/netcoreapp2.0/dotnet-xunit.dll',
          --       getDLLPath(),
          --       '-namespace',
          --       getProjName(),
          --     },
          --     env = {},
          --     --console = 'true',
          --   },
        }
      else
        print "couldn't find executable"
      end

      -- keymaps
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Set [b]reakpoint' })
      vim.keymap.set('n', '<leader>gb', dap.run_to_cursor, { desc = 'Run to cursor' })

      vim.keymap.set('n', '<leader>?', function()
        require('dapui').eval(nil, { enter = true })
      end, { desc = 'Evaluate under cursor (inspect)' })

      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Dap Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Dap Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Dap Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Dap Step Out' })
      vim.keymap.set('n', '<F9>', dap.step_back, { desc = 'Dap Step Back' })
      vim.keymap.set('n', '<F6>', dap.close, { desc = 'Dap Stop' })
      vim.keymap.set('n', '<F7>', dap.restart, { desc = 'Dap Restart' })

      -- Open/Close Dap UI configuration
      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
