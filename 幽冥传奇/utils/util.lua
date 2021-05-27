function Split(split_string, splitter)
	-- 以某个分隔符为标准，分割字符串
	-- @param split_string 需要分割的字符串
	-- @param splitter 分隔符
	-- @return 用分隔符分隔好的table

	local split_result = {}
	local search_pos_begin = 1

	while true do
		local find_pos_begin, find_pos_end = string.find(split_string, splitter, search_pos_begin)
		if not find_pos_begin then
			break
		end

		split_result[#split_result + 1] = string.sub(split_string, search_pos_begin, find_pos_begin - 1)
		search_pos_begin = find_pos_end + 1
	end

	if search_pos_begin <= string.len(split_string) then
		split_result[#split_result + 1] = string.sub(split_string, search_pos_begin)
	end

	return split_result
end

function Join(join_table, joiner)
	-- 以某个连接符为标准，返回一个table所有字段连接结果
	-- @param join_table 连接table
	-- @param joiner 连接符
	-- @param return 用连接符连接后的字符串

	if #join_table == 0 then
		return ""
	end

	local fmt = "%s"
	for i = 2, #join_table do
		fmt = fmt .. joiner .. "%s"
	end

	return string.format(fmt, unpack(join_table))
end

function DeepCopy(object)
	-- @param object 需要深拷贝的对象
	-- @return 深拷贝完成的对象

	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end

		return setmetatable(new_table, getmetatable(object))
	end

	return _copy(object)
end

function SwitchFuncs(t)
	t.Case = function (self, x)
		return self[x] or self.default
	end

	return t
end

function ToBoolean(s)
	-- 将字符串转换为boolean值

	local transform_map = {
		["true"] = true,
		["false"] = false,
	}

	return transform_map[s]
end

function TabToStr( tab, flag )
	local result = ""
	result = string.format( "%s{", result )

	local filter = function( str )
		str = string.gsub( str, "%[", " " )
		str = string.gsub( str, "%]", " " )
		str = string.gsub( str, "\"", " " )
		str	= string.gsub( str, "%'", " " )
		str	= string.gsub( str, "\\", " " )
		str	= string.gsub( str, "%%", " " )
		return str
	end

	for k,v in pairs(tab) do
		if type(k) == "number" then
			if type(v) == "table" then
				result = string.format( "%s[%d]=%s,", result, k, TabToStr( v ) )
			elseif type(v) == "number" then
				result = string.format( "%s[%d]=%d,", result, k, v )
			elseif type(v) == "string" then
				result = string.format( "%s[%d]=%q,", result, k, v )
			elseif type(v) == "boolean" then
				result = string.format( "%s[%d]=%s,", result, k, tostring(v) )
			else
				if flag then
					result = string.format( "%s[%d]=%q,", result, k, type(v) )
				else
					error("the type of value is a function or userdata")
				end
			end
		else
			if type(v) == "table" then
				result = string.format( "%s%s=%s,", result, k, TabToStr( v, flag ) )
			elseif type(v) == "number" then
				result = string.format( "%s%s=%d,", result, k, v )
			elseif type(v) == "string" then
				result = string.format( "%s%s=%q,", result, k, v )
			elseif type(v) == "boolean" then
				result = string.format( "%s%s=%s,", result, k, tostring(v) )
			else
				if flag then
					result = string.format( "%s[%s]=%q,", result, k, type(v) )
				else
					error("the type of value is a function or userdata")
				end
			end
		end
	end
	result = string.format( "%s}", result )
	return result
end

function Serialize( tab, level, strStart, strEnd )
	local rep = string.rep
	strStart = strStart or "\""
	strEnd = strEnd or "\""
	level = level or 0

	local str = "\n" .. rep( "\t", level ) .. "{\n"
	for k,v in pairs(tab) do
		local kIsStr = 0
		if type(k) == "string" then
			kIsStr = 1
		end
		if type(v) == "table" then
			str = str .. rep( "\t", level+1 ) .. "[" .. rep( strStart, kIsStr ) .. k .. rep( strEnd, kIsStr ) .. "]" .. " = " .. Serialize( v, level+1 ) .. "\n"
		else
			local vIsStr = 0
			if type(v) == "string" then
				vIsStr = 1
			end
			str = str .. rep( "\t", level+1 ) .. "[" .. rep( strStart, kIsStr ) .. k .. rep( strEnd, kIsStr ) .. "]" .. " = "..rep( strStart, vIsStr ) .. v .. rep( strEnd, vIsStr ) .. ",\n"
		end
	end
	str = str .. rep( "\t", level ) .. "},"
	return str
end


function TableCopy(t, n)
	if nil == t then return end
	if nil == n then
		n = 1
	end

	local new_t = {}
	for k, v in pairs(t) do
		if n > 0 and type(v) == "table" then
			local T = TableCopy(v, n - 1)
			new_t[k] = T
		else
			new_t[k] = v
		end
	end
	
	return new_t
end

function GetCenterPoint(node)
	local size = node:getContentSize()
	local  point = cc.p(size.width / 2, size.height / 2)
	return point
end

function To_Utf8(a)  
  local n, r, u = tonumber(a)  
  if n<0x80 then                        -- 1 byte  
    return string.char(n)  
  elseif n<0x800 then                   -- 2 byte  
    u, n = tail(n, 1)  
    return string.char(n+0xc0) .. u  
  elseif n<0x10000 then                 -- 3 byte  
    u, n = tail(n, 2)  
    return string.char(n+0xe0) .. u  
  elseif n<0x200000 then                -- 4 byte  
    u, n = tail(n, 3)  
    return string.char(n+0xf0) .. u  
  elseif n<0x4000000 then               -- 5 byte  
    u, n = tail(n, 4)  
    return string.char(n+0xf8) .. u  
  else                                  -- 6 byte  
    u, n = tail(n, 5)  
    return string.char(n+0xfc) .. u  
  end  
end 

function IsEmptyTable(table)
	for k,v in pairs(table) do
		return false
	end
	return true
end

function IsInTable(a, table)
	for k,v in pairs(table) do
		if a == v then
			return true
		end
	end
	return false
end

function ConcatTable(t1, t2)
	t1 = t1 or {}
	t2 = t2 or {}
	
	local begin = #t1 + 1
	local len = #t2
	for i = 0, len - 1 do
		t1[begin + i] = t2[i + 1]
	end
end

function TableWalk(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

-- 使用 ListToMap(tt, "id") 后将 tt = {
-- 	{id = 2, name = "23", sex = 0},
-- 	{id = 2, name = "23", sex = 1},
-- 	{id = 3, name = "23", sex = 0},
-- 	{id = 3, name = "23", sex = 1},
-- }
-- 变成tt = {
-- 	[2] = {id = 2, name = "23", sex = 0},
-- 	[3] = {id = 3, name = "23", sex = 0},
-- }
function ListToMap(list, ...)
	if nil == list then
		ErrorLog("ListToMap list is nil")
		return nil
	end

	local map = {}
	local key_list = {...}
	local max_depth = #key_list

	if max_depth <= 0 then
		ErrorLog("ListToMap max_depth is error")
		return nil
	end

	function parse_item(t, item, depth)
		local key_name = key_list[depth]
		local key = item[key_name]
		if nil == t[key] then
			t[key] = {}
		end

		if depth < max_depth then
			parse_item(t[key], item, depth + 1)
		else
			t[key] = item
		end
	end

	for i,v in ipairs(list) do
		parse_item(map, v, 1)
	end

	return map
end

-- 使用 ListToMapList(tt, "id") 后将 tt = {
-- 	{id = 2, name = "23", sex = 0},
-- 	{id = 2, name = "23", sex = 1},
-- 	{id = 3, name = "23", sex = 0},
-- 	{id = 3, name = "23", sex = 1},
-- }
-- 变成tt = {
-- 	[2] = {{id = 2, name = "23", sex = 0},
-- 		   {id = 2, name = "23", sex = 1},}

-- 	[3] = {{id = 3, name = "23", sex = 0},
--		   {id = 3, name = "23", sex = 1},}
-- }
function ListToMapList(list, ...)
	if nil == table then
		ErrorLog("ListToMapList list is nil")
		return nil
	end

	local map = {}
	local key_list = {...}
	local max_depth = #key_list

	if max_depth <= 0 then
		ErrorLog("ListToMapList max_depth is error")
		return nil
	end

	function parse_item(t, item, depth)
		local key_name = key_list[depth]
		local key = item[key_name]
		if nil == t[key] then
			t[key] = {}
		end

		if depth < max_depth then
			parse_item(t[key], item, depth + 1)
		else
			table.insert(t[key], item)
		end
	end

	for i,v in ipairs(list) do
		parse_item(map, v, 1)
	end

	return map
end


----背包筛选
--想要判断一个数据是否在集合里 可以使用这个方法构建一个背包
function SetBag(list)
	local list_ = {}
	for i,v in ipairs(list) do
		list_[v] = true
	end
	return list_
end

function TableSize(table)
	local size = 0
	for _,_ in pairs(table) do
		size = size + 1
	end
	return size
end

--去掉字符数值
function DelNumByString(str)
	return string.gsub(str,"[%d+]","")
end	