--[[serialize.lua
描述：
	声明序列化接口,并提供serialize和unserialize函数用于对Table对象进行序列化和反序列化操作
--]]

local EMPTY_TABLE = {}

--@note：table是数组形式
function table.isArray(tab)
	if not tab then
		return false
	end

	local ret = true
	local idx = 1
	for f, v in pairs(tab) do
		if type(f) == "number" then
			if f ~= idx then
				ret = false
			end
		else
			ret = false
		end
		if not ret then break end
		idx = idx + 1
	end
	return ret
end

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

	local code, ret = pcall(loadstring(string.format([[do local _=%s return _ end]], str)))

	if code then
		return ret
	else
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	end
end
