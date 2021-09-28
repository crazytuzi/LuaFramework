if jit then
  jit.off()
end



object			= System.Object
Type			= System.Type
Object          = UnityEngine.Object
GameObject 		= UnityEngine.GameObject
Transform 		= UnityEngine.Transform

Component		= UnityEngine.Component

SystemInfo		= UnityEngine.SystemInfo
Screen			= UnityEngine.Screen
Camera			= UnityEngine.Camera










Input			= UnityEngine.Input


AudioSource		= UnityEngine.AudioSource








WrapMode		= UnityEngine.WrapMode






function print(...)
	local arg = {...}	
	local t = {}	
  for i = 1, table.maxn(arg) do
		table.insert(t, tostring(arg[i])..'\t')
	end
	
	local str = table.concat(t)	
  if Debugger.IsDebugBuild then
    Debugger.Log(str.."\n"..debug.traceback())
  else
    Debugger.Log(str)
  end
end

function printf(format, ...)
	Debugger.Log(string.format(format, ...))
end






require "class"





















function traceback(msg)
	msg = debug.traceback(msg, 2)
	return msg
end

function LuaGC()
  local c = collectgarbage("count")
  Debugger.Log("Begin gc count = {0} kb", c)
  collectgarbage("collect")
  c = collectgarbage("count")
  Debugger.Log("End gc count = {0} kb", c)
end





function RemoveTableItem(list, item, removeAll)
    local rmCount = 0

    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)

            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end



function IsNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end


function isnan(number)
	return not (number == number)
end




















function string.split(s, sep)
  local sep, fields = sep or ",", {}
    local pos, startIdx, endIdx = 1
    local fields = {}
    startIdx, endIdx = string.find(s, sep, pos, true)
    while startIdx do
        table.insert(fields, string.sub(s, pos, startIdx - 1))
        pos = endIdx + 1
        startIdx, endIdx = string.find(s, sep, pos, true)
    end
    table.insert(fields, string.sub(s, pos))
    return fields
end

function string.empty( s )
    return s == nil or s == ""
end

function string.utf8len(s)
  if s == nil or s == "" then return 0 end
  local n = 0
  for i = 1, #s do
    local c = string.byte(s, i)
    if c < 0x80 or c >= 0xC0 then
      n = n + 1
    end
  end
  return n
end

function string.utf8sub(s, i, j)
  if s == nil or s == "" then return s end
  if not j then j = #s end

  local bi, ei = nil, nil
  local n = 0
  for ii = 1, #s do
    local c = string.byte(s, ii)
    if c < 0x80 or c >= 0xC0 then
      n = n + 1
    end
    if n == i and not bi then bi = ii end
    if n == j + 1 and not ei then ei = ii - 1 end
  end
  if not ei then ei = #s end
  return string.sub(s, bi, ei)
end


function string.encodeSpam(str)
  local spam = "^"

  local list = {}
  local p = 1
  for i = 1, #str do
    local c = string.byte(str, i)
    if c < 0x80 then
      
      table.insert(list, string.sub(str, p, i))
      p = i + 1
    elseif c >= 0xC0 then
      
      if p <= i - 1 then
        
        table.insert(list, string.sub(str, p, i - 1))
        p = i
      end
    end
  end
  if p <= #str then
    table.insert(list, string.sub(str, p, #str))
  end
  return table.concat(list, spam)
end

function string.decodeSpam(str)
  return string.gsub(str, "%^", "")
end

function table.indexOf(t, value, fromIdx, toIdx)
    fromIdx = fromIdx or 1
    toIdx = toIdx or #t
    for i = fromIdx, toIdx do
      if t[i] == value then
        return i
      end
    end
    return nil
end


function table.indexOfKey(t, key, value, fromIdx, toIdx)
    fromIdx = fromIdx or 1
    toIdx = toIdx or #t
    for i = fromIdx, toIdx do
      if t[i] and t[i][key] == value then
        return i, t[i]
      end
    end
    return nil, nil
end

function table.map(t, func, isModify)
  local newt = isModify and t or {}
  for k,v in pairs(t) do
    newt[k] = func(v)
  end
  return newt
end

function table.filterList(list, func)
  local newt = {}
  for i,v in ipairs(list) do
    if func(i, v) then
      table.insert(newt, v)
    end
  end
  return newt
end

function table.reverse(list)
  local len = #list
  for i = 1, math.floor(len/2) do
    local t = list[i]
    list[i] = list[len - i + 1]
    list[len - i + 1] = t
  end
end

table.removeItem = RemoveTableItem

function table.mergeList(list1, list2, isModify)
  local list = nil
  if isModify then
    list = list1
  else
    list = {}
    for _,v in ipairs(list1) do
      table.insert(list, v)
    end
  end

  for _,v in ipairs(list2) do
    table.insert(list, v)
  end

  return list
end

function GetDir(path)
	return string.match(fullpath, ".*/")
end

function GetFileName(path)
	return string.match(fullpath, ".*/(.*)")
end
























function table.contains(table, element)
  if table == nil then
        return false
  end

  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function table.getCount(self)
	local count = 0

	for k, v in pairs(self) do
		count = count + 1
	end

	return count
end

function DumpTable(t)
	for k,v in pairs(t) do
		if v ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
		else
			Debugger.Log("Key: {0}, Value nil", tostring(k))
		end
	end
end

 function PrintTable(tab)
    local str = {}

    local function internal(tab, str, indent)
        for k,v in pairs(tab) do
            if type(v) == "table" then
                table.insert(str, indent..tostring(k)..":\n")
                internal(v, str, indent..' ')
            else
                table.insert(str, indent..tostring(k)..": "..tostring(v).."\n")
            end
        end
    end

    internal(tab, str, '')
    return table.concat(str, '')
end

function PrintLua(name, lib)
	local m
	lib = lib or _G

	for w in string.gmatch(name, "%w+") do
       lib = lib[w]
     end

	 m = lib

	if (m == nil) then
		Debugger.Log("Lua Module {0} not exists", name)
		return
	end

	Debugger.Log("-----------------Dump Table {0}-----------------",name)
	if (type(m) == "table") then
		for k,v in pairs(m) do
			Debugger.Log("Key: {0}, Value: {1}", k, tostring(v))
		end
	end

	local meta = getmetatable(m)
	Debugger.Log("-----------------Dump meta {0}-----------------",name)

	while meta ~= nil and meta ~= m do
		for k,v in pairs(meta) do
			if k ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
			end

		end

		meta = getmetatable(meta)
	end

	Debugger.Log("-----------------Dump meta Over-----------------")
	Debugger.Log("-----------------Dump Table Over-----------------")
end

function stringToTable(str)
   local ret = loadstring("return "..str)()
   return ret
end
