vim.api.nvim_create_user_command("VimPackClean", function()
  local inactive = vim.iter(vim.pack.get()):filter(function(x) return not x.active end):map(function(x) return x.spec.name end):totable()
  if #inactive > 0 then
    vim.pack.del(inactive)
    print("Cleaned: " .. table.concat(inactive, ", "))
  else
    print("Nothing to clean.")
  end
end, {})

local function close_terminals()
  vim.api.nvim_command("bufdo if (bufname() =~ '^term://.*') | bd! | endif")
end

vim.api.nvim_create_user_command("KillTerminals", close_terminals, { desc = "Close all terminal buffers" })

vim.api.nvim_create_user_command("RunProject", function(opts)
  local ami = opts.args

  vim.cmd("tabnew")

  vim.cmd("terminal cd $(ls -d */ | grep -iE '^enco.*backend' | grep -ivE 'mini') && dotnet watch")
  vim.cmd("vsplit")

  if ami == "ami" then
    vim.cmd("terminal ./msql_connect.sh")
    vim.cmd("split")
  end

  vim.cmd("terminal cd $(ls -d */ | grep -iE '^enco.*frontend' | grep -ivE 'mini') && npm run dev")
end, { nargs = "?" })


vim.api.nvim_create_user_command("SwitchGit", function()
  local cwd = vim.fn.getcwd()
  local config_files = vim.fn.globpath(cwd, "**/.git/config", true, true)
  local updated_files = {}

  local function swap_url(url)
    local swapped, n = url:gsub("git%.enco%.au", "git.enco.local", 1)
    if n > 0 then
      return swapped
    end

    swapped, n = url:gsub("git%.enco%.local", "git.enco.au", 1)
    if n > 0 then
      return swapped
    end

    return nil
  end

  for _, config_file in ipairs(config_files) do
    local read_handle = io.open(config_file, "r")
    if read_handle then
      vim.notify("config_file: " .. config_file)
      local content = read_handle:read("*a")
      read_handle:close()

      local changed = false
      local next_content = content:gsub("([ \t]*url[ \t]*=[ \t]*)([^\r\n]+)", function(prefix, url)
        local swapped = swap_url(vim.trim(url))
        if not swapped then
          return prefix .. url
        end

        changed = true
        return prefix .. swapped
      end)

      if changed then
        local write_handle = io.open(config_file, "w")
        if write_handle then
          write_handle:write(next_content)
          write_handle:close()
          table.insert(updated_files, config_file)
        else
          vim.notify("Failed to write " .. config_file, vim.log.levels.ERROR)
        end
      end
    else
      vim.notify("Failed to read " .. config_file, vim.log.levels.ERROR)
    end
  end

  if #updated_files == 0 then
    print("No matching git URLs found under " .. cwd)
    return
  end

  print("Updated git remotes in " .. #updated_files .. " config file(s)")
end, { nargs = 0 })

vim.api.nvim_create_user_command("AmiRhMigration", function(opts)
  local migrationName = opts.args
  if migrationName == "" then
    print("Migration name is required")
    return
  end

  vim.cmd("vsplit")
  vim.cmd(
    "terminal "
      .. "/usr/local/share/dotnet/dotnet ef migrations add "
      .. "--project Enco.RoyHillAMI.Backend/Enco.RoyHillAMI.Backend.csproj "
      .. "--startup-project Enco.RoyHillAMI.Backend/Enco.RoyHillAMI.Backend.csproj "
      .. "--context Enco.RoyHillAMI.Backend.Db.AppDbContext "
      .. "--configuration Debug "
      .. migrationName
      .. " --output-dir Migrations"
  )
end, { nargs = 1 })

vim.api.nvim_create_user_command("AmiMigration", function(opts)
  local migrationName = opts.args
  if migrationName == "" then
    print("Migration name is required")
    return
  end

  vim.cmd("vsplit")
  vim.cmd(
    "terminal "
      .. "/usr/local/share/dotnet/dotnet ef migrations add "
      .. "--project Enco.AMI.RS.Data/Enco.AMI.RS.Data.csproj "
      .. "--startup-project Enco.AMI.RS.FMG.Backend/Enco.AMI.RS.FMG.Backend.csproj "
      .. "--context Enco.AMI.RS.Data.AppDbContext "
      .. "--configuration Debug "
      .. migrationName
      .. " --output-dir Migrations"
  )
end, { nargs = 1 })
