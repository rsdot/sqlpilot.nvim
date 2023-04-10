local util = require("sqlpilot.util")
local config = require("sqlpilot.config")
local autocmd = require("sqlpilot.autocmd")
local keymap = require("sqlpilot.keymap")

local M = {}

M.sqlpilot_dict_command_param = {}

--  ╒══════════════════════════════════════════════════════════════════════════════╕
--    DB Connection settings {{{
-- stylua: ignore
local sql_set_sqlpilot_dict_command_param = function(product, dbenv)--{{{
  M.sqlpilot_dict_command_param.dbms      = product.dbms
  M.sqlpilot_dict_command_param.loginname = dbenv["loginname"] ~= nil and dbenv["loginname"] or product["loginname"]
  M.sqlpilot_dict_command_param.password  = dbenv["password"] ~= nil and dbenv["password"] or product["password"]
  M.sqlpilot_dict_command_param.alias     = dbenv.alias
  M.sqlpilot_dict_command_param.isprod    = dbenv.isprod
  M.sqlpilot_dict_command_param.dbserver  = dbenv.dbserver:find(':') ~= nil and dbenv.dbserver:match('(.+):') or dbenv.dbserver
  M.sqlpilot_dict_command_param.port      = dbenv.dbserver:find(':') ~= nil and dbenv.dbserver:match(':(%d+)') or ""

  autocmd.sql_create_autocmd(M.sqlpilot_dict_command_param.dbms)
  keymap.sql_remove_invalid_whichkey_entries()
end--}}}

-- stylua: ignore
function M.sql_print_sqlpilot_dict_command_param(flag)--{{{
  if flag == nil or flag ~= 1 then
    print(string.format("current setting: [%s (%s)] %s.%s"
      ,tostring(M.sqlpilot_dict_command_param.alias)
      ,tostring(M.sqlpilot_dict_command_param.dbserver)
      ,tostring(M.sqlpilot_dict_command_param.dbname)
      ,tostring(M.sqlpilot_dict_command_param.loginname)
    ))
  else
    print(""
      .."dbms: "     ..tostring(M.sqlpilot_dict_command_param.dbms)     .."\n"
      .."isprod: "   ..tostring(M.sqlpilot_dict_command_param.isprod)   .."\n"
      .."alias: "    ..tostring(M.sqlpilot_dict_command_param.alias)    .."\n"
      .."dbserver: " ..tostring(M.sqlpilot_dict_command_param.dbserver) .."\n"
      .."port: "     ..tostring(M.sqlpilot_dict_command_param.port)     .."\n"
      .."dbname: "   ..tostring(M.sqlpilot_dict_command_param.dbname)   .."\n"
      .."loginname: "..tostring(M.sqlpilot_dict_command_param.loginname).."\n"
      .."password: " ..tostring(M.sqlpilot_dict_command_param.password) .."\n"
      .."command: "  ..tostring(M.sqlpilot_dict_command_param.command)  .."\n"
    )
  end
end--}}}

function M.sql_select_db() --{{{
  if M.sqlpilot_dict_command_param["dbms"] == nil then
    M.sql_select_dbenv()
  end

  --  ┌                                                                              ┐
  --  │ for db choice                                                                │
  --  └                                                                              ┘
  local dbname_list = M.sqlpilot_dict_command_param.dbname_list

  vim.ui.select(dbname_list, { prompt = "Please choice dbname:" }, function(_, idx)
    if idx == nil then
      return nil
    end

    local dbname = dbname_list[idx]:match("[^%s]+")
    if dbname == nil then
      M.sqlpilot_dict_command_param.dbname = "tobeselected"
      return nil
    end

    M.sqlpilot_dict_command_param.dbname = dbname
  end)
end --}}}

local sql_select_dbenv_individual = function(product) --{{{
  --  ┌                                                                              ┐
  --  │ for dbenv choice                                                             │
  --  └                                                                              ┘
  vim.ui.select(product.dbenv, { prompt = "Please choice dbenv:", format_item = function(item)
      return string.format("%-20s (%s)", item.alias, item.dbserver)
    end,
  }, function(_, idx)
    -- product.dbenv[idx] looks like: {"desc":"manager.local","dbname":["tpcc1"],"dbserver":"10.10.10.100:3306","alias":"manager.local"}
    local dbenv = product.dbenv[idx]
    if dbenv == nil then
      return nil
    end

    local dbname_list = dbenv["dbname"] ~= nil and dbenv["dbname"] or product["dbname"]

    M.sqlpilot_dict_command_param.dbname_list = dbname_list

    sql_set_sqlpilot_dict_command_param(product, dbenv)
    M.sql_select_db()
  end)
end --}}}

function M.sql_select_dbenv() --{{{
  --  ┌                                                                              ┐
  --  │ for product choice                                                           │
  --  └                                                                              ┘
  local sorted_product_name = {}
  for product_name, _ in pairs(M.dict_conn.Product) do
    table.insert(sorted_product_name, product_name)
  end
  table.sort(sorted_product_name)

  vim.ui.select(sorted_product_name, { prompt = "Please choice product:" }, function(choice)
    local product = M.dict_conn.Product[choice]
    if product == nil then return nil end
    sql_select_dbenv_individual(product)
  end)
end --}}}

local sql_change_dbenv_password = function()-- {{{
  --  ┌                                                                              ┐
  --  │ for sqlpilot_dict_command_param.password                                     │
  --  └                                                                              ┘
  vim.cmd("redraw!")
  local message = string.format(
    "[%s]%s.%s.%s.<%s>",
    M.sqlpilot_dict_command_param.alias,
    M.sqlpilot_dict_command_param.dbserver,
    M.sqlpilot_dict_command_param.dbname,
    M.sqlpilot_dict_command_param.loginname,
    M.sqlpilot_dict_command_param.password
  )

  vim.ui.input({
    prompt = string.format("Enter DB Password %s: ", message),
    default = M.sqlpilot_dict_command_param.password,
  }, function(input)
    if input == nil then
      vim.api.nvim_err_writeln("no password change made(" .. message .. ")")
    else
      M.sqlpilot_dict_command_param.password = input

      message = string.format(
        "[%s]%s.%s.<%s>",
        M.sqlpilot_dict_command_param.alias,
        M.sqlpilot_dict_command_param.dbserver,
        M.sqlpilot_dict_command_param.dbname,
        M.sqlpilot_dict_command_param.loginname
      )

      vim.cmd("redraw!")
      print("Current Setting: " .. message)
    end
  end)
end-- }}}

local sql_change_dbenv_loginname = function()-- {{{
  --  ┌                                                                              ┐
  --  │ for sqlpilot_dict_command_param.loginname                                    │
  --  └                                                                              ┘
  vim.cmd("redraw!")
  local message = string.format(
    "[%s]%s.%s.<%s>",
    M.sqlpilot_dict_command_param.alias,
    M.sqlpilot_dict_command_param.dbserver,
    M.sqlpilot_dict_command_param.dbname,
    M.sqlpilot_dict_command_param.loginname
  )
  vim.ui.input({
    prompt = string.format("Enter DB Loginname %s: ", message),
    default = M.sqlpilot_dict_command_param.loginname,
  }, function(input)
    if input == nil then
      vim.api.nvim_err_writeln("no loginname change made(" .. message .. ")")
    else
      M.sqlpilot_dict_command_param.loginname = input

      sql_change_dbenv_password()
    end
  end)
end-- }}}

local sql_change_dbenv_dbname = function()-- {{{
  --  ┌                                                                              ┐
  --  │ for sqlpilot_dict_command_param.dbname                                       │
  --  └                                                                              ┘
  vim.cmd("redraw!")
  local message = string.format(
    "[%s]%s.<%s>",
    M.sqlpilot_dict_command_param.alias,
    M.sqlpilot_dict_command_param.dbserver,
    M.sqlpilot_dict_command_param.dbname
  )
  vim.ui.input({
    prompt = string.format("Enter DB Name %s: ", message),
    default = M.sqlpilot_dict_command_param.dbname,
  }, function(input)
    if input == nil then
      vim.api.nvim_err_writeln("no dbname change made(" .. message .. ")")
    else
      M.sqlpilot_dict_command_param.dbname = input

      sql_change_dbenv_loginname()
    end
  end)
end-- }}}

local sql_change_dbenv_port = function()-- {{{
  --  ┌                                                                              ┐
  --  │ for sqlpilot_dict_command_param.port                                         │
  --  └                                                                              ┘
  vim.cmd("redraw!")
  local message = string.format("<%s>", M.sqlpilot_dict_command_param.port)
  local sql_cli = M.dict_run.dbms[M.sqlpilot_dict_command_param.dbms].sql_cli
  if vim.regex([[{port}]]):match_str(sql_cli.command) ~= nil then
    vim.ui.input({
      prompt = string.format("Enter DB Server Port %s: ", message),
      default = M.sqlpilot_dict_command_param.port,
    }, function(input)
      if input == nil then
        vim.api.nvim_err_writeln("no port change made(" .. message .. ")")
      else
        M.sqlpilot_dict_command_param.port = input

        sql_change_dbenv_dbname()
      end
    end)
  end
end-- }}}

local sql_change_dbenv_dbserver = function()-- {{{
  --  ┌                                                                              ┐
  --  │ for sqlpilot_dict_command_param.dbserver                                     │
  --  └                                                                              ┘
  vim.cmd("redraw!")
  local message = string.format(
    "[%s]<%s>",
    M.sqlpilot_dict_command_param.alias,
    M.sqlpilot_dict_command_param.dbserver
  )
  vim.ui.input({
    prompt = string.format("Enter DB Server %s: ", message),
    default = M.sqlpilot_dict_command_param.dbserver,
  }, function(input)
    if input == nil then
      vim.api.nvim_err_writeln("no alias & dbserver change made(" .. message .. ")")
    else
      M.sqlpilot_dict_command_param.alias = input
      M.sqlpilot_dict_command_param.dbserver = input

      sql_change_dbenv_port()
    end
  end)
end-- }}}

function M.sql_change_dbenv() --{{{
  if M.sqlpilot_dict_command_param["dbms"] == nil then
    M.sql_select_dbenv()
  end

  sql_change_dbenv_dbserver()
end --}}}

function M.sql_reset_dbenv() --{{{
  if M.sqlpilot_dict_command_param["dbms"] ~= nil then
    M.sqlpilot_dict_command_param.dbms = nil
  end

  M.sql_select_dbenv()
end --}}}

--}}}
--  ╘══════════════════════════════════════════════════════════════════════════════╛

--  ╒══════════════════════════════════════════════════════════════════════════════╕
-- DB Query window {{{
local sql_param_gsub = function(text, param_gsub) --{{{
  for key, value in pairs(param_gsub) do
    text = string.gsub(text, "{" .. key .. "}", value)
  end
  return text
end --}}}

local sql_prepare_infile_outfile = function() --{{{
  local tmpname = os.tmpname()
  M.sqlpilot_dict_command_param.infile = tmpname .. ".sql"
  M.sqlpilot_dict_command_param.outfile = tmpname .. ".out"
  os.remove(tmpname)
end --}}}

local sql_write_query_to_infile = function(query) --{{{
  local sql_cli = M.dict_run.dbms[M.sqlpilot_dict_command_param.dbms].sql_cli

  query = string.format(
    "%s\n%s\n%s",
    sql_cli["header"] ~= nil and sql_cli["header"] or "",
    query,
    sql_cli["footer"] ~= nil and sql_cli["footer"] or ""
  )

  sql_prepare_infile_outfile()
  M.sqlpilot_dict_command_param.query = query
  vim.fn.setreg(M.dict_registers.query, query)
  util.string_to_file(query, M.sqlpilot_dict_command_param.infile)
end --}}}

local function sql_load_query_result_to_buffer(bufno, param_gsub) -- {{{
  -- for lualine inactive buffer
  vim.b.sqlpilot_display_result = string.format(
    "%s.%s ∞ %s ∞",
    M.sqlpilot_dict_command_param.alias,
    M.sqlpilot_dict_command_param.dbname,
    vim.fn.strftime("%m/%d-%H:%M:%S")
  )

  local array

  if param_gsub ~= nil then
    array = util.file_to_array(param_gsub.objectfile)
    os.remove(param_gsub.objectfile)
  else
    array = util.file_to_array(M.sqlpilot_dict_command_param.outfile)
    os.remove(M.sqlpilot_dict_command_param.infile)
    os.remove(M.sqlpilot_dict_command_param.outfile)
  end

  if #array == 0 then
    array = {
      string.format(
        "<<<empty, cmd stored in reg: %s, query stored in reg: %s>>>",
        tostring(M.dict_registers.cmd),
        tostring(M.dict_registers.query)
      ),
    }
  end

  vim.api.nvim_buf_set_lines(bufno, 0, -1, false, array)
end -- }}}

local sql_execute_command = function(sql_run_command_type, vim_cmd, param_gsub) --{{{
  local sql_run_command =
    M.dict_run.dbms[M.sqlpilot_dict_command_param.dbms][sql_run_command_type].command

  if param_gsub ~= nil then
    sql_run_command = sql_param_gsub(sql_run_command, param_gsub)
  end

  for key, value in pairs(M.sqlpilot_dict_command_param) do
    -- print(string.format("key: %s, value: %s\n", key, value))
    sql_run_command = string.gsub(sql_run_command, "{" .. key .. "}", value)
  end

  M.sqlpilot_dict_command_param.command = sql_run_command
  vim.fn.setreg(M.dict_registers.cmd, sql_run_command)

  -- split/vspit new buffer window and async wait
  vim.api.nvim_command(vim_cmd)
  local bufno = vim.api.nvim_get_current_buf()

  vim.fn.jobstart(sql_run_command, {
    stdout_buffered = true,
    on_stdout = function(jobid, _, _)
      local array = {
        string.format(
          "<<<[%d] waiting for run result, kill by :call jobstop(%d), cmd stored in reg: %s, query stored in reg: %s>>>",
          jobid,
          jobid,
          tostring(M.dict_registers.cmd),
          tostring(M.dict_registers.query)
        ),
      }
      vim.api.nvim_buf_set_lines(bufno, 0, -1, false, array)
    end,
    on_exit = function(_, _, _)
      sql_load_query_result_to_buffer(bufno, param_gsub)
    end,
  })
end --}}}

function M.sql_adhoc_query_result(sql_run_command_type) --{{{
  if M.sqlpilot_dict_command_param["dbms"] == nil then
    M.sql_select_dbenv()
  end

  -- visual lines
  local startline = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
  local endline = vim.api.nvim_buf_get_mark(0, ">")[1]
  -- print (startline, endline)
  local selected_lines = vim.api.nvim_buf_get_lines(0, startline, endline, false)
  local query = table.concat(selected_lines, "\n")

  sql_write_query_to_infile(query)
  sql_execute_command(sql_run_command_type, "new")
end --}}}

function M.sql_list_dbobject_attribute(attribute_query, vim_cmd) --{{{
  if M.sqlpilot_dict_command_param["dbms"] == nil then
    M.sql_select_dbenv()
  end

  local query_lines = M.dict_query.query[attribute_query][M.sqlpilot_dict_command_param.dbms]
  if query_lines == nil then
    print("query for " .. attribute_query .. " doesn't exist!")
    return nil
  end
  local query = table.concat(query_lines, "\n")

  local param_gsub = {}
  param_gsub.dbname = M.sqlpilot_dict_command_param.dbname
  param_gsub.loginname = M.sqlpilot_dict_command_param.loginname
  param_gsub.objectname = vim.fn.expand("<cword>")

  query = sql_param_gsub(query, param_gsub)

  sql_write_query_to_infile(query)
  sql_execute_command("sql_cli", vim_cmd)
end --}}}

--}}}
--  ╘══════════════════════════════════════════════════════════════════════════════╛

--  ╒══════════════════════════════════════════════════════════════════════════════╕
-- Scripting out DB object {{{
function M.sql_scriptout_object() --{{{
  if M.sqlpilot_dict_command_param["dbms"] == nil then
    M.sql_select_dbenv()
  end

  local param_gsub = {}
  param_gsub.objectname = vim.fn.expand("<cword>")
  param_gsub.objectfile = "/tmp/" .. param_gsub.objectname .. ".sql"
  param_gsub.schemaname = "dbo" -- for MSSQL default
  param_gsub.scriptpath = M.plugin_path .. "/scripts"

  sql_execute_command("sql_ddl", "new", param_gsub)
end --}}}

--}}}
--  ╘══════════════════════════════════════════════════════════════════════════════╛

--  ╒══════════════════════════════════════════════════════════════════════════════╕
-- Format {{{
function M.sql_format_slash_toggle() --{{{
  local current_line = vim.api.nvim_get_current_line()
  if vim.regex("\\"):match_str(current_line) ~= nil then
    current_line, _ = string.gsub(current_line, "\\", "/")
  else
    current_line, _ = string.gsub(current_line, "/", "\\")
  end
  vim.api.nvim_set_current_line(current_line)
end --}}}

--}}}
--  ╘══════════════════════════════════════════════════════════════════════════════╛

--  ╒══════════════════════════════════════════════════════════════════════════════╕
-- Misc {{{
function M.sql_create_tempfile() --{{{
  local tmpname = os.tmpname()
  os.remove(tmpname)
  vim.cmd("silent write " .. tmpname .. ".sql")
end --}}}

function M.reset() --{{{
  require("plenary.reload").reload_module("sqlpilot")
  require("sqlpilot").setup()
  M.sqlpilot_dict_command_param.dbms = nil
end --}}}

--}}}
--  ╘══════════════════════════════════════════════════════════════════════════════╛

setmetatable(M, config)

return M

-- vim: fdm=marker fdc=2
