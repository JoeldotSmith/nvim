return {
  "nicholasmata/nvim-dap-cs",
  dependencies = { "mfussenegger/nvim-dap" },
}

-- return {
--   "iabdelkareem/csharp.nvim",
--   dependencies = {
--     { "mason-org/mason.nvim", version = "1.3.0" },
--     { "mason-org/mason-lspconfig.nvim", version = "v0.13.0" },
--     "mfussenegger/nvim-dap",
--     "Tastyep/structlog.nvim",
--   },
--   lazy = true,
--   ft = "cs", -- load only for C# files
--   config = function()
--     require("csharp").setup()
--   end,
-- }
