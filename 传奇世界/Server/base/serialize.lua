--[[serialize.lua
描述：
	声明序列化接口,并提供serialize和unserialize函数用于对Table对象进行序列化和反序列化操作
--]]

require "base.interface"

Serializable = interface(nil,
	"writeObject",
	"readObject")

local EMPTY_TABLE = {}

--@note：序列化一个Table
function serialize(t)
	local mark={}
	local assign={}

	local function table2str(t, parent)
		mark[t] = parent
		local ret = {}

		if table.isArray(t) then
			table.foreach(t, function(i, v)
				local k = tostring(i)
				local dotkey = parent.."["..k.."]"
				local t = type(v)
				if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
					--ignore
				elseif t == "table" then
					if mark[v] then
						table.insert(assign, dotkey.."="..mark[v])
					else
						table.insert(ret, table2str(v, dotkey))
					end
				elseif t == "string" then
					table.insert(ret, string.format("%q", v))
				elseif t == "number" then
					if v == math.huge then
						table.insert(ret, "math.huge")
					elseif v == -math.huge then
						table.insert(ret, "-math.huge")
					else
						table.insert(ret,  tostring(v))
					end
				else
					table.insert(ret,  tostring(v))
				end
			end)
		else
			table.foreach(t, function(f, v)
				local k = type(f)=="number" and "["..f.."]" or f
				local dotkey = parent..(type(f)=="number" and k or "."..k)
				local t = type(v)
				if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
					--ignore
				elseif t == "table" then
					if mark[v] then
						table.insert(assign, dotkey.."="..mark[v])
					else
						table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey)))
					end
				elseif t == "string" then
					table.insert(ret, string.format("%s=%q", k, v))
				elseif t == "number" then
					if v == math.huge then
						table.insert(ret, string.format("%s=%s", k, "math.huge"))
					elseif v == -math.huge then
						table.insert(ret, string.format("%s=%s", k, "-math.huge"))
					else
						table.insert(ret, string.format("%s=%s", k, tostring(v)))
					end
				else
					table.insert(ret, string.format("%s=%s", k, tostring(v)))
				end
			end)
		end

		return "{"..table.concat(ret,",").."}"
	end

	if type(t) == "table" then
		return string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))
	else
		return tostring(t)
	end
end

--@note：反序列化一个Table
function unserialize(str)
	if str == nil or str == "nil" then
		return nil
	elseif type(str) ~= "string" then
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	elseif #str == 0 then
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	end

	local code, ret = pcall(loadstring(string.format("do local _=%s return _ end", str)))

	if code then
		return ret
	else
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	end
end

--@note：给DBID加密
function encodeDBID(dbid)
	local dbid = tonumber(dbid)
	if dbid then
		local s1 = dbid*7%9+1
		local s2 = dbid*11%10
		local ds = s1*51375 + s2*5713
		local s3 = string.format("%.7d", dbid + ds)
		if s2 == 0 or (s3 % 2 == 0) then
			return s1..s3..s2
		elseif s3 % 2 == 1 then
			return s2..s3..s1
		end
	end
end

--@note：给DBID解密
function decodeDBID(dbid)
	local dbid = tonumber(dbid)
	if dbid and dbid > 0 then
		local d = -1
		local s = string.format("%.9d", tonumber(dbid))
		local d1 = tonumber(string.sub(s, 1, 1))
		local d2 = tonumber(string.sub(s, 9, 9))
		local d3 = tonumber(string.sub(s, 2, 8))
		if d2 == 0 or (d3 % 2 == 0) then
			d = d3 - d1*51375 - d2*5713
		elseif 3 % 2 == 1 then
			d = d3 - d2*51375 - d1*5713
		end
		if d > 0 then
			return d
		end
	end
end

function RevertVector(buff)
	local tab = {}
	local len = buff:popInt()
	for idx = 1, len do
		local value = buff:popInt()
		table.insert(tab, value)
	end
	return tab
end

function RevertMap(buff)
	local tab = {}
	local len = buff:popInt()
	for idx = 1, len do
		local key = buff:popInt()
		local value= buff:popInt()
		tab[key] = value
	end
	return tab
end