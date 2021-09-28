--Filename: DebugUtil.lua
--Author:   chengliang
--Date:     2014/5/9
--Purpose:  调试的相关方法


-- 一般用于抛出异常情况
function DThrowException( ... )
    local t_msg = string.format(...)

    if(t_msg==nil)then
        t_msg = "Throw Exception"
    end
    printB("\n----------------------------------------")
    printB("DThrow Exception: " .. t_msg)
    printB("----------------------------------------\n")

    if not g_debug_mode then
        return
    end
    t_msg = "异常:\n" .. t_msg
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert(t_msg, nil, false, nil)
end
