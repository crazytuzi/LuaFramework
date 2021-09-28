  print("------------77777777777777777777777777----------------------------")
function __G__TRACKBACK__(errorMessage)

    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    local traceback = debug.traceback("", 2)
    print(traceback)
    print("----------------------------------------")


    --只有G_Report初始过后才会对错误日志做处理
    --[[
    if G_Report ~= nil then
        G_Report:onTrackBack(errorMessage, traceback)
    end

    
    if SHOW_EXCEPTION_TIP and uf_notifyLayer ~= nil then 
    	uf_notifyLayer:getDebugNode():removeChildByTag(10000)
		local text = tostring(errorMessage)
        require("upgrade.ErrMsgBox").showErrorMsgBox(text)
		
    end
    ]]
end



function traceMem(desc)
    if desc == nil then
        desc = "memory:"
    end
   

    if CCLuaObjcBridge then
        local callStaticMethod = CCLuaObjcBridge.callStaticMethod

        local ok, ret = callStaticMethod("NativeProxy", "getUsedMemory", nil)

        if ok then
            print(desc .. tostring(ret) .."KB")
        else
            print("call memory failed..." .. tostring(ret))
         
        end
    elseif CCLuaJavaBridge then

        local methodName = "getUsedMemory"
        local callJavaStaticMethod = CCLuaJavaBridge.callStaticMethod
        

        local ok, ret = callJavaStaticMethod("com.youzu.sanguohero.platform.NativeProxy", "getUsedMemory", nil, "()I")

        if ok then
            print(desc .. tostring(ret) .."KB")

        else
            print("call memory failed...".. tostring(ret))

        end
    end

end


-- function trace(desc)

--     if CCLuaObjcBridge then
--         local callStaticMethod = CCLuaObjcBridge.callStaticMethod

--         local ok, ret = callStaticMethod("NativeProxy", "log",{text=desc} )
--     else
--         print(desc)
--     end
-- end

function trace(desc)
    --print(desc)
end
local sharedApplication = CCApplication:sharedApplication()
local target = sharedApplication:getTargetPlatform()

local fileUtils = nil
if target < 10 then
    fileUtils = CCFileUtils:sharedFileUtils()
else
    fileUtils = cc.FileUtils:sharedFileUtils()
end
if fileUtils:isFileExist("scripts/upgrade/config.lua") then
    require("upgrade.config")
end 


--if USE_FLAT_LUA == nil or USE_FLAT_LUA == "0" then 
  --if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid then
  -- FuncHelperUtil:loadChunkWithDefaultKeyAndSign("upgrade.zip")
  --end
--end 


require("upgrade.upgrade")
