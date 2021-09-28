function IsNil(uobj)
    return uobj == nil or uobj:Equals(nil)
end

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

function DeepCopy(object)
	-- @param object 需要深拷贝的对象
	-- @return 深拷贝完成的对象

	local lookup_table = {}
	local function _copy(pobj)
		if type(pobj) ~= "table" then
			return pobj
		elseif lookup_table[pobj] then
			return lookup_table[pobj]
		end

		local new_table = {}
		lookup_table[pobj] = new_table
		for index, value in pairs(pobj) do
			new_table[_copy(index)] = _copy(value)
		end

		return setmetatable(new_table, getmetatable(pobj))
	end

	return _copy(object)
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

function GetDataRange(data, key)
	local return_data_range = {}
	local set = {}
	for i,v in ipairs(data) do
		if not set[v[key]] then
			table.insert(return_data_range, v[key])
			set[v[key]] = true
		end
	end
	table.sort(return_data_range)
	return return_data_range
end

function GetRangeRank(range,value)
	if range ~=nil and value ~= nil then
		for k,v in ipairs(range) do
			if value <= v then
				return v
			end
		end
	end
	return range and range[1] or 0
end

function TestPrint( ... )
	local func = function ( ... )
		local t = { ... }
		for i,v in pairs(t) do
			print_error(v)
		end
	end
	if TestModeSwich == "True" then
		func( ... )
	end

end

function TestLogic(func)
	if TestModeSwich == "True" then
		func()
	end
end

function TestFlag()
	if TestModeSwich == "True" then
		return true
	end
	return false
end

function TableSortByCondition(t, IsAheadCallBack)
	if t == nil or next(t) == nil or IsAheadCallBack == nil then
		ErrorLog("排序传值错误，表或回调为空")
		return t
	end
	local ahead_list = {}
	local behind_list = {}
	for i,v in ipairs(t) do
		if IsAheadCallBack(v) then
			table.insert(ahead_list, v)
		else
			table.insert(behind_list, i)
		end
	end
	for i,v in ipairs(behind_list) do
		table.insert(ahead_list,t[v])
	end
	return ahead_list
end

function CheckInvalid(param1)
	if param1 == nil then
		return true
	end
	if type(param1) == "table" then
		if next(param1) == nil then
			return true
		end
	end
	return false
end

function GetListNum(list)
	local num = 0

	if nil == list then
		return num
	end

	for _,_ in pairs(list) do
		num = num + 1
	end
	return num
end

-- 只搜索两层
function FindObjsByName(transform, name)
	local objs = {}
	for i = 0, transform.childCount - 1 do
		if transform:GetChild(i) then
			local obj = transform:GetChild(i)
			if obj.name == name then
				table.insert(objs, obj)
			end
			for j = 0, obj.childCount - 1 do
				local child_obj = obj:GetChild(j)
				if child_obj.name == name then
					table.insert(objs, child_obj)
				end
			end
		end
	end
	return objs
end

function CheckList(list, ...)
	if not list then
		return
	end
	local data = nil
	local param_list = {...}
	for i,v in ipairs(param_list) do
		if not list[v] then
			-- print_error("取值错误")
			-- print_error(i, v)
			-- print_error("当前层数据为")
			-- print_error(list)
			return nil
		end
		list = list[v]
	end
	data = list
	return data
end