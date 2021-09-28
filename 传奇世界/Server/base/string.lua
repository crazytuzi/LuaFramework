--[[string.lua
描述：
	table库的扩展
]]

--@note：判定一个字符串以偏移量为起始位置，是否是以prefix为前缀的字符串
--@param value：要判定的字符串
--@param prefix：前缀字符串
--@param toffset：要判定的字符串的偏移量
function string.startsWith(value, prefix, toffset)
	if value and prefix then
		toffset = (toffset or 1) > 0 and toffset or 1
		return string.sub(value, toffset, toffset + #prefix - 1) == prefix
	end
	return false
end

--@note：判定一个字符串是否以suffix为后缀
function string.endsWith(value, suffix)
	if value and suffix then
		return string.sub(value, -#suffix) == suffix
	end
	return false
end

--@note：将字符串改成首字符大写
function string.title(value)
	return string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2, #value)
end

--@note：返回字符串value在position处的字符
function string.charAt(value, position)
	if value and position and position > 0 then
		local b = string.byte(value, position, position + 1)
		return b and string.char(b) or b
	end
end

--@note：判定一个字符串是否空格符的集合
function string.isWhitespace(value)
	if value then
		local len = #value
		for i = 1, len do
			local char = string.charAt(value, i)
			if char ~= " " and char ~= "\t" then
				return false
			end
		end
		return true
	end
	return false
end

--@note：将字符串转换成字符数组，包括非英文字符
--@ret：{char1, char2, ...}
function string.toArray(value)
	local ret = {}
	if value then
		local idx = 1
		local count = #value
		while idx <= count do
			local b = string.byte(value, idx, idx + 1)
			if b > 127 then
				table.insert(ret, string.sub(value, idx, idx + 1))
				idx = idx + 2
			else
				table.insert(ret, string.char(b))
				idx = idx + 1
			end
		end
	end
	return ret
end

--@note：将字符串转换成对应的ascii字符串，以空格为分解
function string.bytecode(value)
	if value then
		local bytes = {}
		local idx = 1
		local count = #value
		while idx <= count do
			local b = string.byte(value, idx, idx + 1)
			if b >= 100 then
				table.insert(bytes, (idx == 1 and '' or ' ')..b)
			else
				table.insert(bytes, (idx == 1 and '0' or ' 0')..b)
			end
			idx = idx + 1
		end
		local code, ret = pcall(loadstring(string.format("do local _='%s' return _ end", table.concat(bytes))))
		if code then
			return ret
		end
	end
	return ""
end

--@note：取字符串的字串
function string.substr(value, index, length)
	if value then
		local ret = {}
		local idx = index
		local count = length or #value
		while idx <= count do
			local b = string.byte(value, idx, idx + 1)
			if not b then
				break
			end
			if b > 127 then
				table.insert(ret, string.sub(value, idx, idx + 1))
				idx = idx + 2
			else
				table.insert(ret, string.char(b))
				idx = idx + 1
			end
		end
		return table.concat(ret)
	end
end

-------------colen:根据某个符合拆分字符串为数组(缺省为&,字符串形式:"a=v1&b-v2&c=v3", -------------------
function string.split(str, split)
	local strTab={}
	local sp=split or "&"
	while type(str)=="string" and string.len(str)>0 do
		local f=string.find(str,sp)
		local ele
		if f then
			ele=string.sub(str,1,f-1)
			str=string.sub(str,f+1)
		else
			ele=str
		end
		if ele then
			local sp2=string.find(ele,"=")
			if sp2 then
				local b=string.sub(ele,sp2+1)
				local s,b2=pcall(loadstring("local bb="..b..";return bb"))
				strTab[string.sub(ele,1,sp2-1)]=b2
			end
		end
		if not f then break	end
	end
	return strTab
end

--[[ 字符串str根据字符split(默认&)拆分转表结构,eg:"3&2&1" --> {3,2,1}    ---- by:Andy---- ]]
function string.split1(str, split)
	local strTab={}
	local sp=split or "&"
	while type(str)=="string" and string.len(str)>0 do
		local f=string.find(str,sp)
		local ele
		if f then
			ele=string.sub(str,1,f-1)
			str=string.sub(str,f+1)
		else
			ele=str
		end
		table.insert(strTab, ele)
		if not f then break	end
	end
	return strTab
end