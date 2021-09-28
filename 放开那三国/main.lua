-- Filename: main.lua
-- Author: fang
-- Date: 2013-05-17
-- Purpose: 该文件用于1: 全局变量（非模块）声明; 2: 初始化项目模块

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    printR("----------------------------------------")
    printR("LUA ERROR: " .. tostring(msg) .. "\n")
    printR(debug.traceback())
    printR("----------------------------------------")
    if not g_debug_mode then
        return 
    end
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert(tostring(msg), nil, false, nil)

end 
 
local function main()
	-- avoid memory leak
     
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
     
    require "script/ui/login/ShowLogoUI"
    ShowLogoUI.showLogoUI()
end
 
xpcall(main, __G__TRACKBACK__) 
