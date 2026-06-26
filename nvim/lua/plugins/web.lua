-- HTML / CSS support
-- LazyVim ships no dedicated lang.html extra, so wire up treesitter + LSP here.
-- Formatting (prettier) is handled by the formatting.prettier extra (lazyvim.json).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "html", "css", "scss" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        emmet_language_server = {},
      },
    },
  },
}
