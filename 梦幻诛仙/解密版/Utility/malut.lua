local print = print
local pairs = pairs
local tostring = tostring
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable
local stdout = io.stdout
local stringrep = string.rep
local setfenv = setfenv
local assert = assert
local rawget = rawget
local pcall = pcall
local load = load
local loadfile = loadfile
local tableconcat = table.concat
local tableremove = table.remove
local luad = luad
local ioopen = io.open
local error = error
local select = select
local _VERSION = _VERSION
local is_5_1 = _VERSION == "Lua 5.1"
local _ENV
local malut = {}
local tableToString_tablelist, tableToString_strBuilder
local function tableToString_write(...)
  local n = select("#", ...)
  for i = 1, n do
    tableToString_strBuilder[#tableToString_strBuilder + 1] = select(i, ...)
  end
end
local tableToString_
local function tableToString_keyValue(k, v, level, maxLevel, name)
  tableToString_write(stringrep(" ", level * 2))
  local typeK = type(k)
  if typeK == "number" then
    tableToString_write("#", k)
  else
    tableToString_write(tostring(k))
  end
  tableToString_write(" = ")
  local typeV = type(v)
  if typeV == "table" then
    if tableToString_tablelist[v] then
      tableToString_write(tostring(v), " (", tableToString_tablelist[v], ")")
    elseif maxLevel and maxLevel <= level + 1 then
      tableToString_write(tostring(v), " (...)")
    else
      tableToString_write(tostring(v), "\n")
      return tableToString_(v, level + 1, maxLevel, name .. "." .. tostring(k))
    end
  elseif typeV == "string" then
    tableToString_write("\"", v, "\"")
  else
    tableToString_write(tostring(v))
  end
  tableToString_write("\n")
end
function tableToString_(t, level, maxLevel, name)
  tableToString_tablelist[t] = name
  local size = #t
  for i = 1, size do
    local v = t[i]
    if v ~= nil then
      tableToString_keyValue(i, v, level, maxLevel, name)
    end
  end
  for k, v in pairs(t) do
    if type(k) == "number" and k >= 1 and k <= size then
    else
      tableToString_keyValue(k, v, level, maxLevel, name)
    end
  end
end
function malut.tableToString(t, maxLevel, name)
  tableToString_tablelist = {}
  tableToString_strBuilder = {}
  if name then
    tableToString_write(name, " =\n")
  end
  if type(t) == "table" then
    tableToString_write("[", tostring(t), "]\n")
    tableToString_(t, 0, maxLevel, type(name) == "string" and name or "t")
  else
    if type(t) == "string" then
      tableToString_write("\"", t, "\"")
    else
      tableToString_write(tostring(t))
    end
    tableToString_write("\n")
  end
  local ret = table.concat(tableToString_strBuilder)
  tableToString_tablelist = nil
  tableToString_strBuilder = nil
  return ret
end
function malut.printTable(t, maxLevel, name)
  local str = malut.tableToString(t, maxLevel, name)
  print(str:sub(1, -2))
end
local emptyTable = {}
local function copy(dst, src)
  local __copy = rawget(src, "__copy")
  if type(__copy) == "function" then
    return __copy(dst, src)
  end
  if type(__copy) ~= "table" then
    __copy = emptyTable
  end
  for k, v in pairs(src) do
    local copyFlag = __copy[k]
    if copyFlag ~= false then
      if type(v) == "table" and v.__copytype ~= "ref" then
        if copyFlag == true or v.__copytype == "all" then
          local newT = {}
          local metaT = getmetatable(v)
          if metaT ~= nil then
            if metaT == src then
              setmetatable(newT, newT)
            else
              setmetatable(newT, metaT)
            end
          end
          dst[k] = copy(newT, v)
        else
          dst[k] = v
        end
      else
        dst[k] = v
      end
    end
  end
  return dst
end
malut.copy = copy
local function clone(t)
  local newT = {}
  local metaT = getmetatable(t)
  if metaT ~= nil then
    if metaT == src then
      setmetatable(newT, newT)
    else
      setmetatable(newT, metaT)
    end
  end
  return copy(newT, t)
end
malut.clone = clone
local emptyTable = {}
local function copynew(dst, src)
  local retFlag = true
  local __copy = rawget(src, "__copy")
  if type(__copy) ~= "table" then
    __copy = emptyTable
  end
  for k, v in pairs(src) do
    local copyFlag = __copy[k]
    if copyFlag ~= false then
      if type(v) == "table" and v.__copytype ~= "ref" then
        local dstV = dst[k]
        if dstV == nil then
          if copyFlag == true or v.__copytype == "all" then
            local newT = {}
            local metaT = getmetatable(v)
            if metaT ~= nil then
              if metaT == src then
                setmetatable(newT, newT)
              else
                setmetatable(newT, metaT)
              end
            end
            dst[k] = copy(newT, v)
          else
            dst[k] = v
          end
        elseif type(dstV) == "table" and (copyFlag == true or v.__copytype == "all") then
          local ret = copynew(dstV, v)
          retFlag = retFlag and ret
        end
      elseif dst[k] == nil then
        dst[k] = v
      else
        retFlag = false
      end
    end
  end
  return retFlag
end
malut.copynew = copynew
local toCode_codes, toCode_tables, toCode_
local function toCode_printKeyValue(k, v, level)
  local indentInner = (" "):rep((level + 1) * 2)
  toCode_codes[#toCode_codes + 1] = indentInner
  local typeK = type(k)
  if typeK == "number" or typeK == "boolean" then
    toCode_codes[#toCode_codes + 1] = "["
    toCode_codes[#toCode_codes + 1] = tostring(k)
    toCode_codes[#toCode_codes + 1] = "] = "
  elseif typeK == "string" then
    if k:match("^[%a_][%w_]*$") then
      toCode_codes[#toCode_codes + 1] = k .. " = "
    else
      toCode_codes[#toCode_codes + 1] = ("[%q] = "):format(k)
    end
  else
    error("unsupported key type: " .. typeK .. ", for " .. tostring(k), 4 + 2 * level)
  end
  local typeV = type(v)
  if typeV == "number" or typeV == "boolean" then
    toCode_codes[#toCode_codes + 1] = tostring(v)
    toCode_codes[#toCode_codes + 1] = ";\n"
  elseif typeV == "string" then
    toCode_codes[#toCode_codes + 1] = ("%q;\n"):format(v)
  elseif typeV == "table" then
    if toCode_tables[v] then
      error("table has ring: " .. tostring(v), 3)
    end
    toCode_codes[#toCode_codes + 1] = "\n"
    return toCode_(v, level + 1, ";\n")
  else
    error("unsupported value type: " .. typeV .. ", for " .. tostring(v), 4 + 2 * level)
  end
end
function toCode_(t, level, subfix)
  toCode_tables[t] = true
  local indent = (" "):rep(level * 2)
  local indentInner = (" "):rep((level + 1) * 2)
  toCode_codes[#toCode_codes + 1] = indent
  toCode_codes[#toCode_codes + 1] = "{\n"
  local size = #t
  for i = 1, size do
    local v = t[i]
    if v ~= nil then
      toCode_printKeyValue(i, v, level)
    end
  end
  for k, v in pairs(t) do
    if type(k) == "number" and k >= 1 and k <= size then
    else
      toCode_printKeyValue(k, v, level)
    end
  end
  toCode_codes[#toCode_codes + 1] = indent
  toCode_codes[#toCode_codes + 1] = "}"
  toCode_codes[#toCode_codes + 1] = subfix
  return true
end
local function toCode(t)
  local typeT = type(t)
  if typeT == "table" then
    toCode_codes = {}
    toCode_tables = {}
    toCode_(t, 0, "")
    local result = tableconcat(toCode_codes)
    toCode_codes = nil
    toCode_tables = nil
    return result
  elseif typeT == "number" or typeT == "boolean" then
    return tostring(t)
  elseif typeT == "string" then
    return ("%q"):format(t)
  else
    error("unsupported value type: " .. typeT, 2)
  end
end
malut.toCode = toCode
function malut.toCodeToFile(t, fileName)
  local fout, err = ioopen(fileName, "w")
  if fout then
    fout:write("return\n", toCode(t))
    fout:close()
    return true
  else
    return nil, err
  end
end
if is_5_1 then
  function malut.fromCode(str)
    local func, err = loadstring(str)
    if func then
      local s, ret = pcall(setfenv(func, {}))
      if s then
        return ret
      else
        return nil, ret
      end
    else
      return nil, err
    end
  end
else
  function malut.fromCode(str)
    local func, err = load(str, nil, nil, {})
    if func then
      local s, ret = pcall(func)
      if s then
        return ret
      else
        return nil, ret
      end
    else
      return nil, err
    end
  end
end
if is_5_1 then
  function malut.fromCodeInFile(fileName)
    local func, err = loadfile(fileName)
    if func then
      local s, ret = pcall(setfenv(func, {}))
      if s then
        return ret
      else
        return nil, ret
      end
    else
      return nil, err
    end
  end
else
  function malut.fromCodeInFile(fileName)
    local func, err = loadfile(fileName, nil, {})
    if func then
      local s, ret = pcall(func)
      if s then
        return ret
      else
        return nil, ret
      end
    else
      return nil, err
    end
  end
end
return malut
