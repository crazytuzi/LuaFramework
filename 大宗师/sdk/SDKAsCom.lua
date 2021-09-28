
local SDKAsCom = {}

local SDK_GLOBAL_NAME = "sdk.SDKAsCom"
local SDK_CLASS_NAME = "SDKAsCom"

local sdk = "".. SDK_GLOBAL_NAME --cc.PACKAGE_NAME[SDK_GLOBAL_NAME]

local function onEnterPlatform()
    CCDirector:sharedDirector():pause()
end

local function onLeavePlatform()
    CCDirector:sharedDirector():resume()
end

function SDKAsCom.initPlatform( appId, appKey, isDebug)
    local function aslogout( ... )
        dump("logout")
        -- game.player:deleteUID() 
        GameStateManager:ChangeState( GAME_STATE.STATE_VERSIONCHECK )
    end
    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(display.newNode(), aslogout, "aslogout")


    -- local function ppclose( )
    --     if(GameStateManager.currentState ~= GAME_STATE.STATE_SETTING) then
    --        GameStateManager:ChangeState( GAME_STATE.STATE_MAIN_MENU )
    --     end
    -- end
    -- CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(display.newNode(), ppclose, "ppclose")

    local args = { appId = appId, appKey = appKey, isDebug = isDebug}

    luaoc.callStaticMethod(SDK_CLASS_NAME, "initPlatform", args)
end

--[[--

初始化

初始化完成后，可以使用：

    SDKAsCom.addCallback() 添加回调处理函数

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
function SDKAsCom.init()
    -- if sdk then return end
    
    local sdk_ = {callbacks = {}}
    sdk = sdk_ 
    SDK_GLOBAL_NAME = sdk 

    local function callback(event)
        dump("## SDKAsCom CALLBACK, event %s", tostring(event))

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
function SDKAsCom.cleanup()
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
    SDKAsCom.addCallback("mycallback", callback)

]]
function SDKAsCom.addCallback(name, callback)

    sdk.callbacks[name] = callback
end

--[[--

删除指定名称的回调函数

]]
function SDKAsCom.removeCallback(name)
    sdk.callbacks[name] = nil
end

--[[--

普通登录

]]
function SDKAsCom.login()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "login")
end

--[[--

登录(支持游客登录)

]]
function SDKAsCom.loginEx()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "loginEx")
end

--[[--

注销

]]
function SDKAsCom.logout(cleanAutoLogin)
    if cleanAutoLogin then
        cleanAutoLogin = 1
    else
        cleanAutoLogin = 0
    end
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "logout", {clean = cleanAutoLogin})
end


function SDKAsCom.showToolbar( ... )
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "showToolbar")
    assert(ok, string.format("SDKAsCom.showToolbar() - call API failure, error code: %s", tostring(ret)))
    return ret
end


function SDKAsCom.HideToolbar( ... )
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "HideToolbar")
    assert(ok, string.format("SDKAsCom.HideToolbar() - call API failure, error code: %s", tostring(ret)))
    return ret
end


--[[--

进入平台中心

]]
function SDKAsCom.enterPlatform()
    SDKAsCom.showToolbar()
end

--[[--

游客账户转正式账户

]]
function SDKAsCom.guestRegister()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "guestRegister")
end

--[[--

判断用户登录状态

]]
function SDKAsCom.isLogined()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isLogined")
    assert(ok, string.format("SDKAsCom.isLogined() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

判断用户登录状态

返回三种值：

-   SDKNDCOM_NOT_LOGINED 未登录
-   SDKNDCOM_GUEST_LOGINED 游客登录
-   SDKNDCOM_LOGINED 正常登录

]]
function SDKAsCom.getCurrentLoginState()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getCurrentLoginState")
    assert(ok, string.format("SDKAsCom.getCurrentLoginState() - call API failure, error code: %s", tostring(ret)))
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
function SDKAsCom.getUserinfo()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getUserinfo")
    assert(ok, string.format("SDKAsCom.getUserinfo() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

切换账户

]]
function SDKAsCom.switchAccount()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "switchAccount")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKAsCom.switchAccount() - call API failure, error code: %s", tostring(ret)))
end


--[[--

购买

]]
-- buyAsCoins
function SDKAsCom.payForASCoins(param) 
    onEnterPlatform() 
    local args = {price = param.price, name = param.name, orderId = param.orderId, 
                    roleId = param.accId} 
    dump(args) 
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "payForAsCoins", args) 
    dump(ok)
    if not ok then onLeavePlatform() end 
    assert(ok, string.format("SDKAsCom.payForAsCoins() - call API failure, error code: %s", tostring(ret)))

    return ret  
end 


return SDKAsCom
