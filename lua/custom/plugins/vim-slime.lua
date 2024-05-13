-- Define a Lua function to check if the current buffer is a Python chunk in Quarto
local function quarto_is_in_python_chunk()
  local is_python_chunk = require('otter.tools.functions').is_otter_language_context 'python'
  -- Update the Vim variable directly from Lua
  vim.api.nvim_set_var('quarto_is_python_chunk', is_python_chunk and 1 or 0)
end

-- Use an autocmd to check for Python chunks when entering buffer or text changes
vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'InsertLeave' }, {
  pattern = { '*.qmd', '*.Rmd' }, -- Adjust patterns according to your file types
  callback = quarto_is_in_python_chunk,
})

return {
  'jpalardy/vim-slime',

  dependencies = { 'jmbuhr/otter.nvim' },

  config = function()
    -- Configure vim-slime
    vim.g.slime_target = 'neovim'
    vim.g.slime_python_ipython = 1
    vim.g.slime_dispatch_ipython_pause = 100

    -- Vimscript for custom Slime override function
    vim.cmd [[
      function! SlimeOverride_EscapeText_quarto(text)
        if exists('g:slime_python_ipython') && g:quarto_is_python_chunk && len(split(a:text,"\n")) > 1
          return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
        else
          return a:text
        endif
      endfunction
    ]]

    -- Utility functions for terminal management
    local function mark_terminal()
      local bufnr = vim.api.nvim_get_current_buf()
      local channel = vim.bo[bufnr].channel
      vim.g.slime_last_channel = channel
      print('Terminal marked:', channel)
    end

    local function set_terminal()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.b[bufnr].slime_config = { jobid = vim.g.slime_last_channel }
      print('Terminal set for buffer:', bufnr)
    end

    -- Key mappings for terminal functions
    local wk = require 'which-key'
    wk.register {
      ['<leader>cm'] = { mark_terminal, 'Mark terminal' },
      ['<leader>cs'] = { set_terminal, 'Set terminal' },
    }
  end,
}
