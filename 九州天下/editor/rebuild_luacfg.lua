null = {}

function Rebuild(file_name, output_root_dir)
	local old_cfg = require(file_name)
	local key, _ = next(old_cfg)
	local depth = type(key)=='number' and 1 or 2
	local new_cfg = nil
	local fail_str = ""
	local table_str = ""

	if 1 == depth then
		local default_table = nil
		new_cfg, default_table, fail_str = RebuildTable(old_cfg)
		if nil ~= default_table then
			new_cfg["default_table"] = default_table
		end

		table_str = "return { \n" 
		for k, v in pairs(new_cfg) do
			local key = type(k) == 'string' and string.format('["%s"]', k) or string.format('[%s]', k)
			table_str = table_str .. "	" .. key .. "=" .. TableToStr(v) .. ",\n"
		end
		table_str = table_str .. "}"

	elseif 2 == depth then
		new_cfg = {}
		for k, v in pairs(old_cfg) do
			local default_table = nil
			new_cfg[k], default_table, fail_str = RebuildTable(v)
			if nil ~= default_table then
				new_cfg[k .. "_default_table"] = default_table
			end
			if "" ~= fail_str then
				break
			end
		end

		table_str = "return { \n" 
		for k1, v1 in pairs(new_cfg) do
			local key = type(k1) == 'string' and string.format('["%s"]', k1) or string.format('[%s]', k1)
			table_str = table_str .. "	" .. key .. "=" .. TableToStr(v1, 1) .. ",\n"
		end
		table_str = table_str .. "}"
	end

	local url = output_root_dir .. "/" .. file_name .. "_new.lua"
	local f = assert(io.open(url, 'w'))
	f:write(table_str)
	f:close()

	print("Rebuild Succ " .. url, fail_str)
end

function RebuildTable(cfg)
	local times_map = {}
	local item_count = 0
	local last_key_count = 0

	for _, t in pairs(cfg) do
		item_count = item_count + 1

		local key_count = 0
		for k,v in pairs(t) do
			times_map[k] = times_map[k] or {}
			times_map[k][v] = (times_map[k][v] or 0) + 1
			key_count = key_count + 1
		end

		 -- 列表项的key值数量不一致，这里检查出错（策划在装备配置表加字段时经常其他标签没加）
		if last_key_count > 0 and last_key_count ~= key_count then 
			return cfg, nil, "字段数量不一致"
		end

		last_key_count = key_count
	end

	if item_count <= 2 then -- 表太短不重构建 
		return cfg, nil, ""
	end

	local default_table = {}
	for k, t in pairs(times_map) do
		local max_times = 0
		local default_value = nil
		for value, times in pairs(t) do
			if times > max_times then
				max_times = times
				default_value = value
			end
		end

		default_table[k] = default_value
	end

	for k, t in pairs(cfg) do
		for k,v in pairs(t) do
			if v == default_table[k] then
				t[k] = nil
			end
		end
	end

	return cfg, default_table, ""
end

function ToStringEx(value, depth)
	if value == null then
		return 'null'
    elseif type(value)=='table' then
    	depth = depth + 1
       return TableToStr(value, depth)
    elseif type(value)=='string' then
    	value = string.gsub(value, "\n", "\\n")
    	value = string.gsub(value, "\r", "\\r")
        return '\"'..value..'\"'
    else
       return tostring(value)
    end
end

function TableToStr(t, depth)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    local is_ary = true
    for key,value in pairs(t) do
    	local end_s = ","
    	local start_s = ""
    	if depth == 1 and type(value)=='table' then
    		start_s = "\n		"
    		end_s = ","
    	end

        if key == i and is_ary then
            retstr = retstr .. start_s .. ToStringEx(value, depth) .. end_s
        else
        	is_ary = false
            if type(key)=='number' then
                retstr = retstr .. start_s .. '['..ToStringEx(key, depth).."]="..ToStringEx(value, depth) .. end_s
           
            elseif type(key) == 'string' then
            	retstr = retstr .. start_s .. key .. "=" .. ToStringEx(value, depth) .. end_s
           	end
        end

        i = i+1
    end

    retstr = retstr .. "}"

	return retstr
end

function InitMemtable(cfg)
	local default_table = cfg["default_table"]
	if nil == default_table then
		return
	end

    local func = function (tbl, key)
        local nk, nv = next(default_table, key)
        if nk then 
            nv = tbl[nk]
        end

        return nk, nv
    end

	local mt = {}
	mt.__index = function(tbl, key)
		local val = rawget(tbl, key)
		return val or default_table[key]
	end

	mt.__pairs = function(tbl, key)
		return func, tbl, nil
	end

	for k, v in pairs(cfg) do
		if k ~= "default_table" then
			setmetatable(v, mt)
		end
	end
end

--Rebuild("config/auto_new/activityshuijing_auto", "F:/ug04_cn/client/u3d_proj/Assets/Game/Lua")

