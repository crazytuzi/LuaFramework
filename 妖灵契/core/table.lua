function table.dump(t, name)
	local LINEW = 80
	local function p(o, name, indent, send)
		local s = ""
		s = s .. string.rep("\t", indent)
		if name ~= nil then
			if type(name) == "number" then
				name = string.format("[%d]", name)
			else
				name = tostring(name)
				if indent ~= 0 then
					if not string.match(name, "^[A-Za-z_][A-Za-z0-9_]*$") then
						name = string.format("[\"%s\"]", name)
					end
				end
			end
			s = s .. name .. "="
		end
		if type(o) == "table" then
			s = s.."{"
			local temp = ""
			local keys = {}
			for k, v in pairs(o) do
				table.insert(keys, k)
			end
			pcall(function() table.sort(keys) end)
			for i, k in ipairs(keys) do
				local v = o[k]
				temp = temp .. p(v, k, indent+1, ",")
			end

			local temp2 = string.gsub(temp, "[\n\t]", "")
			if #temp2 < LINEW then
				temp = temp2
			else
				s = s .. "\n"
				temp = temp .. string.rep("\t", indent)
			end
			s = s .. temp .. "}" .. send .. "\n"
		else
			if type(o) == "string" then
				o = "[[" .. o .. "]]"
			elseif o == nil then
				o = "nil"
			end
			s = s .. tostring(o) .. send .. "\n"
		end
		return s
	end
	return p(t, name, 0, "")
end

function table.tostring(t, maxlayer, name)
	local tableDict = {}
	local layer = 0
	maxlayer = maxlayer or 999
	local function cmp(t1, t2)
		return tostring(t1) < tostring(t2)
	end
	local function table_r (t, name, indent, full, layer)
		local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
		local tag = indent .. id .. ' = '
		local out = {}  -- result
		if type(t) == "table" and layer < maxlayer then
			if tableDict[t] ~= nil then
				table.insert(out, tag .. '{} -- ' .. tableDict[t] .. ' (self reference)')
			else
				tableDict[t]= full and (full .. '.' .. id) or id
				if next(t) then -- Table not empty
					table.insert(out, tag .. '{')
					local keys = {}
					for key,value in pairs(t) do
						table.insert(keys, key)
					end
					table.sort(keys, cmp)
					for i, key in ipairs(keys) do
						local value = t[key]
						table.insert(out,table_r(value,key,indent .. '|  ',tableDict[t], layer + 1))
					end
					table.insert(out,indent .. '}')
				else table.insert(out,tag .. '{}') end
			end
		else
			local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
			table.insert(out, tag .. val)
		end
		return table.concat(out, '\n')
	end
	return table_r(t,name or 'Table', '', '', layer)
end


function table.print(t, name, maxlayer)
	print(table.tostring(t, maxlayer, name))
end

function table.index(table, element)
	for k, value in pairs(table or {}) do
		if value == element then
			return k
		end
	end
end

function table.keys(t)
	local keys = {}
	for k, v in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

function table.key(t, v)
	for k1, v1 in pairs(t) do
		if v1 == v then
			return k1
		end
	end
end

function table.safeget(root, ...)
	local args = {...}
	local len = select("#", ...)
	local v= root
	for i= 1, len do
		local key = select(i, ...)
		v = v[key]
		if not v then
			return
		end
	end
	return v
end

function table.safeinsert(root, v, ...)
	local args = {...}
	local len = select("#", ...)
	local parent = root
	for i= 1, len do
		local key = select(i, ...)
		if not parent[key] then
			parent[key] = {}
		end
		parent = parent[key]
	end
	table.insert(parent, v)
end

function table.safeset(root, v, ...)
	local args = {...}
	local len = select("#", ...)
	local parent = root
	for i= 1, len do
		local key = select(i, ...)
		if i==len then
			parent[key] = v
		else
			if not parent[key] then
				parent[key] = {}
			end
			parent = parent[key]
		end
	end
end

function table.values(t)
	local values = {}
	for k, v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

function table.count(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end

function table.copy(object)
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
		return new_table
	end
	return _copy(object)
end

function table.equal(t1, t2)
	if t1 == t2 then
		return true
	end
	if type(t1) == "table" and type(t2) == "table" then
		if t1.GetInstanceID and t2.GetInstanceID then
			return t1:GetInstanceID() == t2:GetInstanceID()
		end
		if table.count(t1) ~= table.count(t2) then
			return false
		end
		for k, v in pairs(t1) do
			if not table.equal(v, t2[k]) then
				return false
			end
		end
		return true
	end
	return false
end

function table.list2dict(t, key)
	local dict = {}
	if not t then
		return dict
	end
	for i, v in ipairs(t) do
		dict[v[key]] = v
	end
	return dict
end

function table.dict2list(t, sortkey, reverse)
	local function sortfunc(v1, v2)
		if reverse then
			return v2[sortkey] < v1[sortkey]
		else
			return v1[sortkey] < v2[sortkey]
		end
	end
	local list = {}
	for k, v in pairs(t) do
		table.insert(list, v)
	end
	if sortkey then
		table.sort(list, sortfunc)
	end
	return list
end

function table.extend(t1, t2)
	for k, v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

function table.update(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

function table.merge(...)
	local t = {}
	local list = {...}
	for i, dict in ipairs(list) do
		for k, v in pairs(dict) do
			t[k] = v
		end
	end
	return t
end

function table.shuffle(t)
	for i=#t, 1, -1 do
		local p = Utils.RandomInt(1, i)
		local temp = t[i]
		t[i] = t[p]
		t[p] = temp
	end
	return t
end

function table.slice(t, iStart, iEnd)
	local temp = {}
	if iStart <= iEnd then
		if #t < iStart then
			temp = t
		else
			for i=iStart, iEnd do
				local o = t[i]
				if o then
					table.insert(temp, o)
				else
					break
				end
			end
		end
	end
	return temp
end

function table.randomvalue(t)
	local keys = table.keys(t)
	local idx = Utils.RandomInt(1, #keys)
	return t[keys[idx]]
end

function table.randomkey(t)
	local keys = table.keys(t)
	local idx = Utils.RandomInt(1, #keys)
	return keys[idx]
end

function table.intersect(t1, t2)
	local list = {}
	for _, v in ipairs(t1) do
		if table.index(t2, v) ~= nil then
			table.insert(list, v)
		end
	end
	return list
end

function table.reverse (tab)
	local size = #tab
	local newTable = {}
	for i,v in ipairs (tab) do
		newTable[size+1-i] = v
	end
	return newTable
end

function table.range(iStart, iEnd)
	local list = {}
	for i = iStart, iEnd do
		table.insert(list, i)
	end
	return list
end