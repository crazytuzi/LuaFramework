function NumberGetString(v)
	if v == nil or v == "" then
		return 0
	end
	-- if v / 1000000000 >1 then  
	-- 	v = v / 100000000
	-- 	return string.format("%.2f", v).."亿"
	-- elseif v / 100000 > 1 then  
	-- 	v = v / 10000
	-- 	return string.format("%.0f", v).."万"
	-- else  
	-- 	return v  
	-- end

	if v / 100000 >= 1 then
		v = v / 10000
		return string.format("%.0f" , v) .."万"
	else
		return v
	end
end

--大于等于万，后面加“万”
function NumberGetString3(v)
	if v == nil or v == "" then
		return 0
	end
	v = tonumber(v)
	if v / 10000 >= 1 then
		v = v / 10000
		return string.format("%.0f" , v) .. "万"
	else
		return v
	end
end

--价钱里面加上逗号
function NumberFormat(v)
	local sign = ""
	if v < 0 then
		sign = "-"
		v = v * (-1)
	end
	if v < 1000 then
		return tostring(v)
	end
	local arr = NumberSplit(tostring(v),"")
	local n = table.getn(arr)
	local i = n%3
	if i == 0 then
		i = 4
	else
		i = i + 1
	end
	while i < n do
		table.insert(arr,i,",")
		i = i + 4
		n = n + 1
	end
	return sign .. NumberJoin(arr,"")
end

--带有逗号的数字字符串
--@params: v：数据
--	isNeedGe:是否需要显示个位数
function NumberGetString2(v ,isNeedGe)
	if v == nil then
		return 0
	end
	if v < 10000 then
		return NumberFormat(v)
	elseif v < 100000000 then
		if v < 1000000 then
			return  NumberFormat(v)
		else
			local oldV = v
			v = math.modf(v * 0.0001)
			if (oldV - v * 10000) > 0 then
				return NumberFormat(v) .. "万" .. (oldV - v * 10000)
			else
				return NumberFormat(v) .. "万"
			end
			
		end
	else
		local oldV = v
		local WV = math.modf(v * 0.0001)
		v = math.modf(v * 0.00000001)
		--return NumberFormat(v) .. "亿" .. NumberFormat(WV - v * 10000) .. "万" .. NumberFormat(oldV - WV * 10000)
		local isNeedShowWV = false
		local isNeedShowGe = false
		if (WV - v * 10000) > 0 then
			isNeedShowWV = true
		end

		if (oldV - WV * 10000) > 0 then
			isNeedShowGe = true
		end

		
		if isNeedShowWV == true and isNeedShowGe == true then
			if isNeedGe == true then
				return v .. "亿" .. (WV - v * 10000) .. "万" .. (oldV - WV * 10000)
			else
				return v .. "亿" .. (WV - v * 10000) .. "万"
			end
		end

		if isNeedShowWV == false and isNeedShowGe == false then
			return v .. "亿"
		end

		if isNeedShowWV == true and isNeedShowGe == false then
			return v .. "亿" .. (WV - v * 10000) .. "万"
		end

		if isNeedShowWV == false and isNeedShowGe == true then
			if isNeedShowGe == true then
				return v .. "亿" .. (oldV - WV * 10000)
			else
				return v .. "亿"	
			end
		end
		
	end
	return v
end

function NumberSplit(source_str,split_str)
	if string.len(split_str) == 0 then
		local arr = {}
		for i = 1, string.len(source_str) do
			table.insert(arr,string.sub(source_str, i, i))
		end
		return arr
	else
		return Split(source_str,split_str)
	end
end
function Split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if (delimiter=='') then return false end
	local pos,arr = 0, {}
	-- for each divider found
	for st,sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

function NumberJoin(source_table, split_str)
	if string.len(split_str) == 0 then
		local fmt = "%s"
		for i = 2, table.getn(source_table) do
			fmt = fmt .. split_str .. "%s"
		end
		return string.format(fmt, unpack(source_table))
	else
		return Join(source_table, split_str)
	end
end

-- 获取整数部分
function NumberGetIntPart(x)
	local temp = math.ceil(x)
	if temp == x then
		return temp
	else
		return temp - 1
	end
end

-- 获取小数部分
function NumberGetFloatPart(x)
	return x - NumberGetIntPart(x)
end
-- 对x数值精确到r位数(默认两位)
function NumberRoundFloat(x, r)
   return tonumber(string.format("%."..(r or 2).."f", x))
end