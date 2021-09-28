local function to_heighter(num)
	return math.floor(num / 4)
end
local function to_lower(num)
	return num - to_heighter(num) * 4
end
local function chinese_code(str)
	if str == "" then 
		return ""
	end
	local data = {}
	for i = 1, 4 do
		data[i] = tonumber("0x"..string.sub(str, i, i), 10)
	end
	return string.char(0xe0 + data[1], 0x80 + data[2] * 4 + to_heighter(data[3]), 0x80 + to_lower(data[3]) * 16 + data[4])
end

--[[转换Unicode为utf8对应字符，json那边用到
	 log(unicode2utf8("\\u6d4b\\u8bd52\\u533a"))
--]]
function unicode2utf8(str)
	local utf_8_str = ""
	local i = 1
	while i <= string.len(str) do
		local letter = string.sub(str, i, i)
		if letter == "\\" and string.sub(str, i+1, i+1) == "u" then
			-- 找到中文了
			utf_8_str = utf_8_str .. chinese_code(string.sub(str, i+2, i+5))
			i = i + 6
		else 
			utf_8_str = utf_8_str .. letter
			i = i + 1
		end
	end
	return utf_8_str
end

--拆分成字符
function splitStr(str)
	local list = {}
	local len = string.len(str)
	local i, j = 1, 1 
	while i <= len do
		local c = string.byte(str, i)
		if c > 0 and c <= 127 then  --英文数字字母
			j = 1
		elseif (c >= 192 and c <= 223) then
			j = 2
		elseif (c >= 224 and c <= 239) then
			j = 3
		elseif (c >= 240 and c <= 247) then
			j = 4
		end
		local char = string.sub(str, i, i+j-1)
		i = i + j
		table.insert(list, {char=char, type=j})
	end
	return list, len
end

-- 以某个分隔符为标准，分割字符串
-- @param split_string 需要分割的字符串
-- @param splitter 分隔符
-- @return 用分隔符分隔好的table
function splitByFormat(split_string, splitter)
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


--数字转换成小写中文
function numToCN(value)
	local num_cn = {"零","一","二","三","四","五","六","七","八","九","十"}
	local num_cn_std = {"零","十","百","千","万","亿"}
	local array = splitStr(value)
	local length = #array
	local flag = false
	local str = ""
	local len = 0
	if length > 13 then
		log("只支持13位数字")
		return
	end
	for k, v in pairs(array) do
		if v.char == "0" and length > 1 then
			flag = true
		else
			if flag then
				flag = false
				str = str..num_cn_std[1]
			end
			str = str..num_cn[tonumber(v.char)+1]
			len = length - k
			if len == 9 then
				str = str..num_cn_std[6]
			elseif len==5 then
				str = str..num_cn_std[len]
			elseif len > 5 then
				str = str..num_cn_std[len-5+1]
			elseif len>=1 then
				str = str..num_cn_std[len+1]
			elseif len==1 then
				str = str..num_cn_std[1+1]
			end
		end
	end
	return str
end

-- 避免使用连接符处理，使用格式操作
function StringFormat(format_text,...)
	local arg = {...}
	local function FormatText(n)
		return tostring(arg[tonumber(n)+1])
	end
	local str=string.gsub(format_text, "{(%d+)}", FormatText)
	return str
end
function StringFormatII(format_text, list)
	local arg = list
	local function FormatText(n)
		return tostring(arg[tonumber(n)+1])
	end
	local str=string.gsub(format_text, "{(%d+)}", FormatText)
	return str
end

--字符串分割函数
--传入字符串和分隔符，返回分割后的table
function StringSplit(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end
	return result
end

--清除所有指定字符
function ClearAllLetter( v, c, r )
	local f= function ( v )
		if r then
			return r
		else
			return ""
		end
	end
	return string.gsub(v, c, f)
end
--[[解析 SdkDelegate 返回的数据 字符串块如下
	"gId=86&subId=149&isNew=0&userId=ssdfs&userName=bbbbb&data={
		ff = 397;
		gg = kaslkdjfas;
	}"
	转为table
]]

local ____eq = "="
local ____eq0 = "@&%%%&@"
local ____eq1 = "@&###&@"
local ____eq2 = "@&%%%&@"
local ____eq3 = "@&$$$&@"
function GetIOSData( param )
	if not param then return nil end
	param = ClearAllLetter(param, "[%s]")
	local content = StringSplit(param, '&')
	if content then
		local data = {}
		for i,v in ipairs(content) do
			if v~="" then
				-- if string.find(v, "[{|}]") then
				-- 	local i,j = string.find(v, ____eq)
				-- 	local n = string.sub(v, 1, i-1)
				-- 	local v = string.sub(v,j+1)
				-- 	data[n] = GetIOSData(ClearAllLetter(ClearAllLetter(v, "[{|}]"), ";", "&"))
				-- else
					-- local tmp = StringSplit(v, '=')
					-- data[tmp[1]] = tmp[2]
					
					local eqa = ____eq0
					local eqb = ____eq2
					if string.find(v, eqa) then
						eqa = ____eq1
					end
					if string.find(v, eqb) then
						eqb = ____eq3
					end
					local tmp = string.gsub( v, ____eq, eqa, 1 )
					tmp = string.gsub( tmp, ____eq, eqb)
					tmp = string.gsub(tmp, eqa, ____eq, 1 )
					tmp = StringSplit(tmp, ____eq)
					local k = tmp[1]
					local vv = tmp[2]
					vv = string.gsub( vv, eqb, ____eq)
					data[k] = vv
				-- end
			end
		end
		return data
	end
	return nil
end

-- 由性别随机生成名字
function getRandomName(sex)
	local nameCfg = require("SKGame/Common/cfg_name")
	-- local hasSign = math.random(0,1)==1 （搭配前后缀，目前没有字集）
	local isDouble = math.random(0,1)==1
	local is2Name = math.random(0,1)==1

	local xing = nameCfg.xing
	local result = xing[math.random(1, #xing)]
	local nan2 = nameCfg.nan2
	local nv2 = nameCfg.nv2
	local nan = nameCfg.nan
	local nv = nameCfg.nv
	if 1==sex then
		if isDouble then
			result = result .. nan2[math.random(1, #nan2)]
		else
			if is2Name then
				result = result .. nan[math.random(1, #nan)].. nan[math.random(1, #nan)]
			else
				result = result .. nan[math.random(1, #nan)]
			end
		end
	else
		if isDouble then
			result = result .. nv2[math.random(1, #nv2)]
		else
			if is2Name then
				result = result .. nv[math.random(1, #nv)].. nv[math.random(1, #nv)]
			else
				result = result .. nv[math.random(1, #nv)]
			end
		end
	end
	-- change 17/08/18 add随机后的名字检测敏感词
	if isExistSensitive(result) then
		return getRandomName(sex)
	else
		return result
	end
end
-- 是否存在敏感字符
function isExistSensitive( content )
	local sensitives = require("SKGame/Common/cfg_sensitive")
	local s=nil
	for i=1,#sensitives do
		s = string.find(content, sensitives[i])
		if s then
			return true
		end
	end
	return false
end
-- 检测敏感字符并进行文明化
function filterSensitive(content)
	local sensitives = require("SKGame/Common/cfg_sensitive")
	for i=1,#sensitives do
		content = string.gsub(content, sensitives[i], "*")
	end
	return content
end

-- content 规则："[[3,0,100,1][1,1201101,1,0]]" 或 "[[3,0,100,1],[1,1201101,1,0]]" 或 "{{3,0,100,1},{1,1201101,1,0}}" 均可
-- 返回 table 或 nil [类型, id, 数量, 绑定]
function StringToTable( content )
	if string.find(content, "%[") then
		content = string.gsub(content, "%[", "{")
	end
	if string.find(content, "%]") then
		content = string.gsub(content, "%]", "}")
	end
	if string.find(content, "}{") then
		content = string.gsub(content, "}{", "},{")
	end
    local result = {}
    local mgr = function ( content )
        result = loadstring("return "..content)()
    end
    if not pcall(mgr, content) then result = {} end
	-- local result = assert(loadstring("return "..content))() --loadstring("return "..content)()
	if type(result) == "table" then
		return result
	end
	return assert(loadstring("return "..result))()
end