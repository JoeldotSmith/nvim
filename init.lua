require("config.lazy")
vim.schedule(function()
  require("config.lspconfig")
end)
require("plugins.dashboard")
require("neotest").setup({
  adapters = {
    require("neotest-dotnet"),
  },
})
