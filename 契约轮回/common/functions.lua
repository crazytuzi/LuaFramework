-- 
-- @Author: LaoY
-- @Date:   2018-07-02 21:24:26
-- lua常用或拓展的方法,比如math、string、table库的拓展

local math_modf = math.modf
local string_format = string.format
--
function toBool(flag)
    return flag and true or false
end

function string2bool(str)
    local t = {
        ["true"] = true,
        ["false"] = false,
    }
    local flag = t[string.lower(str)]
    -- if flag ~= nil then
    -- end
    return flag
end

--lua
function GetLuaMemory()
    -- logWarn("this time the memory is " .. collectgarbage("count") .. "k")
    -- collectgarbage("collect")
    return collectgarbage("count") / 1024
end

--by cocos LuaFramework
local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

--打印table
function dump(value, desciption, nesting)
    if not value then
        return
    end
    if type(nesting) ~= "number" then
        nesting = 6
    end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    result[1] = "dump from: " .. string.trim(traceback[3])

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        -- 过滤PBLua的信息
        if desciption == "_listener" or desciption == "_message_descriptor" then
            return
        end
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result + 1] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent .. "    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do

                    if k then
                        keys[#keys + 1] = k
                        local vk = dump_value_(k) or ""
                        local vkl = string.len(vk)
                        if vkl > keylen then
                            keylen = vkl
                        end
                        values[k] = v
                    end
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result + 1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    -- for i, line in ipairs(result) do
    --     print(line)
    -- end
    print(table.concat(result, "\n"))
end

--[[
    @author LaoY
    @des    打印堆栈
    @param1 param1
    @return number
--]]
function traceback()
    -- local ret = ""  
    -- local level = 2  
    -- ret = ret .. "stack traceback:\n"  
    -- while true do  
    --     --get stack info  
    --     local info = debug.getinfo(level, "Sln")  
    --     if not info then break end  
    --     if info.what == "C" then                -- C function  
    --         ret = ret .. tostring(level) .. "\tC function\n"  
    --     else           -- Lua function  
    --         ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "")  
    --     end
    --     level = level + 1  
    -- end  
    -- print(ret)
    local t = string.split(debug.traceback(), "\n")
    table.remove(t, 2)
    print(table.concat(t, "\n"))
end

--[[
    @author LaoY
    @des    打印堆栈和局部变量，少用。一般用 traceback
    @param1 param1
    @return number
--]]
-- function tracebackex()  
--     local ret = ""  
--     local level = 2  
--     ret = ret .. "stack traceback:\n"  
--     while true do  
--         --get stack info  
--         local info = debug.getinfo(level, "Sln")  
--         if not info then break end  
--         if info.what == "C" then                -- C function  
--             ret = ret .. tostring(level) .. "\tC function\n"  
--         else           -- Lua function  
--             ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "")  
--         end  
--         --get local vars  
--         local i = 1  
--         while true do  
--             local name, value = debug.getlocal(level, i)  
--             if not name then break end  
--             ret = ret .. "\t\t" .. name .. " =\t" .. Table2String(value, 3) .. "\n"  
--             i = i + 1  
--         end    
--         level = level + 1  
--     end  
--     print(ret)
-- end

--[[
    @author LaoY
    @des    字符串序列化成lua table
    @param1 param1
    @return number
--]]
local rechange_tab = {
    ['['] = "{",
    [']'] = "}",
    ['<'] = "",
    ['>'] = "",
    key = "[%[%]<>]"
}
function String2Table(str)
    local old_str = str
    local tab = {}
    if str == nil or str == "nil" then
        return nil
    elseif type(str) ~= "string" then
        tab = {}
        return tab
    elseif #str == 0 then
        tab = {}
        return tab
    end

    local _s = ""
    local number = 0
    str = string.gsub(str, rechange_tab.key, function(s, ...)
        return rechange_tab[s] or s
    end)
    local index, _ = string.find(str, "%b{}")
    if not index then
        str = string.format("{%s}", str)
    end
    -- 这是是特殊字符，看不见的。但是不能做其他操作，要先去除
    local special_index = string.find(str, "([\226])")
    while (special_index) do
        str = string.sub(str, 1, special_index - 1) .. string.sub(str, special_index + 3, len)
        special_index = string.find(str, "([\226])")
    end

    string.gsub(str, "%b{}", function(s)
        -- print(s)
        number = number + 1
        if number >= 2 then
            _s = _s .. ","
        end
        _s = _s .. s
    end)
    if number > 1 then
        _s = "{" .. _s .. "}"
    end

    _s = string.gsub(_s, "([%z\1-\31\33-\43\45-\122\124\126\127\194-\244].-)([,}].-)", function(s, f)
        if tonumber(s) == nil then
            s = "\"" .. s .. "\""
        end
        return s .. f
    end)

    local code, ret = pcall(loadstring(string.format("do local _=%s return _ end", _s)))

    if code then
        return ret
    else
        local error_str = string.format("<font color = '#ff381e'>String to lua table failed, string: %s,please contact php</font>\n%s", old_str, debug.traceback())
        print(error_str)
        local error_msg = "String to lua table failed, string: %s" .. old_str
        tab = {}
        return tab
    end
end

function LString2Table(str)
    local tab = String2Table(str);
    if #tab == 2 and _G.type(tab[1]) ~= "table" then
        tab = { tab };
        return tab;
    end
    return tab;
end

--[[
    @author LaoY
    @des    lua代码格式的string 转成lua table；和 Table2String可以互为转换
--]]
function LuaString2Table(str)
    local code, ret = pcall(loadstring(string.format("do local _=%s return _ end", str)))
    if code then
        return ret
    end
    return {}
end

--[[
    @author LaoY
    @des    table 序列化成string
    @param1 t table
--]]
function Table2String(t, lv)
    local function ser_table(tbl, level)
        level = level or 0
        level = level + 1
        local level_str = string.rep('\t', level)
        local tmp = {}
        local is_line = false
        if type(tbl) ~= "table" then
            return tostring(tbl)
        end
        for k, v in pairs(tbl) do
            local key_type = type(k)
            local key
            if key_type == "number" then
                key = "[" .. k .. "]"
            elseif key_type == "table" then
                key = '[' .. ser_table(k, level + 1) .. '\n' .. level_str .. "]"
            else
                key = '["' .. ser_table(k, level) .. '"]'
            end
            if type(v) == "table" then
                table.insert(tmp, key .. "=" .. ser_table(v, level))
                is_line = true
            elseif type(v) == "function" then
                table.insert(tmp, key .. "=" .. tostring(v))
            else
                if (type(v) == "string") then
                    v = "\"" .. v .. "\""
                end
                if (type(v) == "boolean") then
                    if v then
                        v = "true"
                    else
                        v = "false"
                    end
                end
                table.insert(tmp, key .. "=" .. v)
                is_line = is_line or false
            end
        end
        local str
        local line_str = ""
        local key_str = "\n" .. level_str
        line_str = "\n" .. string.rep('\t', level - 1)
        -- if not is_line then
        --     key_str = ""
        -- end
        str = line_str .. "{" .. "\n" .. level_str .. table.concat(tmp, "," .. key_str) .. line_str .. "}"
        return str
    end
    return ser_table(t, lv)
end

--[[
    @author LaoY
    @des    只读
            用于debug版本的打印测试
    @param1 inputTable  table
    @return table
--]]
-- 
function read_only(inputTable)
    local travelled_tables = {}
    local function __read_only(tbl)
        if not travelled_tables[tbl] then
            local tbl_mt = getmetatable(tbl)
            if not tbl_mt then
                tbl_mt = {}
                setmetatable(tbl, tbl_mt)
            end

            local proxy = tbl_mt.__read_only_proxy
            if not proxy then
                proxy = {}
                tbl_mt.__read_only_proxy = proxy
                local proxy_mt = {
                    __index = tbl,
                    __newindex = function(t, k, v)
                        error("error write to a read-only table with key = " .. tostring(k))
                    end,
                    __pairs = function(t)
                        return pairs(tbl)
                    end,
                    __len = function(t)
                        return #tbl
                    end,
                    __read_only_proxy = proxy
                }
                setmetatable(proxy, proxy_mt)
            end
            travelled_tables[tbl] = proxy
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    tbl[k] = __read_only(v)
                end
            end
        end
        return travelled_tables[tbl]
    end
    return __read_only(inputTable)
end

--深度复制
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function handler(obj, method, param)
    if param then
        --if AppConfig.Debug then
        --    logError("====方法修改====")
        --    traceback()
        --end
        -- 这里会有gc，小心使用
        return function(...)
            local args = { ... }
            if not table.isempty(args) then
                if param then
                    table.insert(args, param)
                    return method(obj, unpack(args))
                end
                return method(obj, ...)
            end
            return method(obj, param)
        end
    else
        return function(...)
            return method(obj, ...)
        end
    end
end

--**********数学公式补充***********--
function checknumber(value, base)
    return tonumber(value, base) or 0
end

function checkint(value)
    return value == math.floor(value) and value or error(false, "value is not int")
end

function math.newrandomseed()
    -- local ok, socket = pcall(function()
    --     return require("socket")
    -- end)

    -- if ok then
    --     math.randomseed(socket.gettime() * 1000)
    -- else
    --     math.randomseed(os.time())
    -- end


    local seed = os.time()

    -- 不搞这么麻烦
    -- if TimeManager then
    --     local time = TimeManager:GetClient()
    --     local time_ms = TimeManager:GetClientMs()

    --     local time_ms_str = tostring(time_ms * 1000)
    --     local time_seed = time_ms_str:sub(-3, -1)
    --     if time_seed:sub(1, 1) == "0" or #time_seed < 3 then
    --         local check_str_list = string.utf8list(tostring(time):reverse())
    --         for k, v in pairs(check_str_list) do
    --             if v ~= "0" then
    --                 time_seed = v .. time_seed
    --                 break
    --             end
    --         end
    --     end
    --     seed = time_seed .. tostring(time):reverse():sub(1, 3) .. time_seed:sub(-1, -1) .. tostring(time):sub(-1, -1) .. time_seed:sub(-2, -2)

    --     Yzprint('--LaoY functions.lua,line 439--', time, time_ms_str, time_seed, seed)
    -- else
    --     seed = seed:reverse():sub(1, 7)
    -- end

    seed = tostring(seed):reverse():sub(1, 7)
    seed = tonumber(seed)
    if not seed then
        seed = os.time()
    end
    if not seed then
        seed = 100
    end

    -- 使用pcall，防止出错导致黑屏
    local status, err = pcall(math.randomseed, seed)
    if not status then
        logError(err)
    end
    -- math.randomseed(seed)

    math.random()
    math.random()
    math.random()
    math.random()

    -- math.randomseed(tostring(time):reverse():sub(1, 7))
    -- math.random()
    -- math.random()
    -- math.random()
    -- math.random()
end

function math.round(value)
    value = checknumber(value)
    return math.floor(value + 0.5)
end

--[[
    @des 角度转弧度
--]]
local pi_div_180 = math.pi / 180
function math.angle2radian(angle)
    return angle * pi_div_180
end

--[[
    @des 弧度转角度
--]]
local pi_mul_180 = 180 / math.pi
function math.radian2angle(radian)
    return radian * pi_mul_180
end

function math.getAngle(angle)
    angle = angle % 360
    angle = angle < 0 and angle + 360 or angle
    angle = angle > 180 and angle - 360 or angle
    return angle
end

--**********数学公式补充***********--

--**********lua io 补充***********--
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then
            return false
        end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then
            -- 46 = char "."
            extpos = pos
        elseif b == 47 then
            -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function io.CheckDirOrCreate(path)
    if io.exists(path) then
        return
    end
    -- 文件夹路径一定要 xx/xx/， xx/xx的文件夹路径判断为xx/
    local info = io.pathinfo(path)
    local dirpath = info.dirname
    dirpath = string.gsub(dirpath, "[/\\]*$", "")
    local cmd
    -- local isExistCmd = "cd " .. "\"" .. dirpath .. "\" >nul 2>nul"
    local isExistCmd = "cd " .. dirpath
    if PlatformManager and PlatformManager:GetInstance() and PlatformManager:GetInstance().IsMobile and PlatformManager:GetInstance():IsMobile() then
        dirpath = string.gsub(dirpath, "\\", "/")
        cmd = "mkdir -p" .. dirpath
    else
        dirpath = string.gsub(dirpath, "/", "\\")
        cmd = "mkdir " .. dirpath
        -- Yzprint('--LaoY functions.lua,line 609--',os.execute("cd " .. dirpath .. ">nul 2>nul"))
        -- Util.CheckFolderOrCreate(dirpath)
        -- return
    end
    local isExistsFolder = os.execute(isExistCmd)
    Yzprint('--LaoY functions.lua,line 615--', isExistsFolder)
    if isExistsFolder == 0 then
        return
    end
    -- cmd = cmd .. " >nul 2>nul"
    local bo = os.execute(cmd)
    Yzprint('--LaoY functions.lua,line 610--', bo)
end
--**********lua io 补充***********--


--**********lua table 补充***********--
function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.sum(tab)
    local number = 0
    if not tab then
        return number
    end
    for k, v in pairs(tab) do
        if type(v) == "number" then
            number = number + v
        end
    end
    return number
end

--[[
    @author LaoY
    @from   https://www.cnblogs.com/njucslzh/archive/2013/02/02/2886876.html
    @des    判断表是否为空
    @param1 tab     table
    @return bool
--]]
function table.isempty(tab)
    return not tab or _G.next(tab) == nil
end

function table.addRange(targetArray, sourceArray)
    for i, v in pairs(sourceArray or {}) do
        table.insert(targetArray, v)
    end
end

--是否包含某个key值
function table.containKey(array, key)
    local has = false
    for i, v in pairs(array) do
        if i == key then
            has = true
            break
        end
    end

    return has
end

function table.containValue(array, value)
    local has = false
    for i, v in pairs(array) do
        if v == value then
            has = true
            break
        end
    end

    return has
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.insertarray(dest, src, count)
    local len = #src
    count = count or len + 1
    for i = 1, len do
        table.insert(dest, src[i])
        if i >= count then
            return
        end
    end
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then
            return i
        end
    end
    return false
end

function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then
            return k
        end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then
                break
            end
        end
        i = i + 1
    end
    return c
end

--[[
    @author LaoY
    @des    删除表内元素，可以不连续
    @param1 array   table
    @param2 index   number  按key值排序的位置，1表示删除key值最小的，2表示第二小的
    @return value
--]]
function table.removebyindex(array, index)
    index = index or 1
    local count = 0
    for i, v in table.pairsByKey(array) do
        count = count + 1
        if index == count then
            array[i] = nil
            return v, i
        end
    end
end

--[[
    @author LaoY
    @des    根据index删除多个，只支持数组
    @param1 array   table
    @param2 array   del_tab  数组，value由小到大
--]]
function table.RemoveByIndexList(array, del_tab)
    local count = 0
    local len = #del_tab
    for i = 1, len do
        local index = del_tab[i] - count
        table.remove(array, index)
        count = count + 1
    end
end

function table.removebykey(array, key)
    key = key or 1
    for i, v in table.pairsByKey(array) do
        if key == i then
            array[i] = nil
            return v, i
        end
    end
end

function table.getbyindex(array, index)
    local _l_index = 1
    for i, v in table.pairsByKey(array) do
        if _l_index == index then
            return array[i]
        end

        _l_index = _l_index + 1
    end
end

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then
            t[k] = nil
        end
    end
end

function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

function table.transfer(tab)
    local t = {}
    for k, v in pairs(tab) do
        t[v] = k
    end
    return t
end

--迭代器 key由小到大遍历
--key 为number
function table.pairsByKey(tab)
    local t = table.keys(tab)
    local function sortFunc(a, b)
        return a < b
    end
    table.sort(t, sortFunc)
    local i = 0
    return function()
        i = i + 1
        return t[i], tab[t[i]]
    end
end
--迭代器 key由大到小遍历
function table.pairsByKeyMax(tab)
    local t = table.keys(tab)
    local function sortFunc(a, b)
        return a > b
    end
    table.sort(t, sortFunc)
    local i = 0
    return function()
        i = i + 1
        return t[i], tab[t[i]]
    end
end


--迭代器 value由小到大遍历
--确保value没有重复且为number
function table.pairByValue(tab)
    local tab2 = table.transfer(tab)
    local t = table.keys(tab2)
    local function sortFunc(a, b)
        return a < b
    end
    table.sort(t, sortFunc)
    local i = 0
    return function()
        i = i + 1
        return tab2[t[i]], t[i]
    end
end

-- 随机遍历
function table.pairByRandom(tab)
    local t = table.keys(tab)
    return function()
        if #t == 0 then
            return nil
        end
        local i = math.random(#t)
        local key = t[i]
        local value = tab[t[i]]
        table.remove(t, i)
        return key, value
    end
end

--[[
    @des 两个表合并，相同的key覆盖
         dest是旧表
         src内容是新表
--]]
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[
    @author LaoY
    @des    递归合并
    @param1 tab
    @param2 src
    @param3 isThorough 表中表是否要递归合并 默认是要
    @ps     dest     = {x = 10,y = 20}
            src = {x = 11,z = 30}
        使用后得：dest = {x = 11,y = 20,z = 30}
--]]
function table.RecursionMerge(dest, src, isThorough)
    if type(dest) ~= "table" or type(src) ~= "table" then
        return
    end
    isThorough = isThorough ~= nil and true or isThorough
    local function recursion(value1, value2)
        for k, v in pairs(value2) do
            if isThorough and type(v) == "table" then
                value1[k] = value1[k] or {}
                recursion(value1[k], v)
            else
                value1[k] = v
            end
        end
    end
    recursion(dest, src)
end
--**********lua table 补充***********--


--**********lua string 补充***********--
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

function string.isempty(str)
    return not str or #string.trim(str) == 0
end

function string.isNilOrEmpty(str)
    if str then
        if #string.trim(str) == 0 then
            return true
        end
    end
    return false;
end

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == '') then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function string.ltrim(input)
    local str, n = string.gsub(input, "^[ \t\n\r]+", "")
    return str
end

function string.rtrim(input)
    local str, n = string.gsub(input, "[ \t\n\r]+$", "")
    return str
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    local str, n = string.gsub(input, "[ \t\n\r]+$", "")
    return str
end

-- 插入空格填充
function string.inserttrim(input, trim_num)
    local len = string.utf8width(input)
    if trim_num <= len then
        return input
    end
    local trim = ""
    for i = 1, trim_num - len do
        trim = trim .. "  "
    end
    return input .. trim
end

function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    local str, n = string.gsub(input, " ", "+")
    return str
end

function string.urldecode(input)
    input = string.gsub(input, "+", " ")
    input = string.gsub(input, "%%(%x%x)", function(h)
        return string.char(checknumber(h, 16))
    end)
    input = string.gsub(input, "\r\n", "\n")
    return input
end

function string.utf8len(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
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

-- 字符串占位符，MondayXMed文算两X
function string.utf8list(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    local t = {}
    local last_len = len
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        local s = string.sub(input, left + 1, last_len)
        last_len = left
        table.insert(t, 1, s)
        cnt = cnt + 1
    end
    return t
end

function string.utf8width(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        if i >= 2 then
            cnt = cnt + 2
        else
            cnt = cnt + 1
        end
    end
    return cnt
end

--过滤特殊字符
function string.filterSpeChars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then
            break
        end
        local c = string.byte(s, k)
        if not c then
            break
        end
        if c < 192 then
            if (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c < 224 then
            k = k + 2
        elseif c < 240 then
            if c >= 228 and c <= 233 then
                local c1 = string.byte(s, k + 1)
                local c2 = string.byte(s, k + 2)
                if c1 and c2 then
                    local a1, a2, a3, a4 = 128, 191, 128, 191
                    if c == 228 then
                        a1 = 184
                    elseif c == 233 then
                        a2, a4 = 190, c1 ~= 190 and 191 or 165
                    end
                    if c1 >= a1 and c1 <= a2 and c2 >= a3 and c2 <= a4 then
                        table.insert(ss, string.char(c, c1, c2))
                    end
                end
            end
            k = k + 3
        elseif c < 248 then
            k = k + 4
        elseif c < 252 then
            k = k + 5
        elseif c < 254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function string.isempty(str)
    return not str or (type(str) ~= "string" and type(str) ~= "number") or #str == 0
end
--**********lua string 补充***********--

function destroyTab(tab, isDelete)
    isDelete = toBool(isDelete);
    if tab then
        for k, v in pairs(tab) do
            v:destroy();
            if isDelete then
                tab[k] = nil;
            end
        end
    end
end

function destroySingle(cls)
    if cls then
        cls:destroy()
    end
end


--比较方法compareFun-----

function PropCompareFun(tab1, tab2)
    return PROP_ENUM[tab1[1]].sort < PROP_ENUM[tab2[1]].sort;
end

function IDCompareFun(tab1, tab2)
    return tab1.id < tab2.id;
end

function SeqCompareFun(tab1, tab2)
    return tab1.seq < tab2.seq;
end

function SortCompareFun(tab1, tab2)
    return tab1.sort < tab2.sort;
end
function OrderCompareFun(tab1, tab2)
    return tab1.order < tab2.order;
end



--根据配置表生成的:HP:1008610086这样的字段
function SetProp(tab, text1, text2)

end

--[[--扩展model的AddEventListener;
其实也可以把GlobalEvent传进来
AddModelEvent(GlobalEvent)
]]
function AddModelEvent(event, handler, model)
    model = model or GlobalEvent;
    return model.AddListener(model, event, handler);
end
function BrocastModelEvent(event, model, ...)
    model = model or GlobalEvent;
    model.Brocast(model, event, ...);
end
function RemoveModelListener(event_id, model)

    model.RemoveListener(model, event_id);
end
function RemoveModelTabListener(tab, model)
    model = model or GlobalEvent;
    if tab then
        for k, v in pairs(tab) do
            model.RemoveListener(model, v);
        end
    end
end
function AddEventListenerInTab(event, handler, tab, model)
    model = model or GlobalEvent;
    tab[#tab + 1] = model:AddListener(event, handler);
    return tab[#tab];
end
--谨慎Use
--不能model = model or GlobalEvent;因为太危险了
function RemoveAllModelEvent(model)
    model:RemoveAll();
end

function StopSchedule(schedule)
    if schedule then
        GlobalSchedule:Stop(schedule);
    end
end

local function tochinesenumber(num)
    if num == nil then
        return
    end
    local chinese_num = { "零", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "7", "8", "9" }
    local tem_name_list = { "", "10", "百", "千", "0K" }
    num = tonumber(num)
    local num_str = tostring(num)
    local num_len = string.len(num_str)
    local final_content = {}
    local cell_content = ""
    for i = 1, num_len do
        if string.sub(num_str, i, i) == "0" then
            if num_len > 1 and (i == num_len or tonumber(string.sub(num_str, i + 1, num_len)) == 0) then
                --尾数的零不显示
                cell_content = ""
            else
                cell_content = chinese_num[1]
            end
        else
            if num >= 10 and num < 20 and i == 1 then
                cell_content = tem_name_list[num_len - i + 1]
            else
                cell_content = chinese_num[string.sub(num_str, i, i) + 1] .. tem_name_list[num_len - i + 1]
            end
        end
        if i == 1 or cell_content ~= chinese_num[1] or final_content[i - 1] ~= chinese_num[1] then
            --避免Med间出现重复的零
            table.insert(final_content, cell_content)
        end
    end
    return table.concat(final_content)
end

--
function ChineseNumber(num)
    if PlatformManager and (not PlatformManager:IsCN()) and (not PlatformManager:IsFT()) then
        return num
    end
    local formatted = tostring(checknumber(num))
    local k
    local count = 0
    local final_content = ""
    while true do
        local cur_format
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d%d)", function(s1, s2)
            cur_format = s2
            return s1
        end)
        if k == 0 then
            break
        end
        if count > 0 and tonumber(cur_format) > 0 then
            if count % 2 == 1 then
                final_content = "0K" .. final_content
            else
                final_content = "00M" .. final_content
            end
        end
        count = count + 1
        final_content = tochinesenumber(cur_format) .. final_content
    end
    if formatted ~= "" then
        if count > 0 then
            if count % 2 == 1 then
                final_content = "0K" .. final_content
            else
                final_content = "00M" .. final_content
            end
        end
        final_content = tochinesenumber(formatted) .. final_content
    end
    return final_content
end

-- local check_tab = {
--     { value = 1000000000000, show = "0K00M", f = 0, check_v = 100000000000000 },
--     { value = 1000000000000, show = "0K00M", f = 1, check_v = 10000000000000 },
--     { value = 1000000000000, show = "0K00M", f = 2, check_v = 1000000000000 },
--     { value = 100000000, show = "00M", f = 0, check_v = 10000000000 },
--     { value = 100000000, show = "00M", f = 1, check_v = 1000000000 },
--     { value = 100000000, show = "00M", f = 2, check_v = 100000000 },
--     { value = 10000, show = "0K", f = 0, check_v = 1000000 },
--     { value = 10000, show = "0K", f = 1, check_v = 100000 },
--     { value = 10000, show = "0K", f = 2, check_v = 10000 },
-- }

local check_tab = {
    { value = 1000, show = "K", f = 2, check_v = 1000 }
}
function GetShowNumber(num, size, show_size)
    --[[
        f 保留几位小数 百0K00MX or above保留0位小数 100K00MX or above保留1位小数 0K00MX or above保留2位小数
    --]]

    for i = 1, #check_tab do
        local info = check_tab[i]
        if info and num >= info.check_v then
            local n, f
            local f_v = math.pow(10, info.f)
            num = num / info.value * f_v
            num = math.round(num)
            local tab = string.split(num / f_v, ".")
            n, f = tab[1] or 0, tab[2] or 0
            local show = info.show
            if show_size then
                show = string.format("<size=%s>%s</size>", show_size, info.show)
            end
            if f == 0 then
                if size then
                    return n .. string.format("<size=%s>%s</size>", size, show)
                else
                    return n .. show
                end
            else
                if f % 10 <= 1e-05 then
                    f = f * 0.1
                end
                if size then
                    return string.format("%d.%s<size=%s>%s</size>", n, f, size, show)
                else
                    return string.format("%d.%s%s", n, f, show)
                end
            end
        end
    end
    return num
end

--获取小数Points后面几位数
function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end

    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

--通过stype获取副本进入消耗
function GetDungeonCost(stype)
    if Config.db_dunge and stype then
        for k, v in pairs(Config.db_dunge) do
            if v.stype == stype then
                local cost = String2Table(v.enter_buy);
                if cost then
                    return cost;
                end
            end
        end
    end
    return nil;
end

function GetGameConfigVal(key)
    if Config.db_game[key] then
        local tab = Config.db_game[key];
        return String2Table(tab.val);
    end
    return nil;
end

function SafetoNumber(value)
    return tonumber(value) or 0;
end

function table.ToSeqTable(tab)
    local ntab = {};
    if tab then
        for k, v in pairs(tab) do
            ntab[#ntab + 1] = { [1] = k, [2] = v };
        end
    end
    return ntab;
end