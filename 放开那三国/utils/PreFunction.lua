-- Filename：	PreFunction.lua
-- Author：		Cheng Liang
-- Date：		2014-6-16
-- Purpose：		需要常驻内存或提前加载的方法和模块

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    
    printB("---------------PreFunction-------------------------")
    printB("LUA ERROR: " .. tostring(msg) .. "\n")
    printB(debug.traceback())
    printB("-------------------debug.getinfo---------------------")
    local debug_info = debug.getinfo(2, "Sln")
    print_t(debug_info)
    printB("-------------End----------------------")
    local file_name = "123"
    if( table.isEmpty(debug_info)==false and debug_info.what == "Lua")then
        local infoArr = string.split(debug_info.source, "/")
        file_name = infoArr[#infoArr] .. "_" .. debug_info.currentline
    end

    require "script/utils/ErrorReport"
    ErrorReport.luaErrorReport(msg, file_name)

    if not g_debug_mode then
        return
    end
    require "script/ui/tip/LogLayer"
    LogLayer.show(tostring(msg) .. "\n" .. debug.traceback())
end