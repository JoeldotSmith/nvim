return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp",
        "razor",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "csharpier",
        "roslyn",
        "netcoredbg",
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    ft = { "cs", "razor" },
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        config = function()
          require("config.nvim-dap-ui")
        end,
      },
      {
        "nvim-neotest/neotest",
        dependencies = {
          "nvim-neotest/nvim-nio",
          "Issafalcon/neotest-dotnet",
        },
        config = function()
          require("neotest").setup({
            adapters = {
              require("neotest-dotnet"),
            },
          })
        end,
      },
    },
    config = function()
      require("config.nvim-dap")

      local dap = require("dap")

      local function pick_program()
        local items = {}
        local csproj = vim.fn.glob("**/*.csproj")

        for path in csproj:gmatch("[^\n]+") do
          items[#items + 1] = path
        end

        if #items == 0 then
          vim.notify("No .csproj files found", vim.log.levels.ERROR)
          return nil
        end

        if #items == 1 then
          csproj = items[1]
        else
          local selection = vim.fn.inputlist(vim.list_extend(
            { "Select .csproj:" },
            vim.tbl_map(function(path)
              return path
            end, items)
          ))

          if selection < 1 or selection > #items then
            return nil
          end

          csproj = items[selection]
        end

        if not csproj or csproj == "" then
          return nil
        end

        local base = vim.fn.fnamemodify(csproj, ":h")
        local name = vim.fn.fnamemodify(csproj, ":t:r")
        return vim.fn.glob(vim.fs.joinpath(base, "bin", "Debug", "*", name .. ".dll"))
      end

      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "launch - netcoredbg",
          request = "launch",
          console = "internalConsole",
          program = pick_program,
        },
        {
          type = "coreclr",
          name = "attach - netcoredbg",
          request = "attach",
          processId = function()
            return require("dap.utils").pick_process()
          end,
        },
      }
    end,
  },
  {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { "cs", "razor" },
    opts = {
      -- your configuration comes here; leave empty for default settings
    },
  },
}
