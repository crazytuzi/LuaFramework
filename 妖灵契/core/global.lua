local setmetatable = setmetatable
local table = table
local pairs = pairs
local ipairs = ipairs
local select = select
local tinsert = table.insert
local assert = assert
local tostring = tostring
local xpcall = xpcall

local weakid = 0
g_WeakObjs = setmetatable({}, {__mode="kv"})

--用lua的闭包实现回调
function callback(luaobj, funcname, ...)
	assert(luaobj[funcname], "callback error!not defind funcname:"..funcname)
	local args = {...}
	local len1 = select("#", ...)
	local id = weakref(luaobj)
	local function f(...)
		local real = getrefobj(id)
		if not real then
			return false
		end
		local len2 = select("#", ...)
		for i=1, len2 do
			args[len1 + i] = select(i, ...)
		end
		return real[funcname](real, unpack(args, 1, len1+len2))
	end

	return f
end

function objcall(obj, f)
	local weakid = weakref(obj)
	return function(...)
		local real = getrefobj(weakid)
		if real then
			return f(real, ...)
		end
	end
end

--打印函数调用堆栈
function printtrace()
	print("调用堆栈:\n",debug.traceback())
end

--print color
function printc(...)
	local args = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		tinsert(args, tostring(v))
	end
	local s = table.concat(args, " ")
	print(string.format("<color=#ffeb04>%s</color>", s))
end

function getprintstr(...)
	local args = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		tinsert(args, tostring(v))
	end
	local s = table.concat(args, " ")
	return s
end

function printerror(...)
	local args = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		tinsert(args, tostring(v))
	end
	local msg = table.concat(args, " ")
	C_api.Utils.LogLuaError(msg, debug.traceback())
end

function weakref(obj)
	local id = weakid
	g_WeakObjs[id] = obj
	weakid = weakid + 1
	return id
end


function weakref_old(obj)
	local wt = setmetatable({}, {__mode="kv"})
	wt[1] = obj
	local function f()
		local o = wt[1]
		if Utils.IsNil(o) then
			return nil
		else
			return o
		end
	end
	return f
end

function getrefobj(id)
	if id then
		local o = g_WeakObjs[id]
		if Utils.IsNil(o) then
			g_WeakObjs[id] = nil
		else
			return o
		end
	end
end

--重新require一个lua文件，替代系统文件。
function reimport(name)
	local package = package
	package.loaded[name] = nil
	package.preload[name] = nil
	return require(name)
end

function xxpcall(f, ...)
	local args = {...}
	local len = select("#", ...)
	return xpcall(function() return f(unpack(args, 1, len)) end, printerror)
end

function safefunc(f, default)
	return function(...)
		local b, ret = pcall(f, ...)
		if b then
			return ret
		else
			return default
		end
	end
end

function getgloalvar(s)
	return _G[s]
end

function decodejson(s)
	if (not s) or (s == "")then
		return {}
	else
		local b, ret = pcall(cjson.decode, s)
		if b then
			return ret
		else
			return {}
		end
	end
end

function memoize(f, default)
	local mem = {}
	setmetatable(mem, {__mode = "kv"})
	return function(x)
		if x then
			local r = mem[x]
			if r == nil then
				r = f(x)
				mem[x] = r
			end
			return r
		else
			return default
		end
	end
end

-- loadstring = memoize(loadstring, nil)

editor = {}
if g_IsEditor then
	editor.error = error
else
	editor.error = print
end