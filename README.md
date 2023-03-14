# sqlpilot.nvim

A neovim plugin for navigating database schemas and executing custom queries across multiple RDBMS and NoSQL DBs

## Why?

- ❤️  **KISS**:
  <ol>Designed to be loose couple interaction with a variety type of DBs' CLI utility and <b>sqlpilot.nvim</b>.</ol>
- 🚀 **Fast**:
  <ol>Async execution of query without blocking editing mode.</ol>
- 🌟 **Featured**:
  <ol>
  <li>Bundled with common used queries supportting Oracle, MySQL, PostgreSQL, Aurora MySQL/PostgreSQL, MongoDB, Cassandra, SQL Server (<I>comming soon</I>)</li>
  <li>Text expander in Insert mode for dozens of SQL keywords.</li>
  <li>Underline query and CLI command executed with actual parameter values can be easily obtained for troubleshooting.</li>
  <li>Display current connected DBs and snapshot of execution time in previous run result buffer window together with <a href="https://github.com/nvim-lualine/lualine.nvim">lualine</a>.</li>
  </ol>
- 💎 **Extensibility**:
  <ol>Fully customized scripts in language of your choice to extend support of other DBs with command line interface(CLI).</ol>


## Installation


#### with [packer.nvim](https://github.com/wbthomason/packer.nvim)

1. obtain a copy of [resources/sql_conn.json](resources/sql_conn.json), change appropriately and stored in `~/projects/xxxx/sqlpilot.nvim/resources/sql_conn.json` (example path)

2. use `sqlpilot.nvim`

    ```lua
    use {
      "rsdot/sqlpilot.nvim",
      config = function()
        require("sqlpilot").setup {
          sql_conn  = vim.fn.glob("~").."/projects/xxxx/sqlpilot.nvim/resources/sql_conn.json", -- required
        }
      end
    }
    ```


## Configuration

1. Shortcut keys with [which-key.nvim](https://github.com/folke/which-key.nvim) is highly recommended to use with `sqlpilot.nvim` together, see example of pre-defined shortcut keys for dozens of bundled queries.

    <details><summary>Example of setup with which-key.nvim</summary>

    ```lua
    local setup = {
      ...
    }

    local n_opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }

    local v_opts = {
      mode = "v", -- visual mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }

    local n_mappings = {
      ...
      f = {
        name = "Sql ",
        ["w"] = { "<Plug>(sql_create_tempfile)", " create temp file" },
        ["a"] = { "<Plug>(sql_selecttabledata_all)", " select all" },
        ["z"] = { "<Plug>(sql_selecttabledata_top)", " select top" },
        ["c"] = { "<Plug>(sql_selecttablecount)", " select count" },
        ["`"] = { "<Plug>(sql_desc)", " desc" },
        ["1"] = { "<Plug>(sql_schemaobject)", " schema" },
        ["!"] = { "<Plug>(sql_schemaobject_enhanced)", " schema enhanced" },
        ["2"] = { "<Plug>(sql_programmableobject)", " progobj" },
        ["@"] = { "<Plug>(sql_programmableobject_enhanced)", " progobj enhanced" },
        ["3"] = { "<Plug>(sql_listcolumns)", " columns" },
        ["4"] = { "<Plug>(sql_descindex)", " desc index" },
        ["5"] = { "<Plug>(sql_scriptout_object)", " scriptout" },
        ["%"] = { "<Plug>(sql_scriptout_objects_tofolder)", " scriptout tofolder" },
        ["6"] = { "<Plug>(sql_contextinfo)", " contextinfo" },
        ["7"] = { "<Plug>(sql_listjobs)", " job" },
        ["&"] = { "<Plug>(sql_scriptout_job)", " scriptout job" },
        ["8"] = { "<Plug>(sql_listfktables)", " fktables" },
        ["9"] = { "<Plug>(sql_listmetadata)", " metadata" },
        ["0"] = { "<Plug>(sql_referencedby)", " referencedby" },
        [";"] = { "<Plug>(sql_select_dbenv)", " list db env" },
        [":"] = { "<Plug>(sql_change_dbenv)", " change env" },
        [","] = { "<Plug>(sql_select_db)", " list env db" },
        ["."] = { "<Plug>(sql_reset_dbenv)", " reset env" },

        F = {
          name = "Sql format ",
          ["/"] = { "<Plug>(sql_format_slash_toggle)", " /" },
          ["\\"] = { "<Plug>(sql_format_slash_toggle)", " \\" },
        },
      },
      ...
    }

    local v_mappings = {
      ...
      f = {
        name = "Sql ",
        ["d"] = { "<Plug>(sql_adhoc_query_result_csv)", " run csv" },
        ["f"] = { "<Plug>(sql_adhoc_query_result_cli_raw)", " run query" },
      },
      ...
    }

    which_key.setup(setup)
    which_key.register(n_mappings, n_opts)
    which_key.register(v_mappings, v_opts)
    ```

    </details>

2. Integration with [lualine](https://github.com/nvim-lualine/lualine.nvim) to display current connected DBs and snapshot of execution time in previous run result buffer window

    <details><summary>Example of setup with lualine</summary>

    ```lua
    local sqlpilot = require("sqlpilot")

    local function db_conn_string()
      if sqlpilot.sqlpilot_dict_command_param.alias ~= nil and
        sqlpilot.sqlpilot_dict_command_param.dbname ~= nil then
        local dbmstype = sqlpilot.sqlpilot_dict_command_param.dbms
        local dbmsicon = ''
        if dbmstype == 'mssql' then
          dbmsicon = ''
        elseif dbmstype == 'mysql' then
          dbmsicon = ''
        elseif dbmstype == 'postgresql' then
          dbmsicon = ''
        elseif dbmstype == 'cassandra' then
          dbmsicon = ''
        elseif dbmstype == 'mongodb' then
          dbmsicon = ''
        elseif dbmstype == 'oracle' then
          dbmsicon = 'ﱤ'
        end

        return '⟛ ' .. dbmsicon .. sqlpilot.sqlpilot_dict_command_param.alias .. '.' .. sqlpilot.sqlpilot_dict_command_param.dbname
      else
        return ''
      end
    end

    local dbconn_prod = {
      'dbconn_prod',
      cons_enabled = true,
      icon = '',
      fmt = db_conn_string,
      color = {fg = '#a14f6d', gui='italic,bold'},
      cond = function()
        return sqlpilot.sqlpilot_dict_command_param.alias ~= nil and sqlpilot.sqlpilot_dict_command_param.isprod == 1
      end,
    }

    local dbconn_nonprod = {
      'dbconn_nonprod',
      cons_enabled = true,
      icon = '',
      fmt = db_conn_string,
      color = {fg = '#63c259', gui='italic'},
      cond = function()
        return sqlpilot.sqlpilot_dict_command_param.alias ~= nil and sqlpilot.sqlpilot_dict_command_param.isprod == 0
      end,
    }

    local dbresult = {
      'dbresult',
      fmt = function()
        return vim.b.sqlpilot_display_result ~= nil and vim.b.sqlpilot_display_result or ''
      end,
      color = {fg = '#5f5f87'},
    }

    require("lualine").setup({
      ...
      sections = {
        ...
        lualine_c = { dbresult },
        lualine_x = { dbconn_prod, dbconn_nonprod },
        ...
      },
      inactive_sections = {
        ...
        lualine_c = { dbresult },
        lualine_x = {},
        ...
      },
      ...
    })
    ```

    </details>


## Usage examples

<details><summary>Text expander</summary>

In `Insert` mode

| type | substituted with |
|------|------------------|
| `;s` | `SELECT `        |
| `;f` | `FROM `          |
| `;w` | `WHERE `         |
| `;c` | `COUNT(1) `      |
| `;o` | `ORDER BY `      |
| `;l` | `LIMIT 1 `       |
| `;g` | `GROUP BY `      |
| `;h` | `HAVING `        |
| `;i` | `INSERT INTO `   |
| `;v` | `VALUES(`        |
| `;i` | `INNER JOIN `    |
| `;u` | `UPDATE `        |
| `;N` | `IS NOT NULL`    |
| `;U` | `IS NULL`        |
| `;b` | `BEGIN`          |
| `;e` | `END`            |

</details>

<details><summary>Executing ad-hoc queries</summary>

`<space>f;` to setup DB connection, in `Visual Line` mode, select lines, then `<space>ff` to run query **async**. Result would show up in the buffer window once they are ready, not blocking current editing 

**mysql** example
```sql
SELECT now();
SELECT SLEEP(10);
SELECT now();
```

</details>

<details><summary>View table index definition</summary>

In `Normal` mode, move cursor on top of a table name, then `<space>f4` to view index defintion of the table under the cursor

</details>


## Extensibility

<details><summary>Tweak CLI run commands</summary>

obtain a copy of [resources/sql_run.json](resources/sql_run.json), change appropriately and stored in `~/projects/xxxx/sqlpilot.nvim/resources/sql_conn.json` (example path)

for each dbms, program/scripts (with full path and excutable) referenced by following commands attributes can be tweaked.

postgresql as example

```json
  ...
  "postgresql": {
    "sql_csv": {
      "command": "PGCONNECT_TIMEOUT=3 PGPASSWORD='{password}' psql -P pager=off -v ON_ERROR_STOP=1 -h {dbserver} -U {loginname} -p {port} -d {dbname} -f {infile} > {outfile} 2>&1",
      "header": [
        "COPY",
        "("
      ],
      "footer": [
        ")",
        "TO STDOUT",
        "WITH CSV HEADER"
      ]
    },
    "sql_cli": {
      "command": "PGCONNECT_TIMEOUT=3 PGPASSWORD='{password}' psql -P pager=off -v ON_ERROR_STOP=1 -h {dbserver} -U {loginname} -p {port} -d {dbname} -f {infile} > {outfile} 2>&1"
    },
    "sql_ddl": {
      "command": "{scriptpath}/ddl_postgresql.sh -h {dbserver} -p {port} -U {loginname} -P '{password}' -d {dbname} -o {objectname} > {objectfile} 2>&1"
    }
  },
  ...
```

</details>

<details><summary>Modify queries</summary>

obtain a copy of [resources/sql_query.json](resources/sql_query.json), change appropriately and stored in `~/projects/xxxx/sqlpilot.nvim/resources/sql_query.json` (example path)

</details>

<details open><summary>Put all together</summary>

use `sqlpilot.nvim`

```lua
use {
  "rsdot/sqlpilot.nvim",
  config = function()
    require("sqlpilot").setup {
      sql_conn  = vim.fn.glob("~").."/projects/xxxx/sqlpilot.nvim/resources/sql_conn.json",  -- required
      sql_query = vim.fn.glob("~").."/projects/xxxx/sqlpilot.nvim/resources/sql_query.json", -- overwrite default
      sql_run   = vim.fn.glob("~").."/projects/xxxx/sqlpilot.nvim/resources/sql_run.json",   -- overwrite default
      registers = {
        cmd   = "y", -- store last used cmd                                                -- change to other register if needed
        query = "z"  -- store last used query                                              -- change to other register if needed
      }
    }
  end
}
```

- In `Normal` mode, `"yp` will paste content from register `y`, which stores last used cmd with actual parameter values
- In `Normal` mode, `"zp` will paste content from register `z`, which stores last used query

</details>
