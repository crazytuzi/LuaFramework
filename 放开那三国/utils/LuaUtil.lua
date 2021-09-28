
-- Filename：	LuaUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-5-17
-- Purpose：		Lua的通用工具方法
require "script/utils/RecordTime"

---------------------------------------- table 方法 ---------------------------------------
-- added by fang. 2013.07.12
-- 增加一个表硬拷贝函数，把t_data表里的数据拷到t_dest中
-- 目的：确保数据拷贝成功（硬拷贝），防止函数返回指针，在指针引用计数为零时lua变量指向野指针引起异常
-- 建议：不建议使用，理论上是不应该出现这种问题的，由于组内个别成员提出了可能有这种灵异事件，因此写个函数确保，也可以测试。
---         有谁发现确实有这种情况，请告诉我一下。
-- @params, t_data: 数据表，t_dest：目标数据表
-- @return, 调用者可不接收返回值
function table.hcopy(t_data, t_dest)
    if (type(t_dest) ~= "table") then
        print ("Error, t_dest table must be table type.")
        return nil
    end
    local mt = getmetatable(t_data)
    if mt then
        setmetatable(t_dest, mt)
    end
    for k, v in pairs(t_data) do
        if (type(v) == "table") then
            t_dest[k] = {}
            table.hcopy(v, t_dest[k])
        else
            t_dest[k] = v
        end
    end
    return t_dest
end

-- 判断一个table是否为空 是 nil 或者 长度为0 （非table 返回 true）
function table.isEmpty (t_data)
    local isEmpty = false
    if(type(t_data) ~= "table") then
        isEmpty = true
    else
        local length = 0
        for k,v in pairs(t_data) do
            length = length + 1
            break
        end
        if (length == 0) then
            isEmpty = true
        end
    end
    return isEmpty
end

-- 获得所有的key
function table.allKeys ( t_table )
    local tmplTable = {}
    if( not table.isEmpty(t_table)) then
        for k,v in pairs(t_table) do
            
            table.insert(tmplTable, k)
        end
    end

    return tmplTable
end

--得到table中所有元素的个数
-- added by lichengyang on 2013-08-13
function table.count ( t_table )
    if type(t_table) ~= "table" then
        return 0
    end
    local tNum = 0
    for k,v in pairs(t_table) do
        tNum = tNum + 1
    end
    return tNum
end
-- added by fang. 2013.08.20
-- 颠倒一个数组类型的table
function table.reverse (tArray)
    if tArray == nil or #tArray == 0 then
        return {}
    end
    local tArrayReversed = {}
    local nArrCount = #tArray
    for i=1, nArrCount do
        tArrayReversed[i] = tArray[nArrCount-i+1]
    end
    return tArrayReversed
end

--add by lichenyang
--把一个table序列号成一个字符串
function table.serialize(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. table.serialize(k) .. "]=" .. table.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. table.serialize(k) .. "]=" .. table.serialize(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end



--add by lichenyang
--把一个序列化的字符串转换成一个lua table 此方法和table.serialize对应
function table.unserialize(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

--把table p_tb的内容递归的覆盖到p_ta这个表上去的
function table.paste( p_ta, p_tb )
    for k,v in pairs(p_tb) do
        if type(v) == "table" then
            if p_ta[k] == nil then
                p_ta[k] = {}
            end
            table.paste(p_ta[k], v)
        end
        if type(v) ~= "table" then
            p_ta[k] = v
        end
    end
end

--table 相减
function table.sub( t1, t2 )
    local t = {}
    for k1,v1 in pairs(t1) do
        local isHave = false
        for k2,v2 in pairs(t2) do
            if k1 == k2 then
                t[k1] = v1 - v2
                isHave = true
                break
            end
        end
        if isHave == false then
            t[k1] = v1
        end
    end
    return t
end

--table 相加
function table.add( ... )
    local t = {}
    for k,v in pairs({...}) do
       for k1,v1 in pairs(v) do
            if (type(v1) == "table") then
                t[k1] = table.add(t[k1], v1)
            else
                if t[k1] == nil then
                    t[k1] = tonumber(v1) or 0
                else
                    t[k1] = t[k1]+(tonumber(v1) or 0)
                end
            end
       end

    end
    return t
end


function table.dictFromTable( t_table )
    local t_dict = CCDictionary:create()
    for k,v in pairs(t_table) do
        if( type(v) == "table" )then
            table.dictFromTable(v)
        else
            t_dict:setObject(CCString:create(v), tostring(k))
        end
    end

    return t_dict
end

--[[
    @des    : 对数组型排好序的table进行二分查找
    @param  : $ p_table             : 要进行查找的table
    @param  : $ p_value             : 要寻找的值
    @param  : $ p_begin             : 在 p_table 中查找区间的下限，默认为 1
    @param  : $ p_end               : 在 p_table 中查找区间的上限，默认为 #p_table
    @param  : $ p_returnLower       : 是否在没找到的情况下返回最后一个搜索的下标，默认为false
    @param  : $ p_indexFunction     : 可提供的元表操作，默认为在p_table上操作
    @return : 如果找到了值，则返回 p_value 在 p_table 中的下标 
              如果没找到返回 nil
--]]
function table.binarySearch(p_table,p_value,p_returnLower,p_begin,p_end,p_indexFunction)
    local returnLower = p_returnLower or false
    --查找区间的下限
    local lowIndex = tonumber(p_begin) or 1
    --查找区间的上限
    local highIndex = tonumber(p_end) or #p_table
    --如果需要有元表，则创建元表，否则用p_table
    local indexTable = {}
    if p_indexFunction == nil then
        indexTable = p_table
    else
        local mt = {}
        mt.__index = p_indexFunction
        setmetatable(indexTable,mt)
    end
    --检查p_table排列是否是逆序的，如果是，则 isInverted 为 true
    local isInverted = tonumber(indexTable[lowIndex]) > tonumber(indexTable[highIndex]) and true or false
    --进入循环
    while lowIndex <= highIndex do
        --中间下标
        local middleIndex = math.floor((lowIndex + highIndex)*0.5)
        --local middleValue = tonumber(method(middleIndex))
        local middleValue = tonumber(indexTable[middleIndex])

        --如果到元素则返回下标
        if middleValue == p_value then
            return middleIndex
        elseif middleValue > p_value then
            lowIndex = isInverted and middleIndex + 1 or lowIndex
            highIndex = isInverted and highIndex or middleIndex - 1
        else
            highIndex = isInverted and middleIndex - 1 or highIndex
            lowIndex = isInverted and lowIndex or middleIndex + 1
        end
    end
    
    --[[
        returnLower 为在p_table中比p_value小的那个值的下标
        如果p_value小于顺序排列p_table的p_begin元素，则返回 p_begin - 1
        如果p_value小于逆序排列p_table的p_end元素，则返回 p_end + 1
    --]]                                     
    if returnLower == true then
        return isInverted and highIndex + 1 or lowIndex - 1
    else
        return nil
    end
end

--[[
    @des    :连接table，因为个人需要，所以只限数组形式的table
    @param  :一个table，里面放的是要合并的table   
    @return :连接后的table
--]]
function table.connect(p_connectTable)
    local tempTable = {}
    for i=1,#p_connectTable do
        for j = 1,#p_connectTable[i] do
            table.insert(tempTable,p_connectTable[i][j])
        end
    end
    return tempTable
end

-----------------------------------string 类方法增加-----------------------------

-- 按split_char分割字符串str
-- added by fang. 2013.07.17
function string.split(str, split_char)
-- 以下3行代码做数据校检（在底端设备上尽量去掉）
    if type(str) ~= "string" or #str == 0 then
        return {}
    end
    local nSepLen = string.len(split_char)
    local sub_str_tab = {}
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + nSepLen, #str)
    end
    return sub_str_tab
end
-- 按splitByChar分割字符串str
-- added by fang. 2013.10.14
function string.splitByChar(str, char)
    local sub_str_tab = {}

    local lastPos=1

    local bLeft = false 
    for i=1, #str do
        local curChar = string.char(string.byte(str, i))
        if curChar == char then
            local size = #sub_str_tab
            sub_str_tab[size+1] = string.sub(str, lastPos, i-1)
            lastPos = i+1
            bLeft = false 
        else
            bLeft = true
        end
    end
    if bLeft then
       local size = #sub_str_tab
       sub_str_tab[size+1] = string.sub(str, lastPos)
    end
        
    return sub_str_tab
end


-- url参数，把所有&的符号去掉，按照参数名 升序排列 拼接
function string.sortUrlParams(pUrl)
    if not pUrl then
        return ""
    end
    print("pUrl:", pUrl)
    local index = string.find(pUrl, "?")
    if index then
        local parmsStr = string.sub(pUrl, index + 1, #pUrl)
        print("parmsStr:", parmsStr)
        local paramTable = string.split(parmsStr, "&")
        printTable("paramTable", paramTable)
        table.sort(paramTable, function ( h1, h2 )
            return h1 < h2
        end)
        return table.concat(paramTable, "")
    else
        return ""
    end
end

-- 检查是否只有字母、下划线和数字
function string.isBaseChar(str)
    local aByte, zByte, AByte, ZByte, _Byte, n0Byte, n9Byte = string.byte("azAZ_09", 1, 7)
    for i = 1, str:len() do
        local c = string.byte(str, i)
        if (c >= aByte and c <= zByte) or (c >= AByte and c <= ZByte) or (c>=n0Byte and  c<=n9Byte) or c == _Byte then
            
        else
            return false
        end
    end
    return true
end

-- 逗比方法，把‘+’替换成‘ ’   同时截断‘&’和‘#’之后的
function string.replacePlusToSpace( src_str)

    local t_str = string.gsub(src_str, "+", " ")
    local t_arr = string.split(t_str, "&")
    t_str = t_arr[1]
    local t_arr = string.split(t_str, "#")
    t_str = t_arr[1]
    print("t_str===", t_str)
    return t_str
end

-- 逗比方法，检查是否包含 ‘+’ 和 “ ”  
function string.isContainPlusAndSpace( src_str )
    local isPlus, _ = string.find(src_str, "[+ ]")
    if(isPlus == nil)then
        return false
    else
        return true
    end
end

-- 判断一个字符串是否是整型数字
function string.isIntergerByStr( m_str )
    print("m_str===",m_str)
    if(type(m_str) ~= "string")then
        return false
    end

    local isInterger = true
    for i=1,string.len(m_str) do
        local char_num =  string.byte(m_str, i)
        print("char_num===",char_num, type(char_num))
        if(char_num<48 or char_num>57)then
            print("char_num<0 or char_num>9char_num<0 or char_num>9")
            isInterger = false
            break
        end
    end

    return isInterger
end

-- 比较版本号 格式必须是 1.2.0 <==> xx.xx.xx return 1/0/-1 <==> >/=/<
function string.checkScriptVersion( newVersion, oldVersion )
    
    local n_version_arr = {0,0,0}
    local o_version_arr = {0,0,0}
    local n_t_arr = string.splitByChar(newVersion, ".")
    local o_t_arr = string.splitByChar(oldVersion, ".")
    
    for k,v in pairs(n_t_arr) do
        n_version_arr[k] = v
    end
    for k,v in pairs(o_t_arr) do
        o_version_arr[k] = v
    end


    if( tonumber(n_version_arr[1]) > tonumber(o_version_arr[1]) )then
        return 1
    elseif( tonumber(n_version_arr[2]) > tonumber(o_version_arr[2]) and tonumber(n_version_arr[1]) == tonumber(o_version_arr[1]))then
        return 1
    elseif( tonumber(n_version_arr[3]) > tonumber(o_version_arr[3]) and tonumber(n_version_arr[2]) == tonumber(o_version_arr[2]) and  tonumber(n_version_arr[1]) == tonumber(o_version_arr[1]))then
        return 1
    elseif( tonumber(n_version_arr[3]) == tonumber(o_version_arr[3]) and tonumber(n_version_arr[2]) == tonumber(o_version_arr[2]) and  tonumber(n_version_arr[1]) == tonumber(o_version_arr[1]))then
        return 0
    else
        return -1
    end

end

-- add by chengliang
--------------------------- url_encode -------------------------
function string.escape(w)  
    pattern="[^%w%d%._%-%* ]"  
    s=string.gsub(w,pattern,function(c)  
        local c=string.format("%%%02X",string.byte(c))  
        return c  
    end)  
    s=string.gsub(s," ","+")  
    return s  
end  
      
function string.detail_escape(w)  
    local t={}  
    for i=1,#w do  
        c = string.sub(w,i,i)  
        b,e = string.find(c,"[%w%d%._%-'%* ]")  
        if not b then  
            t[#t+1]=string.format("%%%02X",string.byte(c))  
        else  
            t[#t+1]=c  
        end  
    end  
    s = table.concat(t)  
    s = string.gsub(s," ","+")  
    return s  
end  
      
function string.unescape(w)  
    s=string.gsub(w,"+"," ")  
    s,n = string.gsub(s,"%%(%x%x)",function(c)  
        return string.char(tonumber(c,16))  
    end)  
    return s  
end

-- urlEncode
function string.urlEncode(url)
    local aByte, zByte, AByte, ZByte, _Byte, dotByte, hypeByte, n0Byte, n9Byte = string.byte("azAZ_.-09", 1, 9)
    local ret = ""
    for i = 1, url:len() do
        local c = string.byte(url, i)
        if (c >= aByte and c <= zByte) or (c >= AByte and c <= ZByte) or (c>=n0Byte and  c<=n9Byte) or c == _Byte or c == dotByte or c == hypeByte then
            ret = ret .. string.char(c)
        else
            ret = ret .. '%'
            ret = ret .. string.format("%x", c)
        end
    end
    return ret
end


function string.isEmpty( p_str )
    local isEmpty = false
    if(type(p_str) ~= "string")then
        isEmpty = true
        print("Warning: the param  is not string or nil")
    elseif( p_str == "")then
        isEmpty = true
    else
        isEmpty = false
    end
    return isEmpty
end

--[[
    @des    :格式化大数字，暂时返回 超过百万以万作单位
    @param  :p_num
    @return :如 1000000 => 100万 策划需求:如果是1009000也同样显示100万，只有当达到万级别时才显示101万
--]]
function string.formatBigNumber( p_num )
    local retNum = nil
    if( tonumber(p_num) >= 1000000)then
        retNum = math.floor( tonumber(p_num)/10000 ) .. GetLocalizeStringBy("lic_1400") -- 这是个万这是个万这是个万啊
    else
        retNum = p_num
    end
    return retNum
end

--[[
    @des    :格式化大数字，返回 超过十万以万作单位
    @param  :p_num
    @return :如 100000 => 10万 策划需求:如果是109000也同样显示10万，只有当达到万级别时才显示11万
--]]
function string.formatBigNumber1( p_num )
    local retNum = nil
    if( tonumber(p_num) >= 100000)then
        retNum = math.floor( tonumber(p_num)/10000 ) .. GetLocalizeStringBy("lic_1400") -- 这是个万这是个万这是个万啊
    else
        retNum = p_num
    end
    return retNum
end

--[[
    @des    : 格式化大数字，返回 超过万以万作单位  add by yangrui main for silver num at 2015-12-03
    @param  : pNum
    @return : 
--]]
function string.formatBigNumber2( pNum )
    local originalNum = tonumber(pNum)
    local retNum = nil
    if originalNum >= 10000 then
        retNum = GetLocalizeStringBy("yr_6000",math.floor(originalNum/10000))
    else
        retNum = originalNum
    end
    return retNum
end

--[[
    @des    : 通过判断是否是国服决定银币的单位显示
    @param  : 
    @return : 
--]]
function string.convertSilverUtilByInternational( pNum )
    local originalNum = tonumber(pNum)
    local silverStr = nil
    if Platform.isInternational ~= nil then
        if Platform.isInternational() then
            silverStr = tostring(originalNum)
        else
            silverStr = string.formatBigNumber2(originalNum)
        end
    else
        silverStr = string.formatBigNumber2(originalNum)
    end
    return silverStr
end

-----------------------------------[[ 打印方法 ]]---------------------------

---打印tab结构 lichenyang
function print_t(sth)
    if not g_debug_mode then
        return
    end
    if type(sth) ~= "table" then
        print(sth)
        return
    end
    local space, deep = string.rep(' ', 4), 0
    -- local bStr = "[LUA-print]"
    local function _dump(t)
        local temp = {}
        for k,v in pairs(t) do
            key = k
            if type(key) == "string" then
                key = string.format("\"%s\"",key)
            elseif type(key) == "number" then
                key = string.format("[%s]",key)
            else
                key = string.format("\"%s\"",key)
            end
            if type(v) == "table" then
                deep = deep + 2
                print(string.format("%s%s => Table", string.rep(space, deep - 1),key) ) 
                print(string.format("%s{",string.rep(space, deep) ) ) --print.
                _dump(v)
                print(string.format("%s}",string.rep(space, deep)))
                deep = deep - 2
            else
                if type(v) == "string" then
                    v = "\"" ..v.."\""
                end
                print(string.format("%s%s => %s",
                string.rep(space, deep + 1),
                key,
                tostring(v) ) )
            end 
        end 
    end
    print("Table")
    print("{")
    _dump(sth)
    print(string.format("}\n"))
end


-- 打印出tbl的所有(key, value)
-- 该函数主要功能是自动计算缩进层次打印出table内容
-- added by fang. 2013-05-30

local tab_indent_count = 0
function print_table (tname, tbl)
    if not g_debug_mode then
        return
    end
    if (tname == nil or tbl == nil) then
        print ("Error, in LuaUtil.lua file. You must pass \"table name\" and \"table`s data\" to print_table function.")
        return
    end
    local tabs = ""
    for i = 1, tab_indent_count do
        tabs = tabs .. "    "
    end
    local param_type = type(tbl)
    if param_type == "table" then
        for k, v in pairs(tbl) do
            -- 如果value还是一个table，则递归打印其内容
            if (type(v) == "table") then
                print (string.format("T %s.%s", tabs, k))
                -- 子table加一个tab缩进
                tab_indent_count = tab_indent_count + 1
                print_table (k, v)
                -- table结束，则退回一个缩进
                tab_indent_count = tab_indent_count - 1
            elseif (type(v) == "number") then
                print (string.format("N %s.%s: %d", tabs, k, v))
            elseif (type(v) == "string") then
                print (string.format("S %s.%s: \"%s\"", tabs, k, v))
            elseif (type(v) == "boolean") then
                print (string.format("B %s.%s: %s", tabs, k, tostring(v)))
            elseif (type(v) == "nil") then
                print (string.format("N %s.%s: nil", tabs, k))
            else 
                print (string.format("%s%s=%s: unexpected type value? type is %s", tabs, k, tostring(v), type(v)))
            end
        end
    end
end

function printTable(tname, tbl)
    if(tname) then
        print("----------------------------[ " .. tname .. " ]-------------------------")
    end
    print_table(tname, tbl)
end



--android GC
local function getFreeMemory()

    local count = 0
    local result = {
        ["MemFree"] = 0,
        ["Buffers"] = 0,
        ["Cached"] = 0,
    }

    for line in io.lines('/proc/meminfo') do
        for key in string.gmatch(line, "%a+") do
            if result[key] == nil then
                break
            end

            for value in string.gmatch(line,"%d+") do
                result[key] = tonumber(value)
            end

            count = count + 1
            if count >= 3 then
                break
            end
        end
    end
    return result

end
local _iLastFree=0
local _iLastMemory=0
function checkMem(...)

    local meminfo = getFreeMemory()
    local memory = meminfo.MemFree + meminfo.Buffers + meminfo.Cached
    local free = meminfo.MemFree
    print("free memory [" .. free .. "," .. memory .. "], [" ..  _iLastFree .. "," .. _iLastMemory .. "]")
    
    if memory > _iLastMemory then
        _iLastMemory = memory
    end
    
    if free > _iLastFree then
        _iLastFree = free 
        return
    end

    if _iLastFree >= free * 2 or _iLastMemory >= memory * 2 then
        print("low memory, purge cached data now")
        CCDirector:sharedDirector():purgeCachedData()
        collectgarbage("collect", 100)
        _iLastFree = 0
        _iLastMemory = 0
    end
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = {}
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + 1, #str)
    end
    return sub_str_tab
end

function file_exists(path)
    --print("file_exists:",path)
    --[[
    local realPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    local file = io.open(realPath, "rb")
    if file then file:close() end
    return file ~= nil
     --]]
    if path == nil then
        return false
    end

    if(Platform.getOS() == "wp")then
        if(path == nil) then return "" end
        path = string.gsub(path,".mp3",".wav")
    end
    
    local realPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    print("realPath:",realPath)
    if(realPath==path)then
        return false
    else
        return true
    end
    --return CCFileUtils:sharedFileUtils():isFileExist(path)
end

-- added by bzx
-- 把字符串转成table 类似“xxx|xxx|xxx,xxx|xxx|xxx”
function strToTable(str,types)
    local data_array1 = string.split(str, ",")
    local data = {}
    for i = 1, #data_array1 do
        local data_array2 = string.split(data_array1[i], "|")
        data[i] = strTableToTable(data_array2, types)
    end
    return data
end

-- added by bzx
-- 把字符串转成table类似 “xxx|xxx|xxx”
function strTableToTable(str_table, types)
    local data = {}
    for i = 1, #str_table do
        local str_element = str_table[i]
        if types ~= nil then
            local element_type = types[i]
            if element_type == "str" then
                data[i] = str_element
            elseif element_type == "n" then
                data[i] = tonumber(str_element)
            end
        else
            data[i] = tonumber(str_element) or str_element
        end
    end
    return data
end

-- added by bzx
-- 将单身条DB数据进行解析，使得string型的数字table转换成table
function parseDB(db)
    if db == nil then
        return nil
    end
    local new_db = {}
    for k, v in pairs(db) do
        local data = v
        local t = nil
        if type(data) == "string" then
           local position =  string.find(data, "|")
           if position ~= nil then
               local t1 = string.split(data, ",")
               if #t1 == 1 then
                    t = strTableToTable(string.split(data, "|"), nil)
               else
                    t = strToTable(data, nil)
               end
           else
            t = data
           end
        else
            t = data
        end
        new_db[k] = t
    end
    setmetatable(new_db, getmetatable(db))
    return new_db
end

-- added by bzx
function parseField(data, dimension)
    if data == nil then
        return {}
    end
    local ret = nil
    if type(data) == "string" then
       local position =  string.find(data, "|")
       if position ~= nil then
           local t1 = string.split(data, ",")
           if #t1 == 1 then
                ret = strTableToTable(string.split(data, "|"), nil)
           else
                ret = strToTable(data, nil)
           end
       else
            position = string.find(data, ",")
            if position ~= nil then
                ret = strTableToTable(string.split(data, ","), nil)
            else
                ret = tonumber(data) or data
            end
       end
    else
        ret = data
    end
    if dimension == 2 then
        if type(ret) == "table" then
            if type(ret[1]) ~= "table" then
                ret = {ret}
            end
        end
    elseif dimension == 1 then
        if type(ret) ~= "table" then
            ret = {ret}
        end
    end
    return ret
end

-- added by bzx
-- 得到一个map的长度
function getMapSize(map)
    local size = 0
    for k, v in pairs(map) do
        size = size + 1
    end
    return size
end

-- added by bzx
-- 以array的结构得到一个map的value
function getValues(map)
    local values = {}
    for k, v in pairs(map) do
        table.insert(values, v)
    end
    return values
end

-- added by bzx
-- 得到VIP的最小需求等级
function getNecessaryVipLevel(field, tag, isOpen)
    local i = 1
    require "db/DB_Vip"
    local vip_db = DB_Vip.getDataById(i)
    local vip_level = nil
    while vip_db ~= nil and vip_db[field] == tag do
        if isOpen ~= nil and isOpen(vip_db[field]) == false then
            break
        end
        i = i + 1
        vip_db = DB_Vip.getDataById(i)
    end
    local vip_level = nil
    if i == 1 then
        vip_level = 0
    else
        vip_level = i - 1
    end
    return vip_level
end


local testTimeArr = {}

local last_time = os.clock()

function RecorderUtilTime( tag_str )
    local time_info = {}
    time_info.tagStr = tag_str
    time_info.time = os.clock()
    time_info.deltTime = time_info.time - last_time
    last_time = time_info.time
    table.insert(testTimeArr, time_info)
    

    print_t(testTimeArr)
    return testTimeArr
end


