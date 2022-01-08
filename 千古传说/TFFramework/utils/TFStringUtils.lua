--[[--
	字符串操作

	--By: yun.bo
	--2013/8/8
]]

local StringUtils = {}

local mt = getmetatable('')
local nCharCode = 0
local _index = mt.__index

local idx = {}
local i, len, beg = 0, 0, 0

mt.__index = function(str, ...)
	local k = ...
	if 'number' == type(k) then
		return _index.sub(str, k, k)
	elseif 'string' == type(k) then
		if string[k] then
			return string[k]
		end
		i, len, beg = 1, #k, 0
		idx[1], idx[2], idx[3] = nil, nil, nil

		while i <= len do
			if k[i] == ':' then
				local num = tonumber(string.sub(k, beg, i - 1))
				idx[#idx + 1] = num and num or false
				beg = i + 1
			else
				nCharCode = string.byte(k, i) 
				if (nCharCode < 48 or nCharCode > 57) and nCharCode ~= 45 then
					error("can not index a string value: " .. str .. '[' .. k .. ']' .. debug.traceback())
				end
			end
			i = i + 1
		end
		idx[#idx + 1] = tonumber(string.sub(k, beg))
		idx[1] = idx[1] or 1
		idx[2] = idx[2] or #str
		idx[3] = idx[3] or 1
		return string.sub(str, idx[1], idx[2])
	elseif 'table' == type(k) then
		k[1] = k[1] or 1
		k[2] = k[2] or #str
		k[3] = k[3] or 1
		return string.sub(str, k[1], k[2])
	else
		return _index[k]
	end
end

mt.__mul = function (str, nRep) -- '*'
	if type(nRep) == 'number' then
		local ret = ''
		while nRep > 0 do
			ret = ret .. str
			nRep = nRep - 1
		end
		return ret
	end
	return str .. nRep
end

mt.__sub = function (stra, strb) -- '-'
	if type(stra) == 'string' then
		strb = tostring(strb)
		return string.gsub(stra, strb, "")
	end
	return stra
end

--[[--

Convert special characters to HTML entities.

The translations performed are:

-   '&' (ampersand) becomes '&amp;'
-   '"' (double quote) becomes '&quot;'
-   "'" (single quote) becomes '&#039;'
-   '<' (less than) becomes '&lt;'
-   '>' (greater than) becomes '&gt;'

@param string input
@return string

]]
function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

--[[--

Inserts HTML line breaks before all newlines in a string.

Returns string with '<br />' inserted before all newlines (\n).

@param string input
@return string

]]
function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

--[[--

Returns a HTML entities formatted version of string.

@param string input
@return string

]]
function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

--[[--

Split a string by string.

@param string str
@param string delimiter
@return table

]]
function string.split(str, delimiter, plain)
    if (delimiter=='') then return false end
	if plain == nil then plain = true end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, plain) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

--[[--

Strip whitespace (or other characters) from the beginning of a string.

@param string str
@return string

]]
function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

--[[--

Strip whitespace (or other characters) from the end of a string.

@param string str
@return string

]]
function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

--[[--

Strip whitespace (or other characters) from the beginning and end of a string.

@param string str
@return string

]]
function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

--[[--

Make a string's first character uppercase.

@param string str
@return string

]]
function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--[[--

@param string str
@return string

]]
function string.urlencodeChar(char)
    return "%" .. string.format("%02X", string.byte(c))
end

--[[--

URL-encodes string.

@param string str
@return string

]]
function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", string.urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

--[[--

Get UTF8 string length.

@param string str
@return int

]]
function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--[[--

Get Special string length.

@param string str
@return int

]]
function string.len2(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if tmp > 0x7F then cnt = cnt + 1 end 
    end
    return cnt
end


--[[--

Return formatted string with a comma (",") between every group of thousands.

**Usage:**

    local value = math.comma("232423.234") -- value = "232,423.234"


@param number num
@return string

]]
function string.formatNumberThousands(num)
    local formatted = tostring(tonumber(num))
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--[[--

Judge value[toffset..toffset+#prefix-1] == prefix

@value string
@prefix string
@toffset number 

]]

function string.startsWith(value, prefix, toffset)
	if value and prefix then
		toffset = (toffset or 1) > 0 and toffset or 1
		return string.sub(value, toffset, toffset + #prefix - 1) == prefix
	end
	return false
end

--[[--
	Judge if value tail with suffix
]]
function string.endsWith(value, suffix)
	if value and suffix then
		return string.sub(value, -#suffix) == suffix
	end
	return false
end

--[[--
	Exchange value's first charactor to uppercase value
]]
function string.title(value)
	return string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2, #value)
end

function string.charAt(value, position)
	if value and position and position > 0 then
		local b = string.byte(value, position, position + 1)
		return b and string.char(b) or b
	end
end

--[[--
	Check the string are whitespace
]]
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

function string.bytecode(value)
	if value then
		local bytes = {}
		local idx = 1
		local count = #value
		while idx <= count do
			local b = string.byte(value, idx, idx + 1)
			if b >= 100 then
				table.insert(bytes, '\\'..b)
			else
				table.insert(bytes, '\\0'..b)
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

function string.substr(value, startIndex, endIndex)
	if value then
		local ret = {}
		local idx = startIndex
		local count = endIndex or #value
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

return StringUtils