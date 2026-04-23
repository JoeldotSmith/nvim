vim.loader.enable()

require("config.options")
require("config.pack")
require("config.autocmds")
require("config.keymaps")

vim.schedule(function()
  require("config.lspconfig")
end)

require("neotest").setup({
  adapters = {
    require("neotest-dotnet"),
  },
})
