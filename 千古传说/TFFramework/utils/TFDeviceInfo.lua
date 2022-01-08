TFDeviceInfo={}
TFDeviceInfo.CLASS_NAME = nil
if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    TFDeviceInfo.CLASS_NAME = "TFDeviceInfo"
elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    TFDeviceInfo.CLASS_NAME = "org/cocos2dx/lib/TFDeviceInfo"
end

function TFDeviceInfo.checkResult(ok,ret)
    -- body
    if ok then return ret end
    return nil
end

function TFDeviceInfo:getSystemName()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getSystemName",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getSystemVersion()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getSystemVersion",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getMachineName()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getMachineName",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getCurAppName()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getCurAppName",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getCurAppVersion()

    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        return "1.0.0"
    end

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        local ok,ret = TFLuaOcJava.callStaticMethod("HeitaoManager", "getAppVersion",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    else
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getCurAppVersion",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    end
end

function TFDeviceInfo:getPhoneNumber()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getPhoneNumber",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getTotalMem()
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        return math.ceil(TFProcessHelper:getAllMemory() / 1024)
    end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getTotalMem",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getFreeMem()
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        return math.ceil(TFProcessHelper:getFreeMemory() / 1024)
    end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getFreeMem",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getIsJailBreak()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getIsJailBreak",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getAddreddBook()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getAddreddBook",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

--will return "2G,3G,4G,5G,WIFI,NO"
function TFDeviceInfo:getNetWorkType()
    -- local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getNetWorkType",nil,"()Ljava/lang/String;")
    -- return TFDeviceInfo.checkResult(ok,ret)

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        local ok,ret = TFLuaOcJava.callStaticMethod("HeitaoManager", "getNetWorkType",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    else
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getNetWorkType",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    end
end

function TFDeviceInfo:copyToPasteBord(content)
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "copyToPasteBord",{szContent = content})
    else
        TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "copyToPasteBord",{content})
    end
end

function TFDeviceInfo:getClipBoardText()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getClipBoardText",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getDeviceToken()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        return CCApplication:sharedApplication():getDeviceTokenID()
     else
        print("android not support")
        return nil
    end
end

function TFDeviceInfo:getCarrierOperator()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getCarrierOperator",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getSDPath()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        print("ios not support")
        return nil
    else
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getSDPath",nil,"()Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

function TFDeviceInfo:getPackageName()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        print("ios not support")
        return nil
    else
        local ok,ret = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getCocos2dxPackageName",nil,"()Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

function TFDeviceInfo:terminateApp()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        endToLua()
    else
    	TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "terminateProcess")
    end
end

function TFDeviceInfo:getResolution()
    -- body
    return me.frameSize.width .. 'x' .. me.frameSize.height
end

function TFDeviceInfo:getMacAddress()
    local ok = nil
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME,"getMacAddress")
    else
        print("only support ios")
    end
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getMachineOnlyID()
    local ok = nil
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME,"getMachineOnlyID")
    else
        print("only support ios")   
    end
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getMachineFreeSpace()
    local ok = false
    local value = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,value = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME,"getDeviceFreeSpace")
    else
        ok1,valueInternal = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper","getInternalMemLeftSize",nil,"()I")
        ok2,valueExt = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper","getExternalTotalMemSize",nil,"()I")
        ok = ok1 and ok2 
        if ok then 
            value = valueInternal > valueExt and valueInternal or valueExt
        else 
            if ok1 then value = valueInternal end
            if ok2 then value = valueExt end
            if value then ok = true end
        end
    end
    return TFDeviceInfo.checkResult(ok,value)
end

function TFDeviceInfo:getUUID()
    if CC_TARGET_PLATFORM ~= CC_PLATFORM_ANDROID then 
        return TFProcessHelper:getUUID()
    end
    local ok, ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getUUID",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok, ret) 
end

-- 是否打开系统浏览器
function TFDeviceInfo:openUrl(url)
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openUrl", {url = url})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openUrl", {url})

        -- return TFDeviceInfo.checkResult(ok,ret)
    end

    return ok
end

--打开黑桃sdk的内嵌网页
function TFDeviceInfo:openHeitaoWebUrl(url)
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openHeitaoWebUrl", {url = url})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openHeitaoWebUrl", {url})
    end

    return ok
end


return TFDeviceInfo