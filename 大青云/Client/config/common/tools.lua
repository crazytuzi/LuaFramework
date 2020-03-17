
print("--------init tools----------")

_G.table = _G.table or {}

table.loadstring = function(strData)
    if strData == nil or strData == "" then
        return {}
    end
    local f = loadstring("do local ret=" .. strData ..  " return ret end")
    if f then
        return f() or {}
    else
        return {}
    end
end

table.ClearTable = function(clearTable)
	if not clearTable then clearTable = {} return end
	for k,v in pairs(clearTable) do
		clearTable[k] = nil
	end
end

table.tostring = function(t)
    local mark={}
    local assign={}
    local ser_table 
    if type(t) ~= "table" then
        return "{}"
    end
    ser_table = function (tbl,parent)
        mark[tbl]=parent
        local tmp={}
        for k,v in pairs(tbl) do
            local key= type(k)=="number" and "["..k.."]" or "[".. string.format("%q", k) .."]"
            if type(v)=="table" then
                local dotkey= parent.. key
                if mark[v] then
                    table.insert(assign,dotkey.."="..mark[v])
                else
                    table.insert(tmp, key.."="..ser_table(v,dotkey))
                end
            elseif type(v) == "string" then
                table.insert(tmp, key.."=".. string.format('%q', v))
            elseif type(v) == "number" or type(v) == "boolean" then
                table.insert(tmp, key.."=".. tostring(v))
            end
        end
        return "{"..table.concat(tmp,",").."}"
    end
    if #assign > 0 then
        print(debug.traceback())
    end
    return ser_table(t, "ret") .. table.concat(assign," ")
end

function table.tostr(t, tabnum)
	local tabnum = tabnum or 1
	local tabs = ''
	for i = 1, tabnum do tabs = tabs .. '\t' end
	local tt = type(t)
	assert(tt=='table','bad argument #1(table expected, got '..tt..')')
	local ts = {}
	for k,v in pairs(t) do
		local tv = type(v)
		assert(tv~='userdata',k..':userdata unexpected')
		assert(tv~='function',k..':function unexpected')
		assert(tv~='thread',k..':thread unexpected')
		--assert(tv=='nil', k..':nil unexpcted')
		local tk = type(k)
		if tk=='number' then k = '['..k..']' end
		k = tabs .. k
		if tv=='table' then ts[#ts+1] = k..'='..table.tostr(v, tabnum + 1)
		elseif tv=='string' then ts[#ts+1] = k.."='"..v.."'"
		else ts[#ts+1] = k..'='..tostring(v) end
	end
	return  '{\n' .. table.concat( ts, ',\n' ) .. '\n' .. tabs .. '}'
end

table.clone = function(srctable)
    if (srctable == nil) then
        return nil
    else
        return table.loadstring(table.tostring(srctable))
    end
end

_G.trace = function(e)
    if type(e) == "table" then
        print(tostringex(e))
    else
        print(tostring(e))
    end
end

_G.tostringex = function(v, len)
    if len == nil then len = 0 end
    local pre = string.rep('\t', len)
    local ret = ""
    if type(v) == "table" then
        if len > 5 then return "\t{ ... }" end
        local t = ""
        local keys = {}
        for k, v1 in pairs(v) do
            table.insert(keys, k)
        end
        for k, v1 in pairs(keys) do
            k = v1
            v1 = v[k]
            t = t .. "\n\t" .. pre .. tostring(k) .. ":"
            t = t .. tostringex(v1, len + 1)
        end
        if t == "" then
            ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
        else
            if len > 0 then
                ret = ret .. "\t(" .. tostring(v) .. ")\n"
            end
            ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
        end
    else
        ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
    end
    return ret
end

_G.MAX_COPY_LAY = 7
_G.deepcopy = function(tbSrc, nMaxLay)
    nMaxLay = nMaxLay or MAX_COPY_LAY
    if (nMaxLay <= 0) then
        return
    end
    
    local tbRet = {}
    for k, v in pairs(tbSrc) do
        if (type(v) == "table") then
            tbRet[k] = deepcopy(v, nMaxLay-1)
        else
            tbRet[k] = v
        end
    end
    
    return tbRet
end

local _loadfile = function(fileName)
	 local fe = _File.new()
	 fe:open(fileName)
	 local data = fe:read()
	 fe:close()
	 return data
end

table.readtab = function(fileName, index1, index2, isLowMem)
    if not isLowMem then isLowMem = 0 end
    assert(isLowMem == 0 or isLowMem == 1)
	local f = _File.new()
    local fileData = _loadfile(fileName)
	if not fileData then
		print("error read tab file：" .. fileName)
		return
	end
    if string.byte(fileData, 1, 1) == 0x1B or string.byte(fileData, 3, 3) == 0xFF then
        fileData = _dofile(fileName)
    end
	if (string.byte(fileData, 1, 1) == 0xEF) then
		fileData = string.sub(fileData, 4)
	end

	local rows = split(fileData, "\r\n")
	local ret = {}
	local colNames = nil
    local colNamesIndex, meta
    if isLowMem == 1 then
        colNamesIndex = {}
        meta = 
        {
            __index = function(t, k)
                local ret = rawget(t, colNamesIndex[k])
                return ret
            end
        }
    end
	for i = 1, #rows do
		local row = rows[i]
		if row and row ~= "" and string.sub(row, 1, 1) ~= "#" then
			local col = split(row, "\t")
			if not colNames then
				colNames = col
                if isLowMem == 1 then
                    for k, v in pairs(colNames) do
                    	colNamesIndex[v] = k
                    end
                end
			else
				local item = nil
                if isLowMem == 0 then
                    item = {}
                end
				local itemId = tonumber(col[1])
				if itemId == nil then
					print(fileName.."\r\n"..debug.traceback().."\r\n" .. tostringex(rows))
				end

                assert(itemId)
				for i = 1, #col do
					if colNames[i] ~= "" then
						local value = col[i]
						if string.char(1) == '"' and string.char() == '"' then
							value = string.sub(value, 2, string.len() - 1);
						end
						if string.sub(colNames[i], 1, 2) == "sz" then
                            assert(string.sub(colNames[i], 3, 3) == "_")
                            value = col[i]
                        elseif string.sub(colNames[i], 1, 5) == "list_" then
                            if value == "" then
                                value = {}
                            else
								local sp_1 = string.find(value, ",");
								local sp_2 = string.find(value, "|");
								if sp_1 and sp_2 then
									assert(false, fileName .. " list_不支持同时存在,和|:" .. value);
								end
								if sp_1 then									
									value = split(value, ",")
								elseif sp_2 then
									value = split(value, "|")
								else
									value = {value};
								end	
															
                                if string.sub(colNames[i], 6, 8) == "sz_" then
									for k,v in pairs(value) do
										value[k] = _v
									end
                                else
                                    for k, v in pairs(value) do value[k] = tonumber(v) or 0 end
                                end
                            end
						else
							value = tonumber(col[i]) or 0
                            if string.find(value, "\"") then
                                assert(false, fileName .. " 不能包含双引号" .. value)
                            end
                        end
                        if isLowMem == 1 then
                            col[i] = value
                        else
						    item[colNames[i] ] = value
                        end
                        
					end
                end
                if ret[itemId] then
				    assert(false, fileName .. " 有重复 id:" .. itemId .. tostringex(colNames))
                end
                --TraceError(itemId);
                if isLowMem == 1 then
    				setmetatable(col, meta)
    				ret[itemId] = col
                else
                    ret[itemId] = item
                end
			end
		end
    end
    if index1 and index2 then
        local indexed_ret = {}
        for k, v in pairs(ret) do
            if not indexed_ret[v[index1]] then
                indexed_ret[v[index1]] = {}
            end
            if index2 ~= "*" then
    			assert(not indexed_ret[v[index1]][v[index2]], "表" .. fileName .. "有重复双主键：" .. index1 .. ":" .. tostring(v[index1]) .. "\t" .. index2 .. ":" .. tostring(v[index2]));
                indexed_ret[v[index1]][v[index2]] = v
            else
                table.insert(indexed_ret[v[index1]],  v)
            end
        end
        return indexed_ret
    elseif index1 then
        local indexed_ret = {}
        for k, v in pairs(ret) do
            assert(not indexed_ret[v[index1]], "表" .. fileName .. "有重复索引：" .. index1 .. ":" .. tostring(v[index1]))
            indexed_ret[v[index1]] = v
        end
        return indexed_ret
    else
        return ret
    end
end










