-- Todo 后面上线时将debug.traceback()去掉
local tinsert = table.insert
local pairs = pairs
-- 错误日志--
function Error(str)
	Debugger.LogError(tostring(str) .. "\n" .. debug.traceback());
end

-- 警告日志--
function Warning(str)
	Debugger.LogWarning(tostring(str) .. "\n" .. debug.traceback());
end

-- 输出日志--
function log(str)
	Debugger.Log(tostring(str) .. "\n" .. debug.traceback());
end

-- 带lua堆栈的输出日志--弃用
function logTrace(str)
	Debugger.Log(tostring(str) .. "\n" .. debug.traceback());
end

-- 打印table--
function PrintTable(root, name, logFun)
	name = name or ""
	if(root == nil) then log("table is nil") return end
	local cache = {[root] = "."}
	local function _dump(t, space, name)
		local temp = {}
		for k, v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				tinsert(temp, "+" .. key .. " {" .. cache[v] .. "}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				tinsert(temp, key .. _dump(v, space ..(next(t, k) and "|" or " ") .. string.rep(" ", # key), new_key))
			else
				tinsert(temp, "--" .. key .. "= [" .. tostring(v) .. "]")
			end
		end
		return table.concat(temp, "\n" .. space)
	end
	if not logFun then logFun = log end
	logFun(_dump(root, "", name))
end

function print(...)
	local arg = {...}
	local t = {}
	
	for i, k in ipairs(arg) do
		tinsert(t, tostring(k))
	end
	
	local str = table.concat(t)
	Debugger.Log(tostring(str) .. "\n" .. debug.traceback())
end

if(not GameConfig.instance.useLog) then
	Error = function(str) end
	Warning = function(str) end
	log = function(str) end
	PrintTable = function(str) end
	logTrace = function(str) end
	print = function(...) end	
end



function printf(format, ...)
	Debugger.Log(string.format(format, ...) .. "\n" .. debug.traceback())
end

function print_r(t)
	if(t == nil) then
		return print("t is nil")
	end
	local print_r_cache = {}
	local function sub_print_r(t, indent)
		if(print_r_cache[tostring(t)]) then
			print(indent .. "*" .. tostring(t))
		else
			print_r_cache[tostring(t)] = true
			if(type(t) == "table") then
				for pos, val in pairs(t) do
					if(type(val) == "table") then
						print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
						sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
						print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
					elseif(type(val) == "string") then
						print(indent .. "[" .. pos .. '] => "' .. val .. "\"")
					else
						print(indent .. "[" .. pos .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end
	if(type(t) == "table") then
		print(tostring(t) .. " {")
		sub_print_r(t, "  ")
		print("}")
	else
		sub_print_r(t, "  ")
	end
	print()
end



function PrintLua(name, lib)
	local m
	lib = lib or _G
	
	for w in string.gmatch(name, "%w+") do
		lib = lib[w]
	end
	
	m = lib
	
	if(m == nil) then
		Debugger.Log("Lua Module {0} not exists", name)
		return
	end
	
	Debugger.Log("-----------------Dump Table {0}-----------------", name)
	if(type(m) == "table") then
		for k, v in pairs(m) do
			Debugger.Log("Key: {0}, Value: {1}", k, tostring(v))
		end
	end
	
	local meta = getmetatable(m)
	Debugger.Log("-----------------Dump meta {0}-----------------", name)
	
	while meta ~= nil and meta ~= m do
		for k, v in pairs(meta) do
			if k ~= nil then
				Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
			end
			
		end
		
		meta = getmetatable(meta)
	end
	
	Debugger.Log("-----------------Dump meta Over-----------------")
	Debugger.Log("-----------------Dump Table Over-----------------")
end

function string.trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")
	return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if(delimiter == '') then return false end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		tinsert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	tinsert(arr, string.sub(input, pos))
	return arr
end

function string.splitToNum(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if(delimiter == '') then return false end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		tinsert(arr, tonumber(string.sub(input, pos, st - 1)))
		pos = sp + 1
	end
	tinsert(arr, tonumber(string.sub(input, pos)))
	return arr
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

function table.getCount(table)
	local count = 0
	
	for k, v in pairs(table) do
		count = count + 1
	end
	
	return count
end
-- addTable添加到sourceTable
function table.AddRange(sourceTable, addTable)
	for k, v in pairs(addTable) do tinsert(sourceTable, v) end
end
-- addTable合并到sourceTable
function table.Merge(sourceTable, addTable)
	for k, v in pairs(addTable) do
		sourceTable[k] = v
	end
end

function table.copy(st)
	local tab = {}
	for k, v in pairs(st or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = table.copy(v)
		end
	end
	return tab;
end

function table.copyTo(source, des)
	local tab = des;
	for k, v in pairs(source or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = table.copy(v)
		end
	end
end

function GetDir(path)
	return string.match(fullpath, ".*/")
end

function GetFileName(path)
	return string.match(fullpath, ".*/(.*)")
end

-- unity 对象判断为空, 如果你有些对象是在c#删掉了，lua 不知道
-- 判断这种对象为空时可以用下面这个函数。
function IsNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end

-- isnan
function isnan(number)
	return not(number == number)
end


--[[function ShowUI(name, OnLoad)
	UIBase.LoadUI(name, OnLoad)
end--]]
function RemoveTableItem(list, item, removeAll)
	local rmCount = 0
	
	for i = 1, # list do
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

Convert = {}

function Convert.PointToServer(pt, angle)
	local to = {
		x = math.round(pt.x * 100);
		y = math.round(pt.y * 100);
		z = math.round(pt.z * 100);
	}
	if(angle) then
		to.a = math.round(angle * 100);
	end
	return to;
end

function Convert.PointFromServer(x, y, z)
	return Vector3.New(x / 100, y / 100, z / 100);
end
function Convert.PointFromConfig(x, y, z)
	return Vector3.New(x / 100, y / 100, z / 100);
end

function Convert.AngleFromServer(angle)
	return math.round(angle / 100);
end

uiEnablePos = Vector3.zero
uiDisablePos = Vector3.one * 10000

function SetUIEnable(trs, enable)
	Util.SetLocalPos(trs, enable and uiEnablePos or uiDisablePos)
end

 
function GetToday()
	-- local now = GetTime() - 18000	
	local now = GetOffsetTime() - 18000
	today = tonumber(os.date("%d", now))
	return today
end

-------------------------tolua 升级用的------------------------------
function Vector3.Distance2(va, vb)
	return math.sqrt((va.x - vb.x) ^ 2 +(va.z - vb.z) ^ 2)
end



function GetClassFuncName(ind)
	local info = debug.getinfo(ind, "Snl")
	if info then
		local cn = nil
		local argIndex = 1
		local argName, argValue = debug.getlocal(ind, argIndex)
		while argName ~= nil do
			--print(argIndex, argName, tostring(argValue))
			if argName == "self" then
				cn = argValue.__cname
				break
			end
			argIndex = argIndex + 1
			argName, argValue = debug.getlocal(ind, argIndex)
		end
		return string.format("%s.%s_%d",(cn or info.source),(info.name or ""), info.currentline)
	end
end