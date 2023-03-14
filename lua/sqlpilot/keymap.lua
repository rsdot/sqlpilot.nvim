local M = {}

local ks = vim.keymap.set

function M.sql_set_keymap()
  local opts = { silent = true }

  -- visual map
  ks('x', '<Plug>(sql_adhoc_query_result_cli_raw)',  '<ESC><CMD>lua require("sqlpilot").sql_adhoc_query_result("sql_cli")<CR>',                              opts)
  ks('x', '<Plug>(sql_adhoc_query_result_csv)',      '<ESC><CMD>lua require("sqlpilot").sql_adhoc_query_result("sql_csv")<CR>',                              opts)
  ks('x', '<Plug>(sql_scriptout_objects_tofolder)',  '<ESC><CMD>lua require("sqlpilot").sql_scriptout_objects_tofolder()<CR>',                               opts)

  -- normal map
  ks('n', '<Plug>(sql_schemaobject)',                '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("schemaobject","40vnew")<CR>',                opts)
  ks('n', '<Plug>(sql_schemaobject_enhanced)',       '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("schemaobject_enhanced","40vnew")<CR>',       opts)
  ks('n', '<Plug>(sql_programmableobject)',          '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("programmableobject","40vnew")<CR>',          opts)
  ks('n', '<Plug>(sql_programmableobject_enhanced)', '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("programmableobject_enhanced","40vnew")<CR>', opts)
  ks('n', '<Plug>(sql_listcolumns)',                 '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("listcolumns","new")<CR>',                    opts)
  ks('n', '<Plug>(sql_descindex)',                   '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("descindex","new")<CR>',                      opts)
  ks('n', '<Plug>(sql_contextinfo)',                 '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("contextinfo","new")<CR>',                    opts)
  ks('n', '<Plug>(sql_listjobs)',                    '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("listjobs","new")<CR>',                       opts)
  ks('n', '<Plug>(sql_listfktables)',                '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("listfktables","new")<CR>',                   opts)
  ks('n', '<Plug>(sql_listmetadata)',                '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("listmetadata","new")<CR>',                   opts)
  ks('n', '<Plug>(sql_referencedby)',                '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("referencedby","new")<CR>',                   opts)
  ks('n', '<Plug>(sql_desc)',                        '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("desc","new")<CR>',                           opts)
  ks('n', '<Plug>(sql_selecttabledata_all)',         '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("selecttabledata_all","new")<CR>',            opts)
  ks('n', '<Plug>(sql_selecttabledata_top)',         '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("selecttabledata_top","new")<CR>',            opts)
  ks('n', '<Plug>(sql_selecttablecount)',            '<CMD>lua require("sqlpilot").sql_list_dbobject_attribute("selecttablecount","new")<CR>',               opts)

  ks('n', '<Plug>(sql_select_dbenv)',                '<CMD>lua require("sqlpilot").sql_select_dbenv()<CR>',                                                  opts)
  ks('n', '<Plug>(sql_change_dbenv)',                '<CMD>lua require("sqlpilot").sql_change_dbenv()<CR>',                                                  opts)
  ks('n', '<Plug>(sql_select_db)',                   '<CMD>lua require("sqlpilot").sql_select_db()<CR>',                                                     opts)
  ks('n', '<Plug>(sql_reset_dbenv)',                 '<CMD>lua require("sqlpilot").sql_reset_dbenv()<CR>',                                                   opts)

  ks('n', '<Plug>(sql_scriptout_object)',            '<CMD>lua require("sqlpilot").sql_scriptout_object()<CR>',                                              opts)

  ks('n', '<Plug>(sql_create_tempfile)',             '<CMD>lua require("sqlpilot").sql_create_tempfile()<CR>',                                               opts)
  ks('n', '<Plug>(sql_format_slash_toggle)',         '<CMD>lua require("sqlpilot").sql_format_slash_toggle()<CR>',                                           opts)

end

function M.sql_text_expander()
  local opts = { silent = true, noremap = true, buffer = 0 }

  ks('i', ';s', 'SELECT ',           opts)
  ks('i', ';b', 'BEGIN',             opts)
  ks('i', ';c', 'COUNT(1) ',         opts)
  ks('i', ';d', 'DECLARE ',          opts)
  ks('i', ';D', 'DISTINCT ',         opts)
  ks('i', ';C', 'CONVERT(',          opts)
  ks('i', ';e', 'END',               opts)
  ks('i', ';f', 'FROM ',             opts)
  ks('i', ';g', 'GROUP BY ',         opts)
  ks('i', ';h', 'HAVING ',           opts)
  ks('i', ';i', 'INSERT INTO ',      opts)
  ks('i', ';j', 'INNER JOIN ',       opts)
  ks('i', ';m', 'OPTION (MAXDOP 1)', opts)
  ks('i', ';N', 'IS NOT NULL',       opts)
  ks('i', ';o', 'ORDER BY ',         opts)
  ks('i', ';s', 'SELECT ',           opts)
  ks('i', ';l', 'LIMIT 1 ',          opts)
  ks('i', ';u', 'UPDATE ',           opts)
  ks('i', ';U', 'IS NULL',           opts)
  ks('i', ';v', 'VALUES(',           opts)
  ks('i', ';V', 'nvarchar(',         opts)
  ks('i', ';w', 'WHERE ',            opts)
  ks('i', ';x', 'CROSS APPLY (',     opts)

  ks('c', '2))', '\\([^\\t]*\\)\\t\\([^\\t]*\\)',                                                 opts)
  ks('c', '3))', '\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)',                                 opts)
  ks('c', '4))', '\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)',                 opts)
  ks('c', '5))', '\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)\\t\\([^\\t]*\\)', opts)
end

return M

