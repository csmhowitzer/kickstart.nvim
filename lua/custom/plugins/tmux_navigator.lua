return {
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-s-H>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-s-J>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-s-K>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-s-L>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
}
