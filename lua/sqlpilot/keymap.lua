local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  vim.api.nvim_err_writeln("which-key is not installed; which is prerequisite!")
  return
end

local M = {}

-- locals
local ks = vim.keymap.set
local display_icon = "󰆼"

-- stylua: ignore start
local whichkey_initial_map = {
  create_tempfile  = { display = display_icon .. " create temp file", sql_mapping = "w" },
  scriptout_object = { display = display_icon .. " scriptout",        sql_mapping = "5" },
  select_dbenv     = { display = display_icon .. " list db env",      sql_mapping = ";" },
  change_dbenv     = { display = display_icon .. " change env",       sql_mapping = ":" },
  select_db        = { display = display_icon .. " list env db",      sql_mapping = "," },
  reset_dbenv      = { display = display_icon .. " reset env",        sql_mapping = "." },
}

local whichkey_initial_v_map = {
  adhoc_query_result_csv     = { display = display_icon .. " run csv",   sql_mapping = "d", sql_run_command_type = "sql_csv" },
  adhoc_query_result_cli_raw = { display = display_icon .. " run query", sql_mapping = "j", sql_run_command_type = "sql_cli" },
}

local whichkey_initial_format_map = {
  _forward  = { display = display_icon .. " /",  sql_mapping = "/" },
  _backword = { display = display_icon .. " \\", sql_mapping = "\\" },
}

local whichkey_dbobject_attribute_map = {
  selecttabledata_all         = { display = display_icon .. " select all",            sql_mapping = "a", vim_cmd = "new" },
  selecttabledata_top         = { display = display_icon .. " select top 100",        sql_mapping = "z", vim_cmd = "new" },
  selecttablecount            = { display = display_icon .. " select count",          sql_mapping = "c", vim_cmd = "new" },
  desc                        = { display = display_icon .. " desc",                  sql_mapping = "`", vim_cmd = "new" },
  schemaobject                = { display = display_icon .. " show schema",           sql_mapping = "1", vim_cmd = "50vnew" },
  schemaobject_enhanced       = { display = display_icon .. " show schema enhanced",  sql_mapping = "!", vim_cmd = "50vnew" },
  programmableobject          = { display = display_icon .. " show progobj",          sql_mapping = "2", vim_cmd = "50vnew" },
  programmableobject_enhanced = { display = display_icon .. " show progobj enhanced", sql_mapping = "@", vim_cmd = "50vnew" },
  listcolumns                 = { display = display_icon .. " show columns",          sql_mapping = "3", vim_cmd = "new" },
  descindex                   = { display = display_icon .. " desc index",            sql_mapping = "4", vim_cmd = "new" },
  contextinfo                 = { display = display_icon .. " show contextinfo",      sql_mapping = "6", vim_cmd = "new" },
  listjobs                    = { display = display_icon .. " show job",              sql_mapping = "7", vim_cmd = "new" },
  listfktables                = { display = display_icon .. " show fktables",         sql_mapping = "8", vim_cmd = "new" },
  listmetadata                = { display = display_icon .. " show metadata",         sql_mapping = "9", vim_cmd = "new" },
  referencedby                = { display = display_icon .. " show referencedby",     sql_mapping = "0", vim_cmd = "new" },
}
-- stylua: ignore end

local function n_reg()
  return require("sqlpilot.config").dict_which_key_registers.normal
end

local function v_reg()
  return require("sqlpilot.config").dict_which_key_registers.visual
end

local function which_key_n_deregister(object_attribute, prefix, mode)
  local m = whichkey_dbobject_attribute_map[object_attribute]
  local mapping = (prefix or "<leader>") .. n_reg() .. m.sql_mapping
  pcall(vim.api.nvim_del_keymap, mode or "n", mapping)
  which_key.add({ { mapping, hidden = true } })
end

local function which_key_n_register(object_attribute)
  local m = whichkey_dbobject_attribute_map[object_attribute]
  --[[ vim.print(m) ]]

  local key = "<leader>" .. n_reg() .. m.sql_mapping
  local n_mappings = {
    {
      key,
      "<Plug>(sql_" .. object_attribute .. ")",
      desc = m.display,
      nowait = true,
      remap = false,
      silent = true,
    },
  }

  which_key.add(n_mappings)
end

function M.sql_remove_invalid_whichkey_entries()
  local config = require("sqlpilot.config")
  local sqlpilot = require("sqlpilot")

  for object_attribute, _ in pairs(whichkey_dbobject_attribute_map) do
    local attribute_query = config.dict_query.query[object_attribute]
    if attribute_query[sqlpilot.sqlpilot_dict_command_param.dbms] == nil then
      --[[ print("not found " .. object_attribute) ]]
      which_key_n_deregister(object_attribute)
    else
      --[[ print("found " .. object_attribute) ]]
      which_key_n_register(object_attribute)
    end
  end
end

function M.sql_set_whichkey_initial_keymap()
  -- normal mode
  local key = "<leader>" .. n_reg()
  which_key.add({
    { key, group = display_icon .. " Sql", nowait = true, silent = true, remap = false },
  })

  for o, m in pairs(whichkey_initial_map) do
    key = "<leader>" .. n_reg() .. m.sql_mapping
    which_key.add({
      {
        key,
        "<Plug>(sql_" .. o .. ")",
        desc = m.display,
        nowait = true,
        silent = true,
        remap = false,
      },
    })
  end

  for _, m in pairs(whichkey_initial_format_map) do
    key = "<leader>" .. n_reg() .. m.sql_mapping
    which_key.add({
      {
        key,
        "<Plug>(sql_format_slash_toggle)",
        desc = m.display,
        nowait = true,
        silent = true,
        remap = false,
      },
    })
  end

  -- visual mode
  key = "<leader>" .. v_reg()
  which_key.add({
    {
      key,
      group = display_icon .. " Sql",
      mode = "v",
      nowait = true,
      silent = true,
      remap = false,
    },
  })

  for o, m in pairs(whichkey_initial_v_map) do
    key = "<leader>" .. v_reg() .. m.sql_mapping
    which_key.add({
      {
        key,
        "<Plug>(sql_" .. o .. ")",
        desc = m.display,
        mode = "v",
        nowait = true,
        silent = true,
        remap = false,
      },
    })
  end
end

function M.sql_set_keymap()
  local opts = { silent = true }

  -- visual map
  for o, m in pairs(whichkey_initial_v_map) do
    ks(
      "x",
      "<Plug>(sql_" .. o .. ")",
      string.format(
        '<ESC><CMD>lua require("sqlpilot").sql_adhoc_query_result("%s")<CR>',
        m.sql_run_command_type
      ),
      opts
    )
  end

  -- normal map
  for object_attribute, m in pairs(whichkey_dbobject_attribute_map) do
    ks(
      "n",
      "<Plug>(sql_" .. object_attribute .. ")",
      string.format(
        '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("%s","%s")<CR>',
        object_attribute,
        m.vim_cmd
      ),
      opts
    )
  end

  for o, _ in pairs(whichkey_initial_map) do
    ks(
      "n",
      "<Plug>(sql_" .. o .. ")",
      string.format('<CMD>lua require("sqlpilot").sql_%s()<CR>', o),
      opts
    )
  end

  ks(
    "n",
    "<Plug>(sql_format_slash_toggle)",
    '<CMD>lua require("sqlpilot").sql_format_slash_toggle()<CR>',
    opts
  )
end

-- stylua: ignore
function M.sql_text_expander()
  local opts = { silent = true, noremap = true, buffer = 0 }

  ks("i", ";s", "SELECT "          , opts)
  ks("i", ";b", "BEGIN"            , opts)
  ks("i", ";c", "COUNT(1) "        , opts)
  ks("i", ";d", "DECLARE "         , opts)
  ks("i", ";D", "DISTINCT "        , opts)
  ks("i", ";C", "CONVERT("         , opts)
  ks("i", ";e", "END"              , opts)
  ks("i", ";f", "FROM "            , opts)
  ks("i", ";g", "GROUP BY "        , opts)
  ks("i", ";h", "HAVING "          , opts)
  ks("i", ";i", "INSERT INTO "     , opts)
  ks("i", ";j", "INNER JOIN "      , opts)
  ks("i", ";m", "OPTION (MAXDOP 1)", opts)
  ks("i", ";N", "IS NOT NULL"      , opts)
  ks("i", ";o", "ORDER BY "        , opts)
  ks("i", ";s", "SELECT "          , opts)
  ks("i", ";l", "LIMIT 1 "         , opts)
  ks("i", ";l", "LATERAL "         , opts)
  ks("i", ";u", "UPDATE "          , opts)
  ks("i", ";U", "IS NULL"          , opts)
  ks("i", ";v", "VALUES("          , opts)
  ks("i", ";V", "varchar("         , opts)
  ks("i", ";w", "WHERE "           , opts)
  ks("i", ";x", "CROSS APPLY ("    , opts)

  ks("c", "2))", "\\([^\\t]*\\)\\t\\([^\\t]*\\)"                                                , opts)
  ks("c", "3))", "\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)"                                , opts)
  ks("c", "4))", "\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)"                , opts)
  ks("c", "5))", "\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)", opts)
end

return M
