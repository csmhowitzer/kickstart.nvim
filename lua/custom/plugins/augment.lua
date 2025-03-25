return {
  {
    'augmentcode/augment.vim',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      vim.g.augment_disable_completions = true

      --- Reads the content of a file.
      --- @param file_path string
      --- @return string
      local file_content = function(file_path)
        local file = io.open(file_path, 'r')
        if not file then
          return 'file not found'
        end

        local content = file:read '*all'
        file:close()

        return content
      end

      --- Reads the workspaces from the config file.
      --- @return any
      local read_workspaces = function()
        local config_path = vim.fn.expand '~/.augment/workspaces.json'
        local content = file_content(config_path)

        local ok, decoded = pcall(vim.json.decode, content)
        return ok and decoded or {}
      end

      --- Adds a workspace folder.
      --- @return any
      local add_workspace_folder = function()
        local name = vim.fn.input 'Workspace Name: '
        if name == '' then
          return
        end
        local path = vim.fn.input 'Workspace Path: '
        if path == '' then
          return
        end
        local workspaces = read_workspaces()
        table.insert(workspaces.workspaces or {}, {
          name = name,
          path = path,
        })
        local config_path = vim.fn.expand '~/.augment/workspaces.json'
        local file = io.open(config_path, 'w')
        if file then
          file:write(vim.json.encode(workspaces))
          file:close()
          vim.notify('Workspace added successfully', vim.log.levels.INFO)
        end
      end

      --- Lists the workspaces.
      --- @return any
      local list_workspaces = function()
        local workspaces = read_workspaces()
        if workspaces.workspaces then
          local workspace_list = 'Current Workspaces:\n'
          for _, workspace in ipairs(workspaces.workspaces) do
            workspace_list = workspace_list .. '- ' .. workspace.name .. ': ' .. workspace.path .. '\n'
          end
          vim.notify(workspace_list, vim.log.levels.INFO)
        else
          vim.notify('No workspaces configured', vim.log.levels.INFO)
        end
      end

      --- Ingests the workspaces.
      --- @return any
      local ingest_workspaces = function()
        local workspaces = read_workspaces() or {}
        local folders = {}
        for _, workspace in ipairs(workspaces.workspaces) do
          table.insert(folders, workspace.path)
        end
        if #folders <= 0 then
          vim.notify('No workspaces configured', vim.log.levels.INFO)
        end
        return folders
      end
      vim.g.augment_workspace_folders = ingest_workspaces()

      --- Custom function to check nvim-cmp menu visibility
      local Augment_Accept = function()
        -- Check if nvim-cmp menu is visible
        if require('cmp').visible() then
          require('cmp').confirm { select = true }
        else
          -- Call Augment's accept function
          vim.cmd [[call augment#Accept('N/A')]]
        end
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<CMD>Augment chat<CR>', { desc = '[A]ugment [C]hat' })
      vim.keymap.set('n', '<leader>an', '<CMD>Augment chat new<CR>', { desc = '[A]ugment Chat [N]ew' })
      vim.keymap.set('n', '<leader>at', '<CMD>Augment chat toggle<CR>', { desc = '[A]ugment Chat [T]oggle' })
      vim.keymap.set('n', '<leader>asi', '<CMD>Augment signin<CR>', { desc = '[A]ugment [S]ign[I]n' })
      vim.keymap.set('n', '<leader>aso', '<CMD>Augment signout<CR>', { desc = '[A]ugment [S]ign[O]ut' })
      vim.keymap.set('n', '<leader>ast', '<CMD>Augment status<CR>', { desc = '[A]ugment [S]tatus' })

      vim.keymap.set('n', '<leader>atog', function()
        if vim.g.augment_disable_completions == false then
          vim.g.augment_disable_completions = true
          vim.notify('Augment disabled', vim.log.levels.INFO)
        else
          vim.g.augment_disable_completions = false
          vim.notify('Augment enabled', vim.log.levels.INFO)
        end
      end, { desc = '[A]ugment [T]oggle' })

      vim.keymap.set('n', '<leader>alw', function()
        list_workspaces()
      end, { desc = '[A]ugment [L]ist [W]orkspaces' })

      vim.keymap.set('n', '<leader>aw', function()
        add_workspace_folder()
      end, { desc = '[A]ugment Add [W]orkspace' })

      vim.keymap.set('i', '<C-y>', function()
        Augment_Accept()
      end, { desc = 'Accept completion or Augment suggestion' })
    end,
  },
}
