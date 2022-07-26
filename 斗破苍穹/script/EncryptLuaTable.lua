
--[[
加密的Lua表
对存入表中的直接子属性boolean、number、string进行内存实时加解密，
若需要使用子table，请直接将新的加密表作为直接子属性存入表中，
可开启boolean、number、string的异常检测，但未处理异常。
--]]

local ENABLE_DETECT = false --是否开启检测

local function onDetected() --检测到异常时被调用
	--print("检测到异常!!!") --cclog
end

EncryptLuaTable = EncryptLuaTable or {}

--IN	string
--OUT	string
function EncryptLuaTable.encryptString(str)
	local result = str:gsub(".",
		function(c)
			local a = 0xFF - c:byte()
			local r = math.random(0,a)
			return string.char(r) .. string.char(a-r)
		end
	)
	return result
end

--IN	string
--OUT	string
function EncryptLuaTable.decryptString(str)
	local result = str:gsub("..",
		function(c)
			return string.char(0xFF - (c:byte(1) + c:byte(2)))
		end
	)
	return result
end

--IN	number
--OUT	string
function EncryptLuaTable.encryptNumber(num)
	return EncryptLuaTable.encryptString(tostring(num))
end

--IN	string
--OUT	number
function EncryptLuaTable.decryptNumber(str)
	return tonumber(EncryptLuaTable.decryptString(str))
end

--IN	boolean
--OUT	number
function EncryptLuaTable.encryptBoolean(bool) --todo转为加密字符串
	local r = math.random(100000000,999999990)
	local m = r % 7
	if bool then
		if m == 0 then
			r = r + 1
		end
	else
		if m ~= 0 then
			r = r - m
		end
	end
	return r
end

--IN	number
--OUT	boolean
function EncryptLuaTable.decryptBoolean(num) --todo转为加密字符串
	return num % 7 ~= 0
end

--metatable
local __t = {
	__index = function(t,k)
		local c = rawget(t.__k,k)
		if c == nil then
			return nil
		end
		
		local v = rawget(t.__v,k)
		local o = rawget(t.__o,k)
		if c == "nil" then
			--v = v
			--if ENABLE_DETECT and v ~= o then
			--	onDetected()
			--end
		elseif c == "boolean" then
			v = EncryptLuaTable.decryptBoolean(v)
			if ENABLE_DETECT and v ~= o then
				onDetected()
			end
		elseif c == "number" then
			v = EncryptLuaTable.decryptNumber(v)
			if ENABLE_DETECT and tostring(v) ~= tostring(o) then
				onDetected()
			end
		elseif c == "string" then
			v = EncryptLuaTable.decryptString(v)
			if ENABLE_DETECT and v ~= o then
				onDetected()
			end
		elseif c == "table" then --todo可递归处理，暂不实现
			--v = v
			--if ENABLE_DETECT and v ~= o then
			--	onDetected()
			--end
		else --function,userdata,thread
			assert(false,"Unsupport type: " .. c)
		end
		return v
	end,
	__newindex = function(t,k,v)
		local c = type(v)
		if c == "nil" then
			--rawset(t.__o,k,v)
			rawset(t.__v,k,v)
		elseif c == "boolean" then
			rawset(t.__o,k,v)
			rawset(t.__v,k,EncryptLuaTable.encryptBoolean(v))
		elseif c == "number" then
			rawset(t.__o,k,v)
			rawset(t.__v,k,EncryptLuaTable.encryptNumber(v))
		elseif c == "string" then
			rawset(t.__o,k,v)
			rawset(t.__v,k,EncryptLuaTable.encryptString(v))
		elseif c == "table" then --todo可递归处理，暂不实现
			--rawset(t.__o,k,v)
			rawset(t.__v,k,v)
		else --function,userdata,thread
			assert(false,"Unsupport type: " .. c)
		end
		rawset(t.__k,k,c)
	end,
}

function EncryptLuaTable.new()
	return setmetatable({__k={},__v={},__o={}},__t)
end

local defaultEncryptLuaTable = nil

function EncryptLuaTable.getInstance()
	if defaultEncryptLuaTable == nil then
		defaultEncryptLuaTable = EncryptLuaTable.new()
	end
	return defaultEncryptLuaTable
end

--测试代码

--local tt = EncryptLuaTable.new()

--tt.a = nil
--tt.b = true
--tt.c = false
--tt.d = 0
--tt.e = 999999999999999
--tt.f = "a"
--tt.g = "l\"ksjdl;fkjwsoefjwopeijrwelnrwenrwoperwernwerwerwerweRWerwe-r09w-r092039409287340928341231lkj3321~!@#$%^&*()"
--tt.h = "我"
--tt.i = "中用到的 名字（也称作 标识符）可以是任何非数字开头的字母、数字、下划线组成的字符串。 这符合几乎所有编程语言中关于名字的定义。 （字母的定义依赖于当前环境：系统环境中定义的字母表中的字母都可以被用于标识符。） 标识符用来命名变量，或作为表的域"
--tt.j = {jj=100,kk="kk in j"}
--tt.k = {}
----tt.l = function()end

--print(tt.a)
--print(tt.b)
--print(tt.c)
--print(tt.d)
--print(tt.e)
--print(tt.f)
--print(tt.g)
--print(tt.h)
--print(tt.i)
--print(tt.j)
--print(tt.j.jj)
--print(tt.j.kk)
--print(tt.k)
--print(tt.l)

--测试代码

return EncryptLuaTable
