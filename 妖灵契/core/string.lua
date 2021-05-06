local string = string

function string.safesplit(splitstr, sep)
	local t = {}
	if sep then
		local p 
		local len = string.len(sep)
		if len > 1 and sep ~= string.rep(".", len) and not sep:find("%%") then
			p = "(.-)"..sep
			splitstr = splitstr .. sep
		else
			p = "([^"..sep.."]+)"
		end
		for str in splitstr:gmatch(p) do
			if str ~= "" then
				table.insert(t, str)
			end
		end
	end
	return t
end

function string.split(splitstr, sep)
	local b, ret = pcall(string.safesplit, splitstr, sep)
	if b then
		return ret
	else
		printerror("splitstr:", splitstr, ",sep:", sep, ",errmsg:", ret)
		return {}
	end
end

string.oriformat = string.format
function string.format(s, ...)
	local list = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		if v == nil or type(v) == "boolean" then
			table.insert(list, tostring(v))
		else
			table.insert(list, v)
		end
	end
	return string.oriformat(s, unpack(list))
end

function string.startswith(s, starts)
	if #starts > #s then
		return false
	end
	for i = 1, #starts do
		if string.byte(s, i) ~= string.byte(starts, i) then
			return false
		end
	end
	return true
end

function string.endswith(s, ends)
	local lenS = #s
	local lenEnds = #ends
	if lenEnds > lenS then
		return false
	end
	local offset = lenS - lenEnds
	for i = 1, lenEnds do
		if string.byte(s, offset+i) ~= string.byte(ends, i) then
			return false
		end
	end
	return true
end

--非正则替换
function string.replace(s, pat, repl, n)
	local list = {"(", ")", ".", "%", "+", "-", "*", "?", "[", "^", "$"}
	for k, v in ipairs(list) do
		pat = string.gsub(pat, "%"..v, "%%"..v)
	end
	return string.gsub(s, pat, repl, n)
end

--获取UTF8字符串长度
--@param str 目标字符串
--@return cnt 字符长度
function string.utfStrlen(str)
	local len = #str
	local left = len 
	local cnt = 0
	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local temp = string.byte(str, -left)
		local i = #arr
		while arr[i] do
			if temp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

--判断是否存在非法字符
--@param s 目标字符串
--@return bool
function string.isIllegal(s)  
	local len = #s
	local count = 0
	for k = 1, len do  
		local c = string.byte(s,k)  
		if not c then break end  
		if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
			count = count + 1
		elseif c>=228 and c<=233 then  
			local c1 = string.byte(s,k+1)  
			local c2 = string.byte(s,k+2)  
			if c1 and c2 then  
				local a1,a2,a3,a4 = 128,191,128,191  
				if c == 228 then a1 = 184  
				elseif c == 233 then 
					a2,a4 = 190,c1 ~= 190 and 191 or 165  
				end  
				if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then  
					k = k + 2
					count = count + 3
				end  
			end  
		end  
	end
	if count ~= len then --存在不是中文,字母,数字 字符	
		return false
	end
	return true
end
--string.eval("a+b", {a=1, b=2})
function string.eval(s, t)
	local f = loadstring(string.format("do return %s end", s))
	setfenv(f, t)
	return f()
end

--转换函数 超过10 0000   显示 10万
function string.numberConvert(number)
	local str = ""
	number = tonumber(number)
	if number >= 100000 then
		number = number / 10000
		number = math.ceil(number)
		str = string.format("%d万", number)
	else
		str = tostring(number)
	end		
	return str
end

--阿拉伯数字转中文
function string.number2text(n, isbig)
	local t = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "零"}
	local bigt = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "零"}
	if isbig then
		return (bigt[n] or "")
	else
		return (t[n] or "")
	end
end

function string.getutftable(str)
	local t = {}
	for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
		t[#t+1] = uchar
	end
	return t
end

--获取固定长度字符串，超出长度都用……替代
function string.gettitle(str, size, sPattern)
	local sPattern = sPattern or "……"
	local t = string.getutftable(str)
	local result = {}
	local cnt = 0
	for k, v in pairs(t) do
		if string.byte(v) > 0xc0 then
			cnt = cnt + 2
		else
			cnt = cnt + 1
		end
		if cnt <= size then
			table.insert(result, v)
		else
			table.insert(result, sPattern)
			break
		end
	end
	return table.concat(result, "")
end

function string.findstr(str, starget)
	local amountstr = string.len(str)
	local amounttarget = string.len(starget)
	if amounttarget > amountstr then
		return false
	end
	for i = 1, amountstr do
		local flag = true
		for j = 1, amounttarget do
			if string.sub(str, i-1+j, i-1+j) ~= string.sub(starget, j, j) then
				flag = false
			end
		end
		if flag then
			return i
		end
	end
end

function string.getstringdark(str)
	str = tostring(str) or ""
	if str ~= "" then
		str = string.gsub(str, "#%a", data.colordata.COLORINDARK)
	end
	return str
end

function string.IsNilOrEmpty(str)
	return (str == nil) or (str == "")
end