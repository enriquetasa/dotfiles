-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Format on save (runs the configured formatter per filetype via conform):
--   python -> ruff, ruby -> rubocop, html/css/js/ts -> prettier
-- This is LazyVim's default; set explicitly to make the intent clear.
-- Toggle at runtime with <leader>uf (buffer) / <leader>uF (global).
vim.g.autoformat = true
