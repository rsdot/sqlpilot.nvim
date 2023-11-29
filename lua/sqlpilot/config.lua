local keymap = require("sqlpilot.keymap")
local util = require("sqlpilot.util")

local M = {}

M.plugin_path = util.plugin_path()
M.options = {}
M.dict_conn = {}
M.dict_query = {}
M.dict_run = {}
M.dict_registers = {}
M.dict_which_key_registers = {}

-- stylua: ignore
local defaults = {
  sql_conn  = M.plugin_path .. "/resources/sql_conn.json",
  sql_query = M.plugin_path .. "/resources/sql_query.json",
  sql_run   = M.plugin_path .. "/resources/sql_run.json",
  registers = {
    cmd   = "y", -- default vim register to store last used cmd
    query = "z", -- default vim register to store last used query
  },
  which_key_registers = {
    normal = "f", -- default which-key normal mode key register
    visual = "f", -- default which-key visual mode key register
  },
}

-- stylua: ignore
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  -- print(vim.inspect(M.options))

  M.dict_conn                = util.jsonfile_to_dict(M.options.sql_conn)
  M.dict_query               = util.jsonfile_to_dict(M.options.sql_query)
  M.dict_run                 = util.jsonfile_to_dict(M.options.sql_run)
  M.dict_registers           = M.options.registers
  M.dict_which_key_registers = M.options.which_key_registers

  if M.dict_conn == nil then
    print("M.dict_conn is nil")
    return nil
  end

  keymap.sql_set_keymap()
  keymap.sql_set_whichkey_initial_keymap()
end

M.__index = function(t, k)
  if M[k] == nil then
    print("can't find declared variables")
    return nil
  else
    return M[k]
  end
end

M.__newindex = function(t, k, v)
  if M[k] == nil then
    print(
      string(
        "can't set new variables for %s, %s, %s",
        vim.inspect(t),
        vim.inspect(k),
        vim.inspect(v)
      )
    )
    return nil
  end
end

return M
