--[[--
    将对象序列化
]]
function serialize(t)
    local mark={}
    local assign={}

    local function tb(len)
        local ret = ''
        while len > 1 do
            ret = ret .. '       '
            len = len - 1
        end
        if len >= 1 then
            ret = ret .. '├┄┄'
        end
        return ret
    end

    local function table2str(t, parent, deep)
        deep = deep or 0
        mark[t] = parent
        local ret = {}
        table.foreach(t, function(f, v)
            local k = type(f)=="number" and "["..f.."]" or tostring(f)
            local dotkey = parent..(type(f)=="number" and k or "."..k)
            local t = type(v)
            if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
                table.insert(ret, string.format("%s=%q", k, tostring(v)))
            elseif t == "table" then
                if mark[v] then
                    table.insert(assign, dotkey.."="..mark[v])
                else
                    table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey, deep + 1)))
                end
            elseif t == "string" then
                table.insert(ret, string.format("%s=%q", k, v))
            elseif t == "number" then
                if v == math.huge then
                    table.insert(ret, string.format("%s=%s", k, "math.huge"))
                elseif v == -math.huge then
                    table.insert(ret, string.format("%s=%s", k, "-math.huge"))
                else
                    table.insert(ret, string.format("%s=%s", k, tostring(v)))
                end
            else
                table.insert(ret, string.format("%s=%s", k, tostring(v)))
            end
        end)
        return "{\n" .. tb(deep + 1) .. table.concat(ret,",\n" .. tb(deep + 1)) .. '\n' .. tb(deep) .."}"
    end

    if type(t) == "table" then
        if t.__tostring then 
            return tostring(t)
        end
        local str = string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))
        return "<<table>>" .. str
    else
        return tostring(t)
    end
end

--[[--
    根据指定类型打印日志, 有效日志将会保存在输出文件夹的log目录中
    @param kType: 日志类型:TFLOG_ERROR(错误日志), TFLOG_INFO(记录日志), TFLOG_WARNING(警告日志)
    @param fmt: 格式控制
    @param ...: 输出数据
    @return nil
]]
function TFLOG(kType, fmt, ...)
    local str = string.format(fmt, ...)
    if kType == TFLOG_ERROR then
        TFLOGERROR(str)
    elseif kType == TFLOG_INFO then 
        TFLOGINFO(str)
    elseif kType == TFLOG_WARNING then 
        TFLOGWARNING(str)
    else
        print(str)
    end
end


function TFLOG2(szMsg, kType)
    kType = kType or TFLOG_INFO
    if kType == TFLOG_ERROR then
        TFLOGERROR(szMsg)
    elseif kType == TFLOG_INFO then 
        TFLOGINFO(szMsg)
    elseif kType == TFLOG_WARNING then 
        TFLOGWARNING(szMsg)
    end
end

--[[
    * useful for test
    * not test in real machine
    * by: baiyun
]]
function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    if not currentModuleNameParts then
        if not currentModuleName then
            local source = debug.getinfo(2, 'lS').source
            currentModuleName = source
            currentModuleName = currentModuleName['1:-5']
            currentModuleName = string.gsub(currentModuleName, '/', '.')
        end
        currentModuleNameParts = string.split(currentModuleName, ".")
    end
    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end
    return require(moduleFullName)
end

function handler(func, self)
    return function(...)  return func(self, ...) end
end

function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
    return math.round(tonum(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end

require2 = function(path)
    local oldPath = path
    path = path:gsub('%.', '/')
    path = path .. '.lua'
    local content = io.readfile(path)

    content = string.gsub(content, 'switch%s*%(([%w_]+)%)%s*%{(.-)%}', function(caseWord, content)
        local str = ''
        local first = true
        string.gsub(content, [[case%s*([%w_'"]+)%s*:(.-)break]], function(key, val)
            if key ~= 'default' then 
                if first then 
                    str = str .. string.format("if %s == %s then\n\t%s\n", caseWord, key, val)
                else 
                    str = str .. string.format("elseif %s == %s then\n\t%s\n", caseWord, key, val)
                end
            else 
                if first then 
                    str = str .. string.format("if true then\n\t%s\n", val)
                else 
                    str = str .. string.format("else\n\t%s\n", val)
                end
            end
            first = false
            return ''
        end)
        str = str .. 'end\n'

        return str
    end)
    local ret, err = loadstring(content)
    if ret then
        ret, val = xpcall(ret, __G__TRACKBACK__)
        if ret then 
            package.loaded[path] = val
            return val
        end
        return ret
    else 
        err = string.format("\nlua: erroe loading module '%s' from file '%s':\n", oldPath, path) .. err
        error(err)
        return false
    end
end


--计算图片缓存的使用情况和占用内存情况
function calculateTextureCache()
    local tmap = me.TextureCache:getTexturesMap()
    local nLen = tmap:size()
    local keys = tmap:keys()

    local nUsed = 0
    local nMem = 0
    local nUsedMem = 0

    for i = 0, nLen - 1 do 
        local name = keys:at(i)
        local tex = tmap:objectForKey(name:getCString())
        local bpp = tex:bitsPerPixelForFormat()
        local bytes = tex:getPixelsWide() * tex:getPixelsHigh() * bpp / 8 / 1024
        nMem = nMem + bytes
        if tex:retainCount() > 1 then 
            nUsed = nUsed + 1 
            nUsedMem = nUsedMem + bytes
        end
    end

    return nUsed,nLen,nUsedMem,nMem;
end