local keymap = require("sqlpilot.keymap")

local M = {}

function M.sql_create_autocmd(dbms)-- {{{
  local language
  if dbms == "mysql" then
    language = "mysql"
  elseif dbms == "postgresql" then
    language = "postgresql"
  elseif dbms == "oracle" then
    language = "plsql"
  elseif dbms == "mssql" then
    language = "tsql"
  else
    language = "sql"
  end

  local sqlpilot_buffer_settings = function()
    vim.api.nvim_set_hl(0, "Sql_Semicolon_WhitespaceEOL", { bg = "#c94f6d" })

    if vim.b.match_words == nil then
      vim.b.match_words = [[{:},(:),[:],\(\<CASE\>\|\<BEGIN\>\)\(\s\+TRAN\)\@!:\<WHEN\>:\<THEN\>:\<END\>,\(\<UPDATE\>\|\<SELECT\>\|\<DELETE\>\):\<FROM\>:\<WHERE\>,\<INSERT\>:\<VALUES\>]]
    end
    vim.api.nvim_set_option_value("equalprg", "sql-formatter -l "..language, { buf = 0 })

    keymap.sql_text_expander()
  end

  vim.api.nvim_create_augroup("sqlpilot",{ clear = true })
  vim.api.nvim_create_autocmd("Filetype", { group = "sqlpilot", pattern = "sql", callback = sqlpilot_buffer_settings})
  vim.api.nvim_create_autocmd("Filetype", { group = "sqlpilot", pattern = "sql", command = [[match Sql_Semicolon_WhitespaceEOL /\(;\s*\|\s\+\)$/]]})
end-- }}}

return M

-- vim: fdm=marker fdc=2
