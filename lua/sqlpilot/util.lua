local M = {}

function M.jsonfile_to_dict(jsonfile)-- {{{
  local file = io.open(jsonfile,"r")

  if file == nil then
    print("can't find " .. jsonfile)
    return nil
  end

  local file_content = vim.fn.json_decode(file:read("a"))
  file:close()

  -- print(jsonfile)
  return file_content
end-- }}}

function M.dict_to_jsonstring(dict)-- {{{
  return vim.fn.json_encode(dict)
end-- }}}

function M.file_to_string(infile)-- {{{
  local file = io.open(infile,"r")

  if file == nil then
    print("can't find " .. infile)
    return nil
  end

  local file_content = file:read("a")
  file:close()

  -- print(infile)
  return file_content
end-- }}}

function M.file_to_array(infile)-- {{{
  local file = io.open(infile,"r")

  if file == nil then
    print("can't find " .. infile)
    return nil
  end

  local array = {}
  local line = file:read("*l")
  while line do
    table.insert(array, line)
    line = file:read("*l")
  end
  file:close()

  return array
end-- }}}

function M.string_to_file(content, outfile)-- {{{
  local file = io.open(outfile,"w")

  if file == nil then
    print("can't write " .. outfile)
    return nil
  end

  file:write(content)
  file:close()
end-- }}}

function M.stringlines_to_array(content)-- {{{
  local array = {}
  for line in content:gmatch("([^\n]*)\n?") do
    table.insert(array,line)
  end
  return array
end-- }}}

function M.plugin_path()-- {{{
  local function is_win()
    return package.config:sub(1, 1) == '\\'
  end

  local function get_path_separator()
    if is_win() then
      return '\\'
    end
    return '/'
  end

  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*)' ..
    get_path_separator() ..
    '.*' .. get_path_separator() ..
    '.*' .. get_path_separator()
  )
end-- }}}

return M

-- vim: fdm=marker fdc=2
