----------------------------------------------------
---- 调试工具
---- @author whjing2011@gmail.com
------------------------------------------------------

Debug = Debug or {}

-- 打印调用栈
Debug.trace = function(...)
    if not DEBUG then return end
    print(debug.traceback(), ...)
end

-- 调试日志
Debug.log = function(...)
    if not DEBUG then return end
    Debug.print("debug", true, ...)
end

-- Socket调试日志
Debug.socket = function(cmd, ...)
    if not SOCKET_DEBUG then return end
    if not cmd then return end
    if cmd == 1199 then return end
    if cmd == 10204 then return end
    if type(SOCKET_DEBUG) == 'number' and SOCKET_DEBUG >= 100 and cmd ~= SOCKET_DEBUG and math.floor(cmd / 100) ~= SOCKET_DEBUG then return end
    Debug.print("socket", SOCKET_DEBUG ~= 1, os.time(), ...)
end

-- 普通日志
Debug.info = function(...)
    Debug.print("info", true, ...)
end

-- 错误日志
Debug.error = function(...)
    Debug.print("error", true, ...)
end

-- 条件日志
Debug.is_true = function(flag, ...)
    if not DEBUG or not flag then return end
    Debug.print("cond", true, ...)
end

-- 信息打印输出
Debug.print = function(log_lev, pT, ...)
    local from = log_lev and "["..log_lev.."]"..Debug.track_info(4) or ""
    if pT then
        local tmp = {}
        for k, v in pairs({...}) do 
            if type(v) == "table" then 
                if(#tmp > 0) then print(from, unpack(tmp)); tmp = {} end
                print("↓--"..from.."--↓")
                Debug.printTable(v)
                print("↑--"..from.."--↑")
            else
                tmp[k] = v
            end
        end 
        if(#tmp > 0) then print(from, unpack(tmp)) end
    else
        print(from, ...)
    end
end

-- 打印调用文件和行数
Debug.printParent = function(lev)
    print(Debug.track_info(lev))
end

-- 调用信息
Debug.track_info = function(lev)
    lev = lev or 2
    local track_info = debug.getinfo(lev, "Sln")
    local parent = string.match(track_info.short_src, '[^"\\]+.lua')     -- 之前调用的文件
    return string.format("%s:%d(%s): ",parent or "nil",track_info.currentline,track_info.name or "")
end

-- 打印table
Debug.printTable = function(lua_table, indent)
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
            Debug.printTable(v, indent + 1)
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
    
