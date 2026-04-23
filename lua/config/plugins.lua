local function repo(path)
  return "https://github.com/" .. path
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data and ev.data.spec and ev.data.spec.name
    if name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  repo("nvim-lua/plenary.nvim"),
  repo("nvim-neotest/nvim-nio"),
  repo("MunifTanjim/nui.nvim"),
  repo("nvim-tree/nvim-web-devicons"),
  repo("echasnovski/mini.icons"),

  repo("EdenEast/nightfox.nvim"),
  repo("folke/snacks.nvim"),
  repo("shortcuts/no-neck-pain.nvim"),
  repo("sphamba/smear-cursor.nvim"),
  repo("folke/which-key.nvim"),
  repo("j-hui/fidget.nvim"),
  repo("lewis6991/gitsigns.nvim"),
  repo("folke/todo-comments.nvim"),
  repo("folke/flash.nvim"),
  repo("folke/trouble.nvim"),
  repo("folke/noice.nvim"),
  repo("nvim-lualine/lualine.nvim"),
  repo("akinsho/bufferline.nvim"),
  repo("folke/persistence.nvim"),
  repo("folke/lazydev.nvim"),

  { src = repo("nvim-treesitter/nvim-treesitter"), version = "main" },
  repo("nvim-treesitter/nvim-treesitter-textobjects"),
  repo("windwp/nvim-ts-autotag"),
  repo("JoosepAlviste/nvim-ts-context-commentstring"),

  repo("stevearc/conform.nvim"),
  repo("mfussenegger/nvim-lint"),
  repo("williamboman/mason.nvim"),
  repo("williamboman/mason-lspconfig.nvim"),
  repo("jay-babu/mason-nvim-dap.nvim"),
  repo("neovim/nvim-lspconfig"),
  repo("seblyng/roslyn.nvim"),

  repo("hrsh7th/nvim-cmp"),
  repo("hrsh7th/cmp-nvim-lsp"),
  repo("hrsh7th/cmp-buffer"),
  repo("hrsh7th/cmp-path"),
  repo("garymjr/nvim-snippets"),
  repo("rafamadriz/friendly-snippets"),
  repo("supermaven-inc/supermaven-nvim"),

  repo("mfussenegger/nvim-dap"),
  repo("rcarriga/nvim-dap-ui"),
  repo("theHamsta/nvim-dap-virtual-text"),
  repo("nvim-neotest/neotest"),
  repo("Issafalcon/neotest-dotnet"),
  repo("antoinemadec/FixCursorHold.nvim"),
  repo("ramboe/ramboe-dotnet-utils"),

  repo("olimorris/codecompanion.nvim"),
  repo("MeanderingProgrammer/render-markdown.nvim"),
  repo("obsidian-nvim/obsidian.nvim"),
  repo("OXY2DEV/markview.nvim"),
  repo("lervag/vimtex"),
}, {
  confirm = #vim.api.nvim_list_uis() > 0,
  load = true,
})

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
setup("no-neck-pain", { width = 100 })
setup("smear_cursor")
setup("supermaven-nvim")
setup("render-markdown")
setup("markview")
setup("nvim-dap-virtual-text")

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

local notes_dir = vim.fn.expand("~/Notes")
if vim.fn.isdirectory(notes_dir) == 1 then
  setup("obsidian", {
    legacy_commands = false,
    workspaces = {
      {
        name = "main",
        path = notes_dir,
      },
    },
  })
end

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

setup("mason-lspconfig")
setup("mason-nvim-dap")

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
end

vim.schedule(setup_lsp)

local neotest_ok, neotest = pcall(require, "neotest")
if neotest_ok then
  neotest.setup({
    adapters = {
      require("neotest-dotnet"),
    },
  })
end

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
      inline = {
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
