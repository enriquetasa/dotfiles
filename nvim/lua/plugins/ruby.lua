-- Ruby: use RuboCop for both formatting and linting (preferred over standardrb).
-- The lang.ruby extra provides ruby_lsp; this wires RuboCop into format-on-save.
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rubocop" })
    end,
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ruby = { "rubocop" },
        eruby = { "rubocop" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        ruby = { "rubocop" },
      },
    },
  },
}
