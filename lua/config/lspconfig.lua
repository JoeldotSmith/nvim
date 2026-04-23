local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

vim.lsp.config("roslyn", {})

local capabilities = cmp_nvim_lsp.default_capabilities()

local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local handlers = {
  function(server_name)
    if server_name == "marksman" then
      return
    end
    lspconfig[server_name].setup({
      capabilities = capabilities,
    })
  end,
  ["emmet_ls"] = function()
    lspconfig.emmet_ls.setup({
      capabilities = capabilities,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })
  end,
  ["volar"] = function()
    lspconfig.volar.setup({
      capabilities = capabilities,
      init_options = {
        vue = {
          hybridMode = false,
        },
      },
      settings = {
        typescript = {
          inlayHints = {
            enumMemberValues = {
              enabled = true,
            },
            functionLikeReturnTypes = {
              enabled = true,
            },
            propertyDeclarationTypes = {
              enabled = true,
            },
            parameterTypes = {
              enabled = true,
              suppressWhenArgumentMatchesName = true,
            },
            variableTypes = {
              enabled = true,
            },
          },
        },
      },
    })
  end,
  ["ts_ls"] = function()
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = vim.fn.stdpath("data")
              .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
            languages = { "vue" },
          },
        },
      },
      filetypes = {
        "javascript",
        "typescript",
        "vue",
      },
      settings = {
        typescript = {
          tsserver = {
            useSyntaxServer = false,
          },
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    })
  end,
}

if mason_lspconfig.setup_handlers then
  mason_lspconfig.setup_handlers(handlers)
else
  for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
    local handler = handlers[server_name] or handlers[1]
    handler(server_name)
  end
end
