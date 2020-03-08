function printf(fmt, ...)
  print(string.format(tostring(fmt), ...))
end
function checknumber(value, base)
  return tonumber(value, base) or 0
end
function checkint(value)
  return math.round(checknumber(value))
end
function checkbool(value)
  return value ~= nil and value ~= false
end
function checktable(value)
  if type(value) ~= "table" then
    value = {}
  end
  return value
end
function isset(hashtable, key)
  local t = type(hashtable)
  return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end
function clone(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for key, value in pairs(object) do
      new_table[_copy(key)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(object)
end
function class(classname, super)
  local superType = type(super)
  local cls
  if superType ~= "function" and superType ~= "table" then
    superType = nil
    super = nil
  end
  if superType == "function" or super and super.__ctype == 1 then
    cls = {}
    if superType == "table" then
      for k, v in pairs(super) do
        cls[k] = v
      end
      cls.__create = super.__create
      cls.super = super
    else
      cls.__create = super
      function cls.ctor()
      end
    end
    cls.__cname = classname
    cls.__ctype = 1
    function cls.new(...)
      local instance = cls.__create(...)
      for k, v in pairs(cls) do
        instance[k] = v
      end
      instance.class = cls
      instance:ctor(...)
      return instance
    end
  else
    if super then
      cls = {}
      setmetatable(cls, {__index = super})
      cls.super = super
    else
      cls = {
        ctor = function()
        end
      }
    end
    cls.__cname = classname
    cls.__ctype = 2
    cls.__index = cls
    function cls.new(...)
      local instance = setmetatable({}, cls)
      instance.class = cls
      instance:ctor(...)
      return instance
    end
  end
  return cls
end
function quick_class(classname, super)
  return class(classname, super)
end
function iskindof(obj, classname)
  local t = type(obj)
  local mt
  if t == "table" then
    mt = getmetatable(obj)
  elseif t == "userdata" then
    mt = tolua.getpeer(obj)
  end
  while mt do
    if mt.__cname == classname then
      return true
    end
    mt = mt.super
  end
  return false
end
function import(moduleName, currentModuleName)
  local currentModuleNameParts
  local moduleFullName = moduleName
  local offset = 1
  while true do
    if string.byte(moduleName, offset) ~= 46 then
      moduleFullName = string.sub(moduleName, offset)
      if currentModuleNameParts and #currentModuleNameParts > 0 then
        moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
      end
      break
    end
    offset = offset + 1
    if not currentModuleNameParts then
      if not currentModuleName then
        local n, v = debug.getlocal(3, 1)
        currentModuleName = v
      end
      currentModuleNameParts = string.split(currentModuleName, ".")
    end
    table.remove(currentModuleNameParts, #currentModuleNameParts)
  end
  return require(moduleFullName)
end
function handler(obj, method)
  return function(...)
    return method(obj, ...)
  end
end
function math.newrandomseed()
  local ok, socket = pcall(function()
    return require("socket")
  end)
  if ok then
    math.randomseed(socket.gettime() * 1000)
  else
    math.randomseed(os.time())
  end
  math.random()
  math.random()
  math.random()
  math.random()
end
function math.round(value)
  return math.floor(value + 0.5)
end
function math.angle2radian(angle)
  return angle * math.pi / 180
end
function math.radian2angle(radian)
  return radian / math.pi * 180
end
function io.exists(path)
  local file = io.open(path, "r")
  if file then
    io.close(file)
    return true
  end
  return false
end
function io.readfile(path)
  local file = io.open(path, "r")
  if file then
    local content = file:read("*a")
    io.close(file)
    return content
  end
  return nil
end
function io.writefile(path, content, mode)
  mode = mode or "w+b"
  local file = io.open(path, mode)
  if file then
    if file:write(content) == nil then
      return false
    end
    io.close(file)
    return true
  else
    return false
  end
end
function io.pathinfo(path)
  local pos = string.len(path)
  local extpos = pos + 1
  while pos > 0 do
    local b = string.byte(path, pos)
    if b == 46 then
      extpos = pos
    elseif b == 47 then
      break
    end
    pos = pos - 1
  end
  local dirname = string.sub(path, 1, pos)
  local filename = string.sub(path, pos + 1)
  extpos = extpos - pos
  local basename = string.sub(filename, 1, extpos - 1)
  local extname = string.sub(filename, extpos)
  return {
    dirname = dirname,
    filename = filename,
    basename = basename,
    extname = extname
  }
end
function io.filesize(path)
  local size = false
  local file = io.open(path, "r")
  if file then
    local current = file:seek()
    size = file:seek("end")
    file:seek("set", current)
    io.close(file)
  end
  return size
end
function table.nums(t)
  local count = 0
  for k, v in pairs(t) do
    count = count + 1
  end
  return count
end
function table.keys(hashtable)
  local keys = {}
  for k, v in pairs(hashtable) do
    keys[#keys + 1] = k
  end
  return keys
end
function table.values(hashtable)
  local values = {}
  for k, v in pairs(hashtable) do
    values[#values + 1] = v
  end
  return values
end
function table.merge(dest, src)
  for k, v in pairs(src) do
    dest[k] = v
  end
end
function table.insertto(dest, src, begin)
  begin = checkint(begin)
  if begin <= 0 then
    begin = #dest + 1
  end
  local len = #src
  for i = 0, len - 1 do
    dest[i + begin] = src[i + 1]
  end
end
function table.indexof(array, value, begin)
  for i = begin or 1, #array do
    if array[i] == value then
      return i
    end
  end
  return false
end
function table.keyof(hashtable, value)
  for k, v in pairs(hashtable) do
    if v == value then
      return k
    end
  end
  return nil
end
function table.removebyvalue(array, value, removeall)
  local c, i, max = 0, 1, #array
  while i <= max do
    if array[i] == value then
      table.remove(array, i)
      c = c + 1
      i = i - 1
      max = max - 1
      if not removeall then
        break
      end
    end
    i = i + 1
  end
  return c
end
function table.map(t, fn)
  for k, v in pairs(t) do
    t[k] = fn(v, k)
  end
end
function table.walk(t, fn)
  for k, v in pairs(t) do
    fn(v, k)
  end
end
function table.filter(t, fn)
  for k, v in pairs(t) do
    if not fn(v, k) then
      t[k] = nil
    end
  end
end
function table.unique(t)
  local check = {}
  local n = {}
  for k, v in pairs(t) do
    if not check[v] then
      n[k] = v
      check[v] = true
    end
  end
  return n
end
function table.bubblesort(tbl, compFunc)
  if compFunc then
    local len = #tbl
    for i = 1, len - 1 do
      for j = 1, len - i do
        if not compFunc(tbl[j], tbl[j + 1]) then
          tbl[j], tbl[j + 1] = tbl[j + 1], tbl[j]
        end
      end
    end
  else
    local len = #tbl
    for i = 1, len - 1 do
      for j = 1, len - i do
        if tbl[j] > tbl[j + 1] then
          tbl[j], tbl[j + 1] = tbl[j + 1], tbl[j]
        end
      end
    end
  end
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"
function string.htmlspecialchars(input)
  for k, v in pairs(string._htmlspecialchars_set) do
    input = string.gsub(input, k, v)
  end
  return input
end
function string.restorehtmlspecialchars(input)
  for k, v in pairs(string._htmlspecialchars_set) do
    input = string.gsub(input, v, k)
  end
  return input
end
function string.nl2br(input)
  return string.gsub(input, "\\n", "<br/>")
end
function string.text2html(input)
  input = string.gsub(input, "\t", "    ")
  input = string.htmlspecialchars(input)
  input = string.gsub(input, " ", "&nbsp;")
  input = string.nl2br(input)
  return input
end
function string.split(input, delimiter)
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(input, delimiter, pos, true)
  end, nil, nil do
    table.insert(arr, string.sub(input, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(input, pos))
  return arr
end
function string.ltrim(input)
  return string.gsub(input, "^[ \t\n\r]+", "")
end
function string.rtrim(input)
  return string.gsub(input, "[ \t\n\r]+$", "")
end
function string.trim(input)
  input = string.gsub(input, "^[ \t\n\r]+", "")
  return string.gsub(input, "[ \t\n\r]+$", "")
end
function string.ucfirst(input)
  return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end
local urlencodechar = function(char)
  return "%" .. string.format("%02X", string.byte(char))
end
function string.urlencode(input)
  input = string.gsub(tostring(input), "\n", "\r\n")
  input = string.gsub(input, "([^a-zA-Z_0-9%.%-])", urlencodechar)
  return string.gsub(input, " ", "+")
end
function string.urldecode(input)
  input = string.gsub(input, "+", " ")
  input = string.gsub(input, "%%(%x%x)", function(h)
    return string.char(checknumber(h, 16))
  end)
  input = string.gsub(input, "\r\n", "\n")
  return input
end
function string.utf8len(input)
  local len = string.len(input)
  local left = len
  local cnt = 0
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  while left ~= 0 do
    local tmp = string.byte(input, -left)
    local i = #arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i - 1
    end
    cnt = cnt + 1
  end
  return cnt
end
function string.formatnumberthousands(num)
  local formatted = tostring(checknumber(num))
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then
      break
    end
  end
  return formatted
end
