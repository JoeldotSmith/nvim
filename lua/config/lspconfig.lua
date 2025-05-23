local lspconfig = require("lspconfig")

local vue_language_server_path = "/Users/joelsmith/.nvm/versions/node/v20.14.0/lib/node_modules/@vue/language-server/"

lspconfig.ts_ls.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
      },
    },
  },
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})
lspconfig.volar.setup({})
