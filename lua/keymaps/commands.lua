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
