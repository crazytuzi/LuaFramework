_G.Debug = function(...)
	print("################## ", ...)
end



_G.Utils = {}
function Utils.dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

_G.split = function(s, delim)
    assert (type (delim) == "string" and string.len (delim) > 0,"bad delimiter")
    local start = 1  local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end
        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))
    return t
end

_G.printguid = function(guid)
	if type(guid) ~= "string" then
		print(guid);
		return;
	end
	local t = split(guid,"_");
	local result = "";
	local lowUint = tonumber(t[2]);
	local highUint = tonumber(t[1]);
	local highRemain = 0;
	local lowRemain = 0;
	local tempNum = 0;
	local MaxLowUint = math.pow(2,32);
	while highUint~=0 or lowUint~=0 do
		highRemain = highUint%10;
		tempNum = highRemain*MaxLowUint + lowUint;
		lowRemain = tempNum%10;
		result = tostring(lowRemain) .. result;
		highUint = toint((highUint-highRemain)/10);
		lowUint = toint((tempNum-lowRemain)/10);
	end
	print(result);
end

function table:push(value)
	table.insert(self, value)
end

function _G.writeBytes(input, maxsize)
    local size = input:len()
    local result = input
    if maxsize == nil then
        maxsize = 32
    end
    local pad = maxsize - size
    if pad > 0 then
        for i = 1, pad do
            result = result .. '\0'
        end
    else
        result = result:sub(1, maxsize)
    end
    return result
end

function _G.writeString(input,len)
	local size = input:len();
	local result = input;
	if len then
		local pad = len - size
		if pad > 0 then
			for i = 1, pad do
				result = result .. '\0'
			end
		else
			result = result:sub(1, len)
		end
	else
		result = string.pack('<i4', size) .. result;
	end
	return result;
end

function _G.writeBuffBytes(input)
	local len = input:len();
	local result = string.pack('<i4', len);
	result = result .. input;
	return result;
end

function _G.writeInt(input)
    return string.pack('<i4', input)
end

function _G.writeInt64(input)
    return string.pack('<i8', input)
end

function _G.writeGuid(input)
	if type(input) == "number" or input=="" then
		local result = "";
		result = result .. string.pack('<i4', 0);
		result = result .. string.pack('<i4', 0);
		return result;
	else
		local t = split(input,"_");
		local result = "";
		result = result .. string.pack('<i4', tonumber(t[2]));
		result = result .. string.pack('<i4', tonumber(t[1]));
		return result;
	end
end

function _G.writeDouble(input)
	return string.pack("<i8", input);
end

function _G.readInt(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = string.unpack('<i', input, begin)
    idx = begin + 4
    return value, idx
end

function _G.readString32(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:sub(begin, begin + 32)
    idx = begin + 32
    return value, idx
end

function _G.readString64(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:sub(begin, begin + 64)
    idx = begin + 64
	local findEndFlag = string.find(value,"\0");
	if findEndFlag then
		value = string.sub(value,1,findEndFlag-1);
	end
    return value, idx
end

function _G.readString(input,begin,len)
	local value,idx
	if not begin then begin=1; end
	if not len then 
		len = string.unpack('<i', input, begin)
		begin = begin + 4;
	end
	value = input:sub(begin, begin+len);
	idx = begin + len;
	local findEndFlag = string.find(value,"\0");
	if findEndFlag then
		value = string.sub(value,1,findEndFlag-1);
	end
	return value, idx
end

function _G.readBuffBytes(input,begin,len)
	local value,idx
	if not begin then begin=1;end
	value = input:sub(begin,len);
	idx = begin + len;
	return value, idx
end

function _G.readByte(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = input:sub(begin, begin + 1)
    idx = begin + 1
    return string.byte(value), idx

end

function _G.readShort(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = string.unpack('<h', input, begin)
    idx = begin + 2
    return value, idx

end

function _G.readInt64(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = string.unpack('<l', input, begin)
    idx = begin + 8
    return value, idx
end

function _G.readGuid(input,begin)
	local value,idx
	local v1 = string.unpack('<i', input, begin);
	local v2 = string.unpack('<i', input, begin+4);
	value = tostring(v2) .."_".. tostring(v1);
	idx = begin + 8;
	return value,idx
end

function _G.readNumber(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = string.unpack('<l', input, begin)
    idx = begin + 8
    return value, idx

end

function _G.readDouble(input, begin)
    local value
    local idx
    if begin == nil then
        begin = 1
    end
    value = string.unpack('<d', input, begin)
    idx = begin + 8
    return value, idx

end

