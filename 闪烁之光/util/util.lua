-- 唯一Id
auto_id = auto_id or 0
function autoId()
    auto_id = auto_id + 1
    return auto_id
end

-- 打印table
function printLuaTable (lua_table, indent)
    indent = indent or 0
    for k, v in pairs(lua_table) do
        local szSuffix = ""
        TypeV = type(v)
        if TypeV == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep(" ", indent)
        formatting = szPrefix..k.." = "..szSuffix
        if TypeV == "table" then
            print(formatting)
            printLuaTable(v, indent + 1)
            print(szPrefix.."},")
        else
            local szValue = ""
            if TypeV == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting..szValue..",")
        end
    end
end

function luaTable2Str(str, lua_table, indent)
    indent = indent or 0
    str = str or ""
    for k, v in pairs(lua_table) do
        local szSuffix = ""
        TypeV = type(v)
        if TypeV == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep(" ", indent)
        formatting = szPrefix..k.." = "..szSuffix
        if TypeV == "table" then
            str = str..formatting.."\n"
            str = luaTable2Str(str, v, indent + 1)
            str = str .. szPrefix.."}\n"
        else
            local szValue = ""
            if TypeV == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            str = str .. formatting..szValue.."\n"
        end
    end
    return str
end

-- 弧度转换角度
function radianToDegree(radian)
    return radian * 57.29577951
end

--==============================--
--desc:计算两点的角度,用于做图片翻转
--time:2017-11-09 02:13:43
--@p1:
--@p2:
--@return 
--==============================--
function getAngleByPos(p1,p2)  
    local p = {}  
    p.x = p2.x - p1.x  
    p.y = p2.y - p1.y  
    local r = math.atan2(p.y,p.x)*180/math.pi
    return r  
end 

--==============================--
--desc:根据起始坐标,角度和距离,计算目标点
--time:2017-11-09 02:25:07
--@a:起始点
--@l:距离
--@r:角度--需要转换成弧度
--@return 
--==============================--
function getPosByAngleAndDis(a, l, r)
    local angle = math.pi / 180 * r
    local x = a.x + l * math.cos( angle )
    local y = a.y + l * math.sin( angle )
    return x, y
end

-- 打印调用文件和行数
function printParent(lev)
    lev = lev or 2
    local track_info = debug.getinfo(lev, "Sln")
    local parent = string.match(track_info.short_src, '[^"]+.lua')     -- 之前调用的文件
    print(string.format("From %s:%d in function `%s`",parent or "nil",track_info.currentline,track_info.name or ""))
end

__hoop_file = ""

function hoop(...)
    -- printParent(3)
    __hoop_table = __hoop_table or {}
    local track_info = debug.getinfo(3, "Sln")
    -- local track_info2 = debug.getinfo(4, "Sln")
    if not track_info or not track_info.name then return end
    -- if string.find(track_info.name, "update") ~= nil or track_info.name == '' then return end
    -- if track_info2 and track_info2.short_src and string.find(track_info2.short_src, "time_ticket") ~= nil then return end
    -- local parent = string.match(track_info.short_src, '[^"]+.lua')     -- 之前调用的文件
    local parent = string.match(track_info.short_src, string.format('[^"]+.lua', __hoop_file))     -- 之前调用的文件
    if parent then
        -- __hoop_table[parent] = (__hoop_table[parent] or 0) + ((parent == __hoop_last) and 1 or 0)
        -- __hoop_last = parent
        -- if __hoop_table[parent] < 100 then 
            print(string.format("From %s:%d in function `%s`",parent or "nil",track_info.currentline,track_info.name or ""))
        -- end
    end
end

-- 所有父调用
function whoisyourdaddy()  
    local ret = ""  
    local level = 2  
    ret = ret .. "your daddy is:\n"  
    while true do  
        local info = debug.getinfo(level, "Sln")  
        if not info then break end  
        if info.what == "C" then                -- C function  
            ret = ret .. "    " .. tostring(level) .. "C function\n"  
        else           -- Lua function  
            local parent = string.match(info.short_src, '[^"]+.lua')     -- 之前调用的文件
            ret = ret .. string.format("    %s:%d in function `%s`\n", parent, info.currentline, info.name or "")  
        end  
        level = level + 1
    end  
    print(ret)  
end  

function writeLog(file, some)
    Type = type(some)
    if Type == "table" then
        write_lua_table(file, some, 0)
    else 
        file:write(some)
    end
end

-- 把table写成文件
function writeLuaTable (file, lua_table, indent)
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        TypeV = type(v)
        if TypeV == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep(" ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if TypeV == "table" then
            file:write("[Trace] " .. formatting.."\n")
            write_lua_table(file, v, indent + 1)
            file:write("[Trace] "..szPrefix.."},\n")
        else
            local szValue = ""
            if TypeV == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            file:write("[Trace] " .. formatting..szValue..",\n")
        end
    end
end

-- 按照某个位置的值找数据
-- 返回 false | data()
function keyfind(key, val, list)
    for _, v in pairs(list) do 
        if v[key] == val then 
            return v 
        end
    end
    return false
end

-- 按键位删除
function keydelete(key, val, list)
    for k, v in pairs(list) do 
        if v[key] == val then 
            table.remove(list, k)
            return v
        end
    end
    return false
end

-- 按键值替换
function keyreplace(key, val, list, new)
    for k, v in pairs(list) do 
        if v[key] == val then 
            list[k] = new
            return true
        end
    end
    return false
end

-- 统计table长度
function tableLen(table)
    local len = 0
    if table then
        for _ in pairs(table) do
            len = len + 1
        end
    end
    return len
end

-- 从远程对象赋值给本地vo
function setVoFromRemote(list,remoteList)
    for k, _ in pairs(remoteList) do
        if remoteList[k] ~= nil then
            list[k] = remoteList[k]
        end
    end
end
-- 拷贝table 不能直接用=来复制，否则会一起改变
function deepCopy(object)
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
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- 获取整数部分
function getIntPart(x)
local temp = math.ceil(x)
    if temp == x then
        return temp
    else
        return temp - 1
    end
end

-- 获取小数部分
function getFloatPart(x)
    return x - getIntPart(x)
end

--[[获取小数保留n位的四舍五入
-- @param number 小数
-- @param n 保留位
-- ]]
function getRoundForNLocation(number, n)
    return (math.floor(math.pow(10, n)*number + 0.5))/(math.pow(10, n))
end

function cutBaseClass(data_list)
    if type(data_list) ~= "table" then return data_list end
    local new_data_list = {}
    for k, v in pairs(data_list) do 
        if k ~= "DeleteMe" and k ~= "_class_type" then 
            if type(v) == "table" then 
                new_data_list[k] = cutBaseClass(v)
            else 
                new_data_list[k] = v
            end
        end
    end
    return new_data_list
end

-- 四舍五入
function mathRound( num )
   return math.floor(num + 0.5)
end

-- 整形转rgb
function int2rgb(num)
    local r,g,b,a
    a = num % 256
    num = (num - a) / 256
    b = num % 256
    num = (num - b) / 256
    g = num % 256
    num = (num - g) / 256
    r = num
    return r, g, b
end

-- 判断文件是否存在，不存在抛出异常
_file_exist_list = _file_exist_list or {}
function isFileExist(path)
    if type(path) ~= "string" then return false end
    if _file_exist_list[path] ~= nil then
         return _file_exist_list[path]
    else
         local bool = cc.FileUtils:getInstance():isFileExist(path)
         _file_exist_list[path] = bool
         return bool
    end
end

-- 打印局部变量 调试用
function tracebackex(max_lev)  
    max_lev = max_lev or 5
    local ret = ""  
    local level = 2  
    ret = ret .. "stack traceback:\n"  
    while true do  
       --get stack info  
        local info = debug.getinfo(level, "Sln")  
        if not info then break end  
        if info.what == "C" then                -- C function  
             ret = ret .. tostring(level) .. "\tC function\n"  
        else           -- Lua function  
             ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "")  
        end  
        --get local vars  
        local i = 1  
        while true do  
            local name, value = debug.getlocal(level, i)  
            if not name then break end  
            ret = ret .. "\t\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"  
            i = i + 1  
        end    
        level = level + 1  
        if level > max_lev then       -- 不想打印太多层之后的，没多少用 
            break
        end
    end  
    print(ret)  
end  
      
function tostringex(v, len)  
    if len == nil then len = 0 end  
    local pre = string.rep('\t', len)  
    local ret = ""  
    if type(v) == "table" then  
       if len > 5 then return "\t{ ... }" end  
       local t = ""  
       for k, v1 in pairs(v) do  
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

-- 提示格式化 用于提取语言
function tipsFormat(...) 
    return string.format(...) 
end

--颜色值转换 "abcedf"
function color( value )
    local r,g,b,a = "ff", "ff", "ff", "ff"
    r = string.sub(value,1,2)
    g = string.sub(value,3,4)
    b = string.sub(value,5,6)
    a = string.sub(value,7,8)
    if r=="" then
        r = "ff"
    end
    if g=="" then
        g = "ff"
    end
    if b=="" then
        b = "ff"
    end
    if a=="" then
        a = "ff"
    end
    return cc.c4b(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b), tonumber("0x"..a))
end


--value  cc.c3b
function c3bToStr(value)
    if not value then return "#ffffff" end
    local r = string.format("%x",value.r)
    local g = string.format("%x",value.g)
    local b = string.format("%x",value.b)

    r = #r < 2 and "0"..r or r
    g = #g < 2 and "0"..g or g
    b = #b < 2 and "0"..b or b
    return "#" .. r.. g.. b
end
-- **** 老的util **** -- 
-- 避免使用连接符处理，使用格式操作
function StringFormat(format_text,...)
    local arg = {...}
    local function FormatText(n)
        return tostring(arg[tonumber(n)+1])
    end
    local str=string.gsub(format_text, "{(%d+)}",FormatText)
    return str
end

function Split(split_string, splitter)
    -- 以某个分隔符为标准，分割字符串
    -- @param split_string 需要分割的字符串
    -- @param splitter 分隔符
    -- @return 用分隔符分隔好的table

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

function Join(join_table, joiner)
    -- 以某个连接符为标准，返回一个table所有字段连接结果
    -- @param join_table 连接table
    -- @param joiner 连接符
    -- @param return 用连接符连接后的字符串

    if #join_table == 0 then
        return ""
    end

    local fmt = "%s"
    for i = 2, #join_table do
        fmt = fmt .. joiner .. "%s"
    end

    return string.format(fmt, unpack(join_table))
end

function Printf(fmt, ...)
    -- 格式化输出字符串，类似c函数printf风格

    print(string.format(fmt, ...))
end

function DeepCopy(object)
    -- @param object 需要深拷贝的对象
    -- @return 深拷贝完成的对象

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

        return setmetatable(new_table, getmetatable(object))
    end

    return _copy(object)
end

function SwitchFuncs(t)
    t.Case = function (self, x)
        return self[x] or self.default
    end

    return t
end

function ToBoolean(s)
    -- 将字符串转换为boolean值

    local transform_map = {
        ["true"] = true,
        ["false"] = false,
    }

    return transform_map[s]
end

function TabToStr( tab, flag )
    local result = ""
    result = string.format( "%s{", result )

    local filter = function( str )
        str = string.gsub( str, "%[", " " )
        str = string.gsub( str, "%]", " " )
        str = string.gsub( str, "\"", " " )
        str = string.gsub( str, "%'", " " )
        str = string.gsub( str, "\\", " " )
        str = string.gsub( str, "%%", " " )
        return str
    end

    for k,v in pairs(tab) do
        if type(k) == "number" then
            if type(v) == "table" then
                result = string.format( "%s[%d]=%s,", result, k, TabToStr( v ) )
            elseif type(v) == "number" then
                result = string.format( "%s[%d]=%d,", result, k, v )
            elseif type(v) == "string" then
                result = string.format( "%s[%d]=%q,", result, k, v )
            elseif type(v) == "boolean" then
                result = string.format( "%s[%d]=%s,", result, k, tostring(v) )
            else
                if flag then
                    result = string.format( "%s[%d]=%q,", result, k, type(v) )
                else
                    error("the type of value is a function or userdata")
                end
            end
        else
            if type(v) == "table" then
                result = string.format( "%s%s=%s,", result, k, TabToStr( v, flag ) )
            elseif type(v) == "number" then
                result = string.format( "%s%s=%d,", result, k, v )
            elseif type(v) == "string" then
                result = string.format( "%s%s=%q,", result, k, v )
            elseif type(v) == "boolean" then
                result = string.format( "%s%s=%s,", result, k, tostring(v) )
            else
                if flag then
                    result = string.format( "%s[%s]=%q,", result, k, type(v) )
                else
                    error("the type of value is a function or userdata")
                end
            end
        end
    end
    result = string.format( "%s}", result )
    return result
end

function Serialize( tab, level, strStart, strEnd )
    local rep = string.rep
    strStart = strStart or "\""
    strEnd = strEnd or "\""
    level = level or 0

    local str = "\n" .. rep( "\t", level ) .. "{\n"
    for k,v in pairs(tab) do
        local kIsStr = 0
        if type(k) == "string" then
            kIsStr = 1
        end
        if type(v) == "table" then
            str = str .. rep( "\t", level+1 ) .. "[" .. rep( strStart, kIsStr ) .. k .. rep( strEnd, kIsStr ) .. "]" .. " = " .. Serialize( v, level+1 ) .. "\n"
        else
            local vIsStr = 0
            if type(v) == "string" then
                vIsStr = 1
            end
            str = str .. rep( "\t", level+1 ) .. "[" .. rep( strStart, kIsStr ) .. k .. rep( strEnd, kIsStr ) .. "]" .. " = "..rep( strStart, vIsStr ) .. v .. rep( strEnd, vIsStr ) .. ",\n"
        end
    end
    str = str .. rep( "\t", level ) .. "},"
    return str
end

-- 获取 继承自 cocos2dx-lua中class 构造的类对象或原生引擎中的类对象中的类型名字
function getCCName( cc_obj )
    if type(cc_obj) == "userdata" then -- 获得超类名与当前类名
        return tolua.type(cc_obj), cc_obj.__cname
    else -- 只继承情况下table
        return cc_obj.__cname
    end
end

--[[
@功能:处理包含颜色标记的字符串
@参数:特殊颜色标记处理
@     “对目标造成{10|105%%+2}点伤害”   
@     {} 里面是要替换的内容 , | 分割线  前面是色码 ,后面是实际内容
]]

-- analyzeDesc ( string.format("{s%|S%}啊哈哈哈哈哈哈", "#ffffff", "哈哈哈"), 12, 16, 19)
function analyzeDesc( desc, c, s, c2)
    if desc==nil then return "" end
    local result = desc
    local color = c or 302
    local size = s or 16
    local color2 = c2 or 16
    if string.find(result,"%b{}") == nil then
        result = richtext(result,tranformC3bTostr(color),size)
    else
        while string.find(result,"%b{}") ~= nil do
            local i,j = string.find(result,"%b{}")
            local temp = string.sub(result,i+1,j-1)
            local color_i,color_j = string.find(temp,"|")
            local sss
            if color_i ~= nil and color_j ~= nil then
                local cc = string.sub(temp,1,color_i-1)
                local tt = string.sub(temp,color_j+1,#temp)
                sss = richtext(tt,tranformC3bTostr(tonumber(cc)),size)
            else
                sss = richtext(temp,tranformC3bTostr(color2),size)
            end
            result = string.gsub(result, "%b{}", sss,1)
        end
    end
    return richtext(result,tranformC3bTostr(color),size)
end

function richtext(msg,color,size)
    local m = msg or ""
    m = string.gsub(m, "\\n", "\n")
    local c = color or tranformC3bTostr(10)
    local s = size or 26
    local text = string.format("<div fontsize=%s fontcolor=%s>%s</div>",s,c,m)
    return text
end

-- 读二进制文件
function readBinaryFile( path )
    if not cc.FileUtils:getInstance():isFileExist(path) then return "" end
    local f = assert(io.open(path, 'rb'))
    local string = f:read("*all")
   -- local len = assert(f:seek("end"))
    f:close()
    return string

end

-- 写二进制文件
function writeBinaryFile( path, str)
    local f = assert(io.open(path, 'wb'))
    f:write(str)
    f:close()
end

function copyFileTo(base_path, to_path)
    if not cc.FileUtils:getInstance():isFileExist(to_path) and cc.FileUtils:getInstance():isFileExist(base_path) then
        local f = assert(io.open(base_path, 'rb'))
        local str = f:read("*all")
       -- local len = assert(f:seek("end"))
        f:close()
        f = assert(io.open(to_path, 'wb'))
        f:write(str)
        f:close()
        return true
    end
    return false
end

--[[
    获取通用的key
]]
function getNorKey(...)
    local params = {...}
    local len = #params
    local key = ""
    for i=1,len do
        if key ~= "" then
            key = key.."_"
        end
        key = key..params[i]
    end
    return key
end

-- 获取服务器ID dev_1 return 1
function serverId(srv_id)
	if srv_id and string.find(srv_id, '_') then
		return string.sub(srv_id, string.find(srv_id, '_') + 1, string.len(srv_id))
	else
		return 0
	end
end
