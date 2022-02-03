StringUtil = StringUtil or {}


--拆分成字符
function StringUtil.splitStr(str)
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

function StringUtil.getStrLen(str)
    local len = 0
    local off = 0
    local charLen = string.len(str)
    local i, j = 1, 1 
    while i <= charLen do
        local c = string.byte(str, i)
        if c > 0 and c <= 127 then  --英文数字字母
            j = 1
            off = 1
        elseif (c >= 192 and c <= 223) then
            j = 2
            off = 2
        elseif (c >= 224 and c <= 239) then --中文字
            j = 3
            off = 2
        elseif (c >= 240 and c <= 247) then
            j = 4
            off = 2
        end
        i = i + j
        len = len + off
    end
    return len
end

-- 以某个分隔符为标准，分割字符串
-- @param split_string 需要分割的字符串
-- @param splitter 分隔符
-- @return 用分隔符分隔好的table
function StringUtil.splitByFormat(split_string, splitter)
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

-- 超过部分替换字符串
function StringUtil.getChars(content, num, replace_str)
    num = num or 1
    replace_str = replace_str or "..."
    local words = WordCensor:getInstance():stringToChars(content)
    local str
    if #words < num then
        str = content
    else
        local list = {}
        for i=1, num do
            list[i] = words[i]
        end
        table.insert(list, replace_str)
        str = table.concat(list)
    end
    return str
end

-- 表情个数限制
function StringUtil.checkFace(content, num)
    num = num or 5
    local data = WordCensor:getInstance():relapceFaceIconTag(content)
    if data[1] > 5 then
        message("发言中不能超过5个表情")
        return false
    end
    return true
end

util_num_chn = {"零","一","二","三","四","五","六","七","八","九","十"}
util_num_std = {"零","十","百","千","万","亿"}

--数字转换成小写中文
function StringUtil.numToChinese(value)
    value = tonumber(value) or 0
    local array = StringUtil.splitStr(value)
    local length = #array
    local flag = false
    local str = ""
    local len = 0
    if length > 13 then
        print("只支持13位数字")
        return
    end
    for k, v in pairs(array) do
        if v.char == "0" and length > 1 then
            flag = true
        else
            if flag then
                flag = false
                str = str..util_num_std[1]
            end
            str = str..util_num_chn[tonumber(v.char)+1]
            len = length - k
            if len == 9 then
                str = str..util_num_std[6]
            elseif len==5 then
                str = str..util_num_std[len]
            elseif len > 5 then
                str = str..util_num_std[len-5+1]
            elseif len>=1 then
                str = str..util_num_std[len+1]
            elseif len==1 then
                str = str..util_num_std[1+1]
            end
        end
    end
    if value < 20 and value > 9 then
        return string.sub(str, 4)
    else
        return str
    end
end

-- 转换Unicode为utf8对应字符，json那边用到
-- 测试   测试2区
-- print(unicode2utf8("\\u6d4b\\u8bd52\\u533a"))
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

function encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str
 
    while #str > 0 do
        local bytes_num = 0
        local buf = 0
 
        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end
 
        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end
 
        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end

function bin2hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return s
end

local h2b = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["B"] = 11,
    ["C"] = 12,
    ["D"] = 13,
    ["E"] = 14,
    ["F"] = 15
}

function hex2bin( hexstr )
    local s = string.gsub(hexstr, "(.)(.)", function ( h, l )
         return string.char(h2b[h]*16+h2b[l])
    end)
    return s
end

-- 二进制转字符串
-- 传文件的时候避免出现\0的时候使用
function bin2str(s)
    s=string.gsub(s,"(.)", function (x) 
        if x > '\253' then
            return '\1' .. x
        else 
            return string.char(string.byte(x) + 2)
        end
    end)
    return s
end

-- 上述字符串转回二进制
function str2bin( hexstr )
    local str = {}
    local len = string.len(hexstr)
    local i = 1
    local n = 1
    while i <= len do 
        if string.byte(hexstr, i) == 1 then
            str[n] = string.char(string.byte(hexstr, i+1))
            i = i + 2
        else
            str[n] = string.char(string.byte(hexstr, i) - 2)
            i = i + 1
        end
        n = n + 1
    end
    return table.concat(str)
end

-- 数字转成中文表达
function str4num( num )
    if num == nil or num == 0 then
        return "无"
    elseif num == 999 then
        return "不限"
    else
        return num
    end
end


--返回当前字符实际占用的字符数
local function SubStringGetByteCount(str, index)
	local curByte = string.byte(str, index)
	local byteCount = 1;
	if curByte == nil then
		byteCount = 0
	elseif curByte > 0 and curByte <= 127 then
		byteCount = 1
	elseif curByte >= 192 and curByte <= 223 then
		byteCount = 2
	elseif curByte >= 224 and curByte <= 239 then
		byteCount = 3
	elseif curByte >= 240 and curByte <= 247 then
		byteCount = 4
	end
	return byteCount;
end 


--获取中英混合UTF8字符串的真实字符数量
local function SubStringGetTotalIndex(str)
	local curIndex = 0;
	local i = 1;
	local lastCount = 1;
	repeat
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount;
		curIndex = curIndex + 1;
	until(lastCount == 0);
	return curIndex - 1;
end

--获取字符串的真实索引值
local function SubStringGetTrueIndex(str, index)
	local curIndex = 0;
	local i = 1;
	local lastCount = 1;
	repeat
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount;
		curIndex = curIndex + 1;
	until(curIndex >= index);
	return i - lastCount;
end

--获取中英混合UTF8字符串的真实字符数量
function StringUtil.SubStringGetTotalIndex(str)
    return SubStringGetTotalIndex(str)
end

--截取中英混合的UTF8字符串，endIndex可缺省
function StringUtil.SubStringUTF8(str, startIndex, endIndex)
	if startIndex < 0 then
		startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
	end
	
	if endIndex ~= nil and endIndex < 0 then
		endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
	end
	
	if endIndex == nil then
		return string.sub(str, SubStringGetTrueIndex(str, startIndex));
	else
		return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
	end
end

-- 逐个字的显示字符串
function StringUtil.ShowTextOneByOne( txt_node, str )
    if not txt_node or tolua.isnull(txt_node) then return end
    local charLen = StringUtil.SubStringGetTotalIndex(str)
    for i=1,charLen do
        delayRun(txt_node, i*0.08, function (  )
            local cur_str = StringUtil.SubStringUTF8(str, 1, i)
            if cur_str then
                txt_node:setString(cur_str)
            else
                txt_node:setString(str)
                doStopAllActions(txt_node)
            end
        end)
    end
end