local function setup(module, opts)
  local ok, plugin = pcall(require, module)
  if ok and plugin.setup then
    local setup_ok, err = pcall(plugin.setup, opts or {})
    if not setup_ok then
      vim.schedule(function()
        vim.notify(("Failed to configure %s: %s"):format(module, err), vim.log.levels.WARN)
      end)
    end
  end
end

vim.cmd.colorscheme("carbonfox")
vim.cmd("highlight! WinSeparator guifg=#4BC3B1")

setup("mini.icons")
setup("which-key")
setup("fidget")
setup("gitsigns")
setup("todo-comments")
setup("flash")
setup("trouble")
setup("noice")
setup("lualine")
setup("bufferline")
setup("persistence")
setup("lazydev")
setup("nvim-ts-autotag")
setup("ts_context_commentstring")
setup("smear_cursor")
setup("supermaven-nvim")
setup("render-markdown")

setup("snacks", {
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
        { icon = " ", key = "u", desc = "Update Plugins", action = ":lua vim.pack.update()" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
      header = [[
 .          .
 ';;,.        ::'
 ,:::;,,        :ccc,
,::c::,,,,.     :cccc,
,cccc:;;;;;.    cllll,
,cccc;.;;;;;,   cllll;
:cccc; .;;;;;;. coooo;
;llll;   ,:::::'loooo;
;llll:    ':::::loooo:
:oooo:     .::::llodd:
.;ooo:       ;cclooo:.
.;oc        'coo;.
 .'         .,.]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
})


setup("nvim-treesitter.configs", {
  ensure_installed = {
    "bash",
    "c_sharp",
    "css",
    "dockerfile",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "razor",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
  },
  highlight = { enable = true },
  indent = { enable = true },
})

setup("mason", {
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
})

local mason_tools = {
  "csharpier",
  "roslyn",
  "netcoredbg",
}

local function ensure_mason_tools()
  local ok_registry, registry = pcall(require, "mason-registry")
  if not ok_registry then
    return
  end

  registry.refresh(function()
    for _, tool in ipairs(mason_tools) do
      local ok_pkg, pkg = pcall(registry.get_package, tool)
      if ok_pkg and not pkg:is_installed() then
        pkg:install()
      end
    end
  end)
end

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = ensure_mason_tools,
})

setup("mason-lspconfig", {
  automatic_enable = false,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
  or vim.lsp.diagnostic.on_publish_diagnostics

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == "roslyn" and result and result.diagnostics then
    result.diagnostics = vim.tbl_filter(function(diagnostic)
      return diagnostic.code ~= "CA1873"
    end, result.diagnostics)
  end

  return default_publish_diagnostics(err, result, ctx, config)
end

local function setup_lsp()
  local mason_lspconfig = require("mason-lspconfig")
  local cmp_nvim_lsp = require("cmp_nvim_lsp")

  vim.lsp.config("roslyn", {})

  local capabilities = cmp_nvim_lsp.default_capabilities()
  local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  local configs = {
    emmet_ls = {
      capabilities = capabilities,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    },
    vue_ls = {
      capabilities = capabilities,
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
    },
    ts_ls = {
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
    },
  }

  for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
    if server_name ~= "marksman" then
      vim.lsp.config(server_name, configs[server_name] or {
        capabilities = capabilities,
      })
      vim.lsp.enable(server_name)
    end
  end
end

setup_lsp()


local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  cmp.setup({
    completion = { completeopt = "menu,menuone,noinsert" },
    experimental = { ghost_text = true },
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
      { name = "supermaven" },
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "buffer" },
    }),
  })
end

local codecompanion_ok, codecompanion = pcall(require, "codecompanion")
if codecompanion_ok then
  codecompanion.setup({
    strategies = {
      chat = {
        adapter = "codex",
      },
      inlkne = {
        adapter = "codex",
      },
    },
    display = {
      chat = {
        window = {
          layout = "vertical",
          position = "right",
          width = 75,
          full_height = true,
        },
        start_in_insert_mode = false,
      },
    },
    adapters = {
      acp = {
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chatgpt",
            },
          })
        end,
      },
    },
  })

  local progress_ok, progress = pcall(require, "fidget.progress")
  if progress_ok then
    local handles = {}
    local group = vim.api.nvim_create_augroup("CodeCompanionFidget", {})

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestStarted",
      group = group,
      callback = function(e)
        handles[e.data.id] = progress.handle.create({
          title = "CodeCompanion",
          message = "Thinking...",
          lsp_client = { name = e.data.adapter.formatted_name },
        })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestFinished",
      group = group,
      callback = function(e)
        local handle = handles[e.data.id]
        if handle then
          handle.message = e.data.status == "success" and "Done" or "Failed"
          handle:finish()
          handles[e.data.id] = nil
        end
      end,
    })
  end
end
