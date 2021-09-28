
weakCallbackTab = {}
callbackTab = {}

--weak table
setmetatable(weakCallbackTab, {__mode = "v"})

local function onUpdateStateChange(oldState, newState)
    if weakCallbackTab.onUpdateStateChange then
        weakCallbackTab.onUpdateStateChange(oldState, newState)
    else
        print("onUpdateStateChange is nil")
    end
end

local function onProgress( percent )
    if weakCallbackTab.onProgress then
        weakCallbackTab.onProgress(percent)
    else
        print("onProgress is nil")
    end
end

setUpdateStateChangeCB(onUpdateStateChange)
setUpdateProgressCB(onProgress)

function applicationDidEnterBackground()
    print("applicationDidEnterBackground")
end

function applicationWillEnterForeground()
    print("applicationWillEnterForeground")
end

local function nativeCallback(type, result, args0, args1, args2)
    print("nativeCallback", type, result, args0, args1, args2)
    if callbackTab[type] then
        callbackTab[type](result, args0, args1, args2)
    elseif weakCallbackTab[type] then
        weakCallbackTab[type](result, args0, args1, args2)
    else
        --print("nativeCallback", type, "is nil")
    end
end

setNativeCallback(nativeCallback)

function callbackTab.onWakeupNotify(result, args0)
    print("onWakeupNotify", result, args0)

    LoginUtils.launchFromWXGameCenter = false
    LoginUtils.launchFromQQGameCenter = false
    local ret = require("json").decode(args0)

    if ret then
        if ret.messageExt == "WX_GameCenter" then
            LoginUtils.launchFromWXGameCenter = true
        elseif ret.extInfo.launchfrom == "sq_gamecenter" then
            LoginUtils.launchFromQQGameCenter = true
        end
    end
end

function callbackTab.onHttpDNSResolve(result, domain, ips)
    print("onHttpDNSResolve", domain, ips)
    
    local ip = LoginUtils.stringsplit(ips, ";")
    if #ip > 0 then
        setHttpDNS(unpack(ip))
    end
end

