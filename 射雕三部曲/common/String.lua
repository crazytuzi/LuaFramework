--[[
    文件名：String.lua
	描述：string 类型扩展函数（其他扩展函数可以参考 cocos2d.functions.lua 中相关部分）
	创建人：liaoyuangang
	创建时间：2016.3.30
-- ]]

-- 解析符号分割的字符串到表中
--[[
-- 参数
    srcStr: 源字符串，如：AAAA||BBBB||CCCC||DDDD
    separator：分隔符， 如：||
-- 返回值，如上面到字符串解析为：
    第一个返回值为：
        {
            AAAA,
            BBBB,
            CCCC,
            DDDD
         }
    第二个返回值为：
        {
            ||,
            ||, 
            ||
        }
 ]]
function string.splitBySep(srcStr, separator)
    local ret, sepArray = {}, {}
    if not srcStr or not separator then
        return ret
    end
    while string.len(srcStr) > 0 do
        local i, j = string.find(srcStr, separator)
        if (not i) then
            ret[#ret + 1] = srcStr
            break
        end
        if (i > 1) then
            ret[#ret + 1] = string.sub(srcStr, 1, i - 1)
            table.insert(sepArray, string.sub(srcStr, i, j))
        end
        if (string.len(srcStr) <= j) then
            srcStr = ""
        else
            srcStr = string.sub(srcStr, j + 1, string.len(srcStr))
        end
    end

    return ret, sepArray
end

-- 货币格式化
-- 格式化为： "1,000","1,000,000" 格式字符串
function string.toThousand(num)
    local formatted = tostring(tonumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--- 判断字符串是不是图片文件名
--[[
参数:
	srcStr： 需要判断的字符串
返回值:
	第1个返回值：如果是返回true，否则返回false
	第2个返回值：如果是图片文件名，返回图片名的后缀
]]
function string.isImageFile(srcStr)
    if (not srcStr or string.len(srcStr) <= 4) then
        return false
    end
    local tempStr = string.lower(string.sub(srcStr, -4))
    return tempStr == ".png" or tempStr == ".jpg", tempStr
end

-- 字符串BASE64并URL标准化
-- @str:源字符串
function string.tourl(str)
    local codeStr = crypto.encodeBase64(str)
    -- URL标准化转换
    local function urlencodeChar(char)
        local byteC = string.byte(char)
        if byteC and byteC>0 then
            return "%" .. string.format("%02X", byteC)
        end
    end
    function urlencode(str)
        -- convert line endings
        str = string.gsub(tostring(str), "\n", "\r\n")
        -- escape all characters but alphanumeric, '.' and '-'
        str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
        -- convert spaces to "+" symbols
        return string.gsub(str, " ", "+")
    end
    codeStr = urlencode(codeStr)
    return codeStr
end

--- 格式化动态变化的字符串
--[[
-- 参数:
	@formatStr: 动态的 formatstring
	@valTable: 可变参数列表
-- 返回值
	格式化后的字符串
]]
function string.dynamicFormat(formatStr, valTable)
    local tempTable = {}
    table.insert(tempTable, "return string.format(")
    table.insert(tempTable, "'" .. formatStr .. "'")
    for i = 1, #valTable do
        local tempStr = ""
        if (type(valTable[i]) == "string") then
            tempStr = "'" .. valTable[i] .. "'"
        else
            tempStr = tostring(valTable[i])
        end
        table.insert(tempTable, ", " .. tempStr)
    end
    table.insert(tempTable, ")")
    local tempStr = table.concat(tempTable)
    local fun = loadstring(tempStr)
    return fun()
end

-- 字符串是否为邮件格式
function string.isEmail(email)
    return #email > 0 and email:match "^[%w+%.%-_]+@[%w+%.%-_]+%.%a%a+$"
end

-- 源字符串是否为移动电话格式
function string.isCellular(phone)
    return #phone > 0 and phone:match "^[1-9]%d%d%d%d%d%d%d%d%d%d$"
end

--验证字符串是否合法，不能包含空格、百分号、引号、控制符
function string.isValided(text)
    return #text > 0 and not text:match "[ %c%%\'\"]+"
end

--- 浮点数转化为字符串（如果是整数则不显示小数点，如果不是整数，则显示小数点后一位）
function string.floatToStr(floatNum)
    if not floatNum then
        return ""
    end

    local precision = 0.000001
    local tempNum = math.floor(floatNum + precision)
    if floatNum > tempNum + precision or floatNum < tempNum - precision then
        return string.format("%.1f", floatNum)
    else
        return string.format("%d", floatNum)
    end
end

--- 求字符串的 md5 值
function string.md5Content(srcStr)
    srcStr = md5Core.sum(srcStr)
    return (string.gsub(srcStr, ".", function (c)
        return string.format("%02x", string.byte(c))
    end))
end

-- 颜色转化为字符串标识 c3b(0x00, 0x00, 0x00) ===> #000000
function string.c3bToStr(c3bColor)
    if not c3bColor then
        return ""
    end
    return string.format("#%02x%02x%02x", c3bColor.r or 0, c3bColor.g or 0, c3bColor.b or 0)
end

-- 6位字符串颜色转成cocos color
function string.strToColor(text)
    local ret = cc.c3b(0xFF, 0xFF, 0xFF)
    if string.len(text) >= 6 then
        ret.r = tonumber(string.sub(text, 1, 2), 16)
        ret.g = tonumber(string.sub(text, 3, 4), 16)
        ret.b = tonumber(string.sub(text, 5, 6), 16)
    end
    return ret
end

--- 获取文件路径的文件名部分
--[[
-- 参数
    filename: 文件名，可能包含路径，可能没有包含文件名
-- 返回值
    第一个返回值：返回nil表示不含文件名，否则为只有文件名的字符串
    第一个返回值：true表示只有文件名，否则表示没有文件名或包含了路径
]]
function string.onlyFilename(filename)
    filename = filename or ""
    local srcLen = string.len(filename)

    local retFile = nil
    while string.len(filename) > 0  do
        local beginPos, endPos = filename:find("[^/\n\\:%*%?\"<>|]+%.[%w]+")
        if not beginPos then
            break
        end
        retFile = string.sub(filename, beginPos, endPos) 

        if (string.len(filename) <= endPos) then
            filename = ""
        else
            filename = string.sub(filename, beginPos + 1, string.len(filename))
        end
    end
    local onlyName = retFile and string.len(retFile) == srcLen or false

    return retFile, onlyName
end

-- 获取字符串占用ascii字符位置的个数
function string.asciilen(str)
    local barrier  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local size = #barrier
    local count, delta = 0, 0
    local c, i, j = 0, #str, 0

    while i > 0 do
        delta, j, c = 1, size, string.byte(str, -i)
        while barrier[j] do
            if c >= barrier[j] then i = i - j; break end
            j = j - 1
        end
        delta = j == 1 and 1 or 2
        count = count + delta
    end
    return count
end

