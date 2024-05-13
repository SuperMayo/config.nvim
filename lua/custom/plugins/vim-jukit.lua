return {
  'luk400/vim-jukit',
  keys = {
    { '<leader><space>', false },
  },
  config = function()
    -- Activate commands on python files only
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'python', 'ipynb' }, -- Assuming 'ipynb' is recognized as a filetype
      callback = function()
        -- Define key mappings specific to python and ipynb files
        local map = vim.api.nvim_set_keymap
        local opts = { noremap = true, silent = true }

        -- Send code within the current cell to output split
        map('n', '<leader><space>', ':call jukit#send#section(0)<CR>', opts)
        -- Send current line to output split
        map('n', '<CR>', ':call jukit#send#line()<CR>', opts)
        -- Send visually selected code to output split
        map('v', '<CR>', ':<C-U>call jukit#send#selection()<CR>', opts)
        -- Execute all cells until the current cell
        map('n', '<leader>cc', ':call jukit#send#until_current_section()<CR>', opts)
        -- Execute all cells
        map('n', '<leader>all', ':call jukit#send#all()<CR>', opts)
      end,
    })
  end,
}
