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
