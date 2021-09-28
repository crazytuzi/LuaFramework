
local SDKIACom = {}

local SDK_GLOBAL_NAME = "sdk.SDKIACom"
local SDK_CLASS_NAME = "SDKIACom"

local sdk = "".. SDK_GLOBAL_NAME --cc.PACKAGE_NAME[SDK_GLOBAL_NAME]


local function onEnterPlatform()
    CCDirector:sharedDirector():pause()
end


local function onLeavePlatform()
    CCDirector:sharedDirector():resume()
end


function SDKIACom.initPlatform( appId, appKey, isDebug, cuKey)

    local function  logout( ... )
        dump("SDKIA_NOT_LOGINED") 
        GameStateManager:ChangeState( GAME_STATE.STATE_VERSIONCHECK )
    end
    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(display.newNode(), logout, "SDKIA_NOT_LOGINED")
    local args = { appId = appId, appKey = appKey, isDebug = isDebug, cuKey = cuKey} 

    luaoc.callStaticMethod(SDK_CLASS_NAME, "initPlatform", args)
end

--[[--

初始化

初始化完成后，可以使用：

    SDKIACom.addCallback() 添加回调处理函数

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
function SDKIACom.init()
    -- if sdk then return end
    
    local sdk_ = {callbacks = {}}
    sdk = sdk_
    SDK_GLOBAL_NAME = sdk

    local function callback(event)
        dump("## SDKIACom CALLBACK, event " .. tostring(event)) 

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
function SDKIACom.cleanup()
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
    SDKIACom.addCallback("mycallback", callback)

]]
function SDKIACom.addCallback(name, callback)
    dump(name)
    dump(callback)
    sdk.callbacks[name] = callback
end

--[[--

删除指定名称的回调函数

]]
function SDKIACom.removeCallback(name)
    sdk.callbacks[name] = nil
end

--[[--

普通登录

]]
function SDKIACom.login()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "login") 
end

--[[--

登录(支持游客登录)

]]
function SDKIACom.loginEx()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "loginEx")
end

--[[--

注销

]]
function SDKIACom.logout(cleanAutoLogin)
    if cleanAutoLogin ~= nil and cleanAutoLogin == true then
        cleanAutoLogin = 1
    else
        cleanAutoLogin = 0
    end
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "logout", {clean = cleanAutoLogin})
end

--[[--

游客账户转正式账户

]]
function SDKIACom.guestRegister()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "guestRegister")
end

--[[--

判断用户登录状态

]]
function SDKIACom.isLogined()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isLogined")
    assert(ok, string.format("SDKIACom.isLogined() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

判断用户登录状态

返回三种值：

-   SDKNDCOM_NOT_LOGINED 未登录
-   SDKNDCOM_GUEST_LOGINED 游客登录
-   SDKNDCOM_LOGINED 正常登录

]]
function SDKIACom.getCurrentLoginState()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getCurrentLoginState")
    assert(ok, string.format("SDKIACom.getCurrentLoginState() - call API failure, error code: %s", tostring(ret)))
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
function SDKIACom.getUserinfo()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getUserinfo")
    assert(ok, string.format("SDKIACom.getUserinfo() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

切换账户

]]
function SDKIACom.switchAccount()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "switchAccount")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKIACom.switchAccount() - call API failure, error code: %s", tostring(ret)))
end

--[[--

切换账户，进入账号管理列表

]]
function SDKIACom.enterAccountManager()
    -- onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterAccountManager")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKIACom.enterAccountManager() - call API failure, error code: %s", tostring(ret)))
end


--[[--

进入论坛

]]
function SDKIACom.enterAppBBS()
    -- onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterAppBBS")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKIACom.enterAppBBS() - call API failure, error code: %s", tostring(ret)))
end


--[[--

进入平台中心

]]
function SDKIACom.enterPlatform()
    SDKIACom.enterAccountManager()
end

--[[
    tool bar
]]

function SDKIACom.showToolbar( ... )
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "showToolbar")
    assert(ok, string.format("SDKIACom.showToolbar() - call API failure, error code: %s", tostring(ret)))
    return ret
end

function SDKIACom.HideToolbar( ... )
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "HideToolbar")
    assert(ok, string.format("SDKIACom.HideToolbar() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

调用后返回一个数组，包含：

-   orderId 订单 Id，用于发送到服务器进行验证
-   error 错误代码，为 0 表示没有发生错误

]]
function SDKIACom.payForIACoins(param)
    -- onEnterPlatform()
    local args = {orderId = tostring(param.orderId), price = param.price, 
                    coins = tostring(param.coins), payDescription = param.payDescription} 

    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "payForIACoins", args)
    if not ok then onLeavePlatform() end

    assert(ok, string.format("SDKIACom.payForIACoins() - call API failure, error code: %s", tostring(ret)))
    return ret
end


return SDKIACom 
