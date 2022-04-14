
-- function __G__TRACKBACK__(errorMessage)
--     -- print("----------------------------------------")
--     -- print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
--     -- print("----------------------------------------")
-- 	traceback()
--     print("LUA ERROR: \n")
--     if DebugManager and DebugManager:GetInstance() then
--     	DebugManager:GetInstance():AddErrorList(errorMessage)
--     end
-- end

if LuaFramework.LuaHelper.GetSDKManager().platform == 2 and LuaFramework.Util.IsAndroid64bit() then
    if jit then
        jit.off()
        jit.flush()
    end
end

local LogError = LuaFramework.Util.LogError
function _G_TRACKBACK(errorMessage)
    -- print("----------------------------------------")
    -- print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    -- print("----------------------------------------")
    
    print("----------------------------------------")
    LogError("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print("----------------------------------------")

    if DebugManager and DebugManager:GetInstance() then
    	DebugManager:GetInstance():AddErrorList(errorMessage)
    end
end

 local _, LuaDebuggee = pcall(require, 'LuaDebuggee')
 if LuaDebuggee and LuaDebuggee.StartDebug then
 	LuaDebuggee.StartDebug('127.0.0.1', 9826)
 else
 	print('Please read the FAQ.pdf')
 end

--主入口函数。从这里开始lua逻辑
function Main()
	require "Common.define"
	define.new()		
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
end