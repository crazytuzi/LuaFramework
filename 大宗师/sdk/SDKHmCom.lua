
local SDKHmCom = {}

local SDK_GLOBAL_NAME = "sdk.SDKHmCom"
local SDK_CLASS_NAME = "SDKHmCom"

local sdk = "".. SDK_GLOBAL_NAME --cc.PACKAGE_NAME[SDK_GLOBAL_NAME]

local function onEnterPlatform()
    CCDirector:sharedDirector():pause()
end

local function onLeavePlatform()
    CCDirector:sharedDirector():resume()
end


function SDKHmCom.initPlatform( appId, appKey, isDebug, cuKey)

    local function  logout( ... )
        dump("SDKHMCOM_NOT_LOGINED")
        -- game.player:deleteUID() 
        GameStateManager:ChangeState( GAME_STATE.STATE_VERSIONCHECK )
    end
    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(display.newNode(), logout, "SDKHMCOM_NOT_LOGINED")
    local args = { appId = appId, appKey = appKey, isDebug = isDebug , cuKey = cuKey}

    luaoc.callStaticMethod(SDK_CLASS_NAME, "initPlatform", args)
end

--[[--

初始化
初始化完成后，可以使用：

    SDKHmCom.addCallback() 添加回调处理函数

支持的事件包括：

-   SDKNDCOM_LEAVE_PLATFORM 用户离开 91 平台
-   SDKNDCOM_GUEST_LOGINED 以游客身份登录
-   SDKNDCOM_GUEST_REGISTERED 游客转为正式用户成功
-   SDKNDCOM_LOGINED 正常登录
-   SDKNDCOM_NOT_LOGINED 登录失败
-   SDKNDCOM_HAS_ASSOCIATE 设备上有关联的 91 账号，不能以游客方式登录
-   SDKNDCOM_UNKNOWN_LOGIN_ERROR 未知登录错误
-   SDKNDCOM_INVALID_APPID_OR_APPKEY 无效的 appId 或 appKey
-   SDKNDCOM_INVALID_APPID 无效的 appId
-   SDKNDCOM_SESSION_INVALID session 失效

]]
function SDKHmCom.init()
    -- if sdk then return end
    
    local sdk_ = {callbacks = {}}
    sdk = sdk_
    SDK_GLOBAL_NAME = sdk

    local function callback(event)
        -- echoInfo("## SDKHmCom CALLBACK, event %s", tostring(event))
        dump("## SDKHmCom CALLBACK, event " .. tostring(event)) 

        for name, callback in pairs(sdk.callbacks) do
            callback(event)
        end
        onLeavePlatform()
    end
    dump(sdk.callbacks)
    luaoc.callStaticMethod(SDK_CLASS_NAME, "registerScriptHandler", {listener = callback})
end

--[[--

清理

]]
function SDKHmCom.cleanup()
    sdk.callbacks = {}
    luaoc.callStaticMethod(SDK_CLASS_NAME, "unregisterScriptHandler")
end

--[[--

添加指定名称回调处理函数

用法:

    local function callback(event)
        print(event)
    end

    -- 回调函数名称用于区分不同场合使用的回调函数，removeCallback() 也需要使用同样的名称才能移除回调函数
    SDKHmCom.addCallback("mycallback", callback)

]]
function SDKHmCom.addCallback(name, callback)
    dump(name)
    dump(callback)
    sdk.callbacks[name] = callback
end

--[[--

删除指定名称的回调函数

]]
function SDKHmCom.removeCallback(name)
    sdk.callbacks[name] = nil
end

--[[--

普通登录

]]
function SDKHmCom.login()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "login")
end

--[[--

登录(支持游客登录)

]]
function SDKHmCom.loginEx()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "loginEx")
end

--[[--

注销

]]
function SDKHmCom.logout(cleanAutoLogin)
    if cleanAutoLogin then
        cleanAutoLogin = 1
    else
        cleanAutoLogin = 0
    end
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "logout", {clean = cleanAutoLogin})
end

--[[--

游客账户转正式账户

]]
function SDKHmCom.guestRegister()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "guestRegister")
end

--[[--

判断用户登录状态

]]
function SDKHmCom.isLogined()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isLogined")
    assert(ok, string.format("SDKHmCom.isLogined() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

判断用户登录状态

返回三种值：

-   SDKNDCOM_NOT_LOGINED 未登录
-   SDKNDCOM_GUEST_LOGINED 游客登录
-   SDKNDCOM_LOGINED 正常登录

]]
function SDKHmCom.getCurrentLoginState()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getCurrentLoginState")
    assert(ok, string.format("SDKHmCom.getCurrentLoginState() - call API failure, error code: %s", tostring(ret)))
    if ret == 0 then
        return "SDKNDCOM_NOT_LOGINED"
    elseif ret == 1 then
        return "SDKNDCOM_GUEST_LOGINED"
    else
        return "SDKNDCOM_LOGINED"
    end
end

--[[--

获得已登录用户的信息

返回值是一个表格，包括：

-   uin
-   sessionId
-   nickname 可能为空
-   headCheckSum 头像图片的校验值

]]
function SDKHmCom.getUserinfo()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getUserinfo")
    assert(ok, string.format("SDKHmCom.getUserinfo() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

切换账户

]]
function SDKHmCom.switchAccount()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "switchAccount")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKHmCom.switchAccount() - call API failure, error code: %s", tostring(ret)))
end

--[[--

切换账户，进入账号管理列表

]]
function SDKHmCom.enterAccountManager()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterAccountManager")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKHmCom.enterAccountManager() - call API failure, error code: %s", tostring(ret)))
end

--[[--

用户反馈

]]
function SDKHmCom.userFeedback()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "userFeedback")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKHmCom.userFeedback() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

进入平台中心

]]
function SDKHmCom.enterPlatform()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterPlatform")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKHmCom.enterPlatform() - call API failure, error code: %s", tostring(ret)))
end


--[[--

进入18183论坛

]]
function SDKHmCom.enterAppBBS()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterAppBBS")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKHmCom.enterAppBBS() - call API failure, error code: %s", tostring(ret)))
end


--[[--

进入暂停页面

]]
function SDKHmCom.pause()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "pause")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKHmCom.pause() - call API failure, error code: %s", tostring(ret)))
end


--[[
    91 tool bar
]]

function SDKHmCom.showToolbar( ... )
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "showToolbar")
    assert(ok, string.format("SDKHmCom.showToolbar() - call API failure, error code: %s", tostring(ret)))
    return ret
end

function SDKHmCom.HideToolbar( ... )
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "HideToolbar")
    assert(ok, string.format("SDKHmCom.HideToolbar() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

调用后返回一个数组，包含：

-   orderId 订单 Id，用于发送到服务器进行验证
-   error 错误代码，为 0 表示没有发生错误

]]
function SDKHmCom.payForHMCoins(param)
    -- onEnterPlatform()
    local args = {coins = checknumber(param.coins), price = checknumber(param.price), orderId = param.orderId, 
                    isMonthCard = param.isMonthCard,payDescription = param.payDescription,
                    roleId = param.accId
                } 

    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "payForHMCoins", args)
    if not ok then onLeavePlatform() end

    assert(ok, string.format("SDKHMCom.payForIACoins() - call API failure, error code: %s", tostring(ret)))
    return ret
end



function SDKHmCom.share(message, image)
    onEnterPlatform()
    assert(type(message) == "string", format("SDKHmCom.share() - invalid message %s", tostring(message)))
    local args = {message = message, image = image}
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "share", args)
    if not ok then onLeavePlatform() end
    assert(ok, format("SDKHmCom.share() - call API failure, error code: %s", tostring(ret)))
end

function SDKHmCom.localNotification(message, delay)
    assert(type(message) == "string", string.format("SDKHmCom.localNotification() - invalid message %s", tostring(message)))
    assert(type(delay) == "number" and delay > 0, string.format("SDKHmCom.localNotification() - invalid delay %s", tostring(delay)))
    local args = {message = message, delay = delay}
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "localNotification", args)
    assert(ok, string.format("SDKHmCom.localNotification() - call API failure, error code: %s", tostring(ret)))
end

function SDKHmCom.cleanLocalNotification()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "cleanLocalNotification", args)
    assert(ok, string.format("SDKHmCom.cleanLocalNotification() - call API failure, error code: %s", tostring(ret)))
end

return SDKHmCom
