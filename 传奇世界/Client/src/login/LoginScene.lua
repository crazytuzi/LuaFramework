local LoginScene = class("LoginScene",function() return cc.Scene:create() end)

require("src/config/LoadingTips")
require("src/login/NativeCallback")
require("src/PandoraFunction")

LoginScene.msdk = true
if isWindows() then
    LoginScene.msdk = false
end

LoginScene.isTersafeCanInit = true

--android 和 iOS 上使用 Windows 登录方式时打开注释
LoginScene.msdk = false

--LoginScene.cdn = "http://dlied5.myapp.com/myapp/1105148805/cqsj"
--LoginScene.cdn = "http://cqsj.webpatch.sdg-china.com/android"

LoginScene.cdnHost = "image.cqsj.qq.com"
if isAndroid() then
    LoginScene.cdnPath = "pr2/android"
elseif isIOS() then
    LoginScene.cdnPath = "pr2/ios"
else
    LoginScene.cdnHost = "192.168.1.24"
    LoginScene.cdnPath = ""
end

if LoginUtils.isDevTest() then
    LoginScene.cdnHost = "cqsj.webpatch.sdg-china.com"
    LoginScene.cdnPath = "android"
elseif LoginUtils.isTestMode() then
    if isAndroid() then
        LoginScene.cdnPath = "yfb/android"
    elseif isIOS() then
        LoginScene.cdnPath = "yfb/ios"
    end    
end

pcall(require, "sdkConfig")
--pcall(require, "gameConfig")

function LoginScene:connectDirServer()
    local dir_server_ip = require("netconfig").dir_server_ip
    local dir_server_port = require("netconfig").dir_server_port or 3100
    if not LoginScene.msdk then
        ServerList.connect(dir_server_ip or "192.168.1.50", dir_server_port)
    elseif LoginUtils.isDevTest() then
        G_isTestEnv = true
        ServerList.connect(dir_server_ip or "115.182.6.186", dir_server_port)
    elseif LoginUtils.isTestMode() then
        G_isTestEnv = true
        ServerList.connect("dir.cqsj.qq.com", "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194", 8082)
    else
        G_isTestEnv = false
        ServerList.connect("dir.cqsj.qq.com", "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194", 8085)
    end
end

function LoginScene:getServerById(id)
    if not self.serverInfo then
        return nil
    end

    for i, v in ipairs(self.serverInfo.servers) do
        if not v.hide and v.id == id then
            return v
        end
    end

    return nil
end

function LoginScene:getDefaultServerId()
    if self.serverInfo.default then
        for i, v in ipairs(self.serverInfo.default) do
            local server = self:getServerById(v)
            if server and server.status ~= 0 then
                return v
            end
        end
    end

    for i, v in ipairs(self.serverInfo.servers) do
        if v.status ~= 0 then
            return v.id
        end
    end
    
    if #self.serverInfo.servers > 0 then
        return self.serverInfo.servers[1].id
    end

    print("getDefaultServerId INVALID SERVER LIST!!!")
    return -1
end

function LoginScene:addDefaultServers()
    local defaultServers = self.serverInfo.default or {}
    if type(defaultServers) == "number" then
        defaultServers = {defaultServers}
    end

    for i, v in ipairs(self.serverInfo.servers) do
        if v.status ~= 0 and v.default then
            if not LoginUtils.hasValue(defaultServers, v.id) then
                defaultServers[#defaultServers + 1] = v.id         
            end
        end
    end

    self.serverInfo.default = defaultServers
end

function LoginScene:getServerVersion(server)
    self.canSkipUpdate = false
    self.canNotLogin = false

    local serverVersion = server.version or self.serverInfo.version
    if server.disableUpdate or self.serverInfo.disableUpdate then
        serverVersion = LoginScene.VERSION
        return serverVersion
    end

    local minServerVersion = server.minVersion or self.serverInfo.minVersion
    if minServerVersion and LoginUtils.compareVersion(minServerVersion, LoginScene.VERSION) ~= 1 then
        self.canSkipUpdate = true
    end

    local maxServerVersion = server.maxVersion or self.serverInfo.maxVersion
    if maxServerVersion and LoginUtils.compareVersion(maxServerVersion, LoginScene.VERSION) == -1 then
        self.canNotLogin = true
    end

    return serverVersion
end

function LoginScene:reportCheckAppUpdate(errorCode, check_update)

    local platform = "GUEST"
    if LoginScene.sdkPlatform == "qq" then
        platform = "QQ"
    elseif LoginScene.sdkPlatform == "wx" then
        platform = "WX"
    end

    local updateType = "1"
    if self.canSkipUpdate then
        updateType = "0"
    end

    local totaltime = 0
    if self.startGetServerInfoTime and self.endGetServerInfoTime then
       totaltime = (self.endGetServerInfoTime - self.startGetServerInfoTime) * 1000
    end

    sdkReportEvent("Service_Login_CheckAppUpdate", false, 
        "errorCode", errorCode,
        "appid", "1105148805",
        "openid", LoginScene.user_name,
        "totaltime", totaltime,
        "platform", platform,
        "ver_addr", LoginScene.cdn,
        "Version", self.serverVersion,
        "check_update", check_update,
        "updateType", updateType,
        "versionType", "2"
    )
end

function LoginScene:reportDownloadEvent(errorCode)

    local totaltime = 0
    if self.startUpdateTime then
       totaltime = (self.startUpdateTime - os.clock()) * 1000
    end

    sdkReportEvent("Service_DownloadEvent", false, 
        "openid", LoginScene.user_name,
        "begintime", self.beginUpdateTimeStr,
        "Version", self.serverVersion,
        "oldversion", LoginScene.VERSION,
        "errorCode", errorCode,
        "gameerrorcode", getLastUpdateErrorCode(),
        "errorinfo", getLastUpdateErrorInfo(),
        "totaltime", totaltime,
        "filesize", getLastUpdateFileSize(),
        "url", LoginScene.cdn,
        "final_url", getLastUpdateFileUrl(),
        "versionType", "2",
        "totalfilesize", getUpdateTotalSize()
    )
end

function LoginScene:ctor()
    --print("LoginScene getMemory:",getMemory())
    local resPath = "res/login/"
    local layer = cc.Layer:create()
    local registerUser = nil
    self:addChild(layer)
    __G_ON_CREATE_ROLE = nil
    _G_IS_LOGINSCENE = true

    self.serverInfo = nil
    
    AudioEnginer.playMusic("sounds/login.mp3",true)

    --关闭潘多拉活动pannel
    require("src/PandoraFunction")
    PandoraCloseAllDialog()
    G_isInMainScene = false

    --print("suzhen ----------------------- close pandora pannel")

    local bg = LoginUtils.createSprite(layer, resPath.."1/00000.jpg", g_scrCenter, cc.p(0.5, 0.5))
    local pos = cc.p(400, 247)

    local loadNum = 0
    local function addImageAsyncCallBack(texture)
        loadNum = loadNum + 1
        if loadNum == 20 then
            local ani = cc.Animation:create()
            for i=0,19 do
                ani:addSpriteFrameWithFile(string.format("res/login/1/%05d.jpg",i))
            end
            ani:setDelayPerUnit(0.18)
            ani:setLoops(10000000)
                
            local animateSpr = cc.Sprite:create()
            animateSpr:setAnchorPoint(0.5, 0.5)
            animateSpr:setPosition(cc.p(568,320))
            animateSpr:runAction(cc.Animate:create(ani))
            bg:addChild(animateSpr)
            bg:release()
        end
    end

    local pTextureCache = cc.Director:getInstance():getTextureCache()
    for i=0,19 do
        pTextureCache:addImageAsync(string.format("res/login/1/%05d.jpg",i), addImageAsyncCallBack)
    end
    bg:retain()


    -- local ani2 = cc.Animation:create()
    -- for i=0,19 do
    --     ani2:addSpriteFrameWithFile(string.format("res/login/2/%04d.png",i))
    -- end
    -- ani2:setDelayPerUnit(0.18)
    -- ani2:setLoops(10000000)
    
    -- local animateSpr2 = cc.Sprite:create()
    -- animateSpr2:setAnchorPoint(0.5, 0.5)
    -- animateSpr2:setPosition(cc.p(568,320))
    -- animateSpr2:runAction(cc.Animate:create(ani2))
    -- bg:addChild(animateSpr2)


    local c_size = bg:getContentSize()
    local scale = g_scrSize.width/c_size.width
    if g_scrSize.height/c_size.height > scale then scale = g_scrSize.height/c_size.height end
    bg:setScale(scale)
    self.bg = bg
    self.layer = layer

    local logo = LoginUtils.createSprite(layer, resPath.."7.png", cc.p( g_scrSize.width-300, g_scrSize.height-200), cc.p(0.5,0.5))
    logo:setScale(scale)

    local versionLable = LoginUtils.createLabel(layer, "当前版本 " ..LoginScene.VERSION, cc.p(10, g_scrSize.height-10), cc.p(0.0, 1.0), 20)
    self.versionLable = versionLable
    
    -- local effect = Effects:create(false)
    -- effect:playActionData("loadingbg", 17, 2, -1)
    -- self.bg:addChild(effect, 2)
    -- effect:setPosition(cc.p(400, 220))

    self.loginNode = cc.Node:create()
    self.loginNode:setVisible(false)
    self.layer:addChild(self.loginNode)
    
    self.registerNode = cc.Node:create()
    self.registerNode:setVisible(false)
    self.layer:addChild(self.registerNode)
    
    self.serverSelectNode = cc.Node:create()
    self.serverSelectNode:setVisible(false)
    self.layer:addChild(self.serverSelectNode)

    self.updateNode = cc.Node:create()
    self.updateNode:setVisible(false)
    self.layer:addChild(self.updateNode)

    LoginUtils.createSprite(self.loginNode, resPath.."tip.png", cc.p( g_scrSize.width/2, 25 ), cc.p(0.5,0.5), 20)
    LoginUtils.createSprite(self.serverSelectNode, resPath.."tip.png", cc.p( g_scrSize.width/2, 25 ), cc.p(0.5,0.5), 20)
    
    self.loginNode.statusLable = LoginUtils.createLabel(self.loginNode, "正在登录，请稍候...", cc.p(g_scrSize.width/2, 100), nil, 20)
    self.loginNode.statusLable:setColor(cc.c3b(237, 215, 27))

    self.serverSelectNode.statusLable = LoginUtils.createLabel(self.serverSelectNode, "正在获取服务器信息，请稍候...", cc.p(g_scrSize.width/2, 100), nil, 20)
    self.serverSelectNode.statusLable:setColor(cc.c3b(237, 215, 27))

    self.updateNode.statusLable = LoginUtils.createLabel(self.updateNode, "", cc.p(g_scrSize.width/2, 100), nil, 20)
    self.updateNode.statusLable:setColor(cc.c3b(237, 215, 27))

    --LuaSocket:getInstance():closeSocket()
    LoginUtils.CommonSocketClose()


    -------获取自己的个人信息，异步回调机制，查询到的结果保存如下
    LoginScene.myNickName = nil
    LoginScene.myGender = nil

    self.onRelationMyInfoNotify = function(result, str)
        local ret = require("json").decode(str)
        if #ret > 0 then
            for i = 1, #ret do
                local record = {}
                LoginScene.myNickName = hexDecode(ret[i].nickName)
                LoginScene.myGender = ret[i].gender
            end
        end
    end
    -------获取自己的个人信息结束

    --todo 从C++注册过来
    local UPDATE_NULL = 0

    local GET_SERVER_INFO = 3
    local GET_SERVER_INFO_FAILED = 4
    local GET_SERVER_INFO_SUCCEEDED = 5

    local GET_FILE_LIST = 10
    local GET_FILE_LIST_FAILED = 11
    local READY_FOR_UPDATE = 12
    local DOWNLOAD_APP = 13
    local DOWNLOAD_FILES = 14
    local UPDATE_FAILED = 15
    local UPDATE_CANCELED = 16
    local UPDATE_SUCCEEDED = 17

    if not LoginScene.msdk then
        g_isCom = true
        local editeNameBg = LoginUtils.createSprite(self.loginNode, resPath.."12.png", cc.p(g_scrSize.width+50, 250), cc.p(1.0, 0.5), 20)
        self.editeNameBg = editeNameBg
        LoginUtils.createSprite(editeNameBg, resPath.."9.png", cc.p(80, editeNameBg:getContentSize().height/2), cc.p(0, 0.5), 20)
        local editeName = LoginUtils.createEditBox(editeNameBg, nil ,cc.p(150, 0) ,cc.size(300, 59), nil, 22,LoginUtils.getStrByKey("login_input_name_tip"))
        editeName:setAnchorPoint(cc.p(0, 0))
        editeName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        local user_name = LoginUtils.getLocalRecordByKey(2,"USER_NAME")
        if isWindows() then
            local strAccount = CGameFunc:getAccount()
            if strAccount ~= "" then
                user_name = strAccount
            end
        end
        if user_name then
            editeName:setText(user_name)
        end

        local editePwdBg = LoginUtils.createSprite(self.loginNode, resPath.."12.png", cc.p(g_scrSize.width+50, 180), cc.p(1.0, 0.5), 20)
        self.editePwdBg = editePwdBg
        LoginUtils.createSprite(editePwdBg, resPath.."10.png", cc.p(80, editeNameBg:getContentSize().height/2), cc.p(0, 0.5), 20)
        local editePwd = LoginUtils.createEditBox(editePwdBg, nil ,cc.p(150, 0) ,cc.size(300, 59), nil, 22,LoginUtils.getStrByKey("login_input_name_tip"))
        editePwd:setAnchorPoint(cc.p(0, 0))
        editePwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        editePwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        local user_pwd = LoginUtils.getLocalRecordByKey(2,"USER_PWD")
        if isWindows() then
            local _, strPwd = CGameFunc:getAccount()
            if strPwd ~= "" then
                user_pwd = strPwd
            end
        end
        if user_pwd then
            editePwd:setText(user_pwd)
        end

        local function winLogin()
            local user_name = editeName:getText()
            local user_pwd = editePwd:getText()

            if user_name == "" then
                LoginUtils.showLoginTips(LoginUtils.getStrByKey("login_tip_empty_name"))
                return
            end
            
            if user_pwd == "" then
                LoginUtils.showLoginTips(LoginUtils.getStrByKey("login_tip_empty_pwd"))
                return
            end

            LoginUtils.setLocalRecordByKey(2, "USER_NAME", user_name)
            LoginUtils.setLocalRecordByKey(2, "USER_PWD", user_pwd)
            
            LoginScene.user_name = user_name
            LoginScene.user_pwd = user_pwd

            registerUser(0)

            --self:changeUIStatus("server_select")
			--self.onServerListJsonInfo(true, "", "")

            --self.startGetServerInfo()
        end

        --注册页
        local logo = LoginUtils.createSprite(self.registerNode, resPath.."reg1.png", cc.p( g_scrSize.width/2, g_scrSize.height/2), cc.p(0.5,0.5), -1)
        local labelX = -200
        local panelX = -50
        local versionLable = LoginUtils.createLabel(self.registerNode, "用户名", cc.p(g_scrSize.width/2 + labelX, g_scrSize.height/2 + 60), cc.p(0.0, 0.5), 20)
        local editeNameBgRegister = LoginUtils.createSprite(self.registerNode, resPath.."reg2.png", cc.p(g_scrSize.width/2+panelX, g_scrSize.height/2 + 60), cc.p(0.0, 0.5), 20)
        self.editeNameBgRegister = editeNameBgRegister
        local editeNameRegister = LoginUtils.createEditBox(editeNameBgRegister, nil ,cc.p(50, 0) ,cc.size(200, 59), nil, 22,LoginUtils.getStrByKey("login_input_name_tip"))
        editeNameRegister:setAnchorPoint(cc.p(0, 0))
        editeNameRegister:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

        local versionLable = LoginUtils.createLabel(self.registerNode, "密码 ", cc.p(g_scrSize.width/2 + labelX, g_scrSize.height/2), cc.p(0.0, 0.5), 20)
        local editePwdBgRegister = LoginUtils.createSprite(self.registerNode, resPath.."reg2.png", cc.p(g_scrSize.width/2+panelX, g_scrSize.height/2), cc.p(0.0, 0.5), 20)
        self.editePwdBgRegister = editePwdBgRegister
        local editePwdRegister = LoginUtils.createEditBox(editePwdBgRegister, nil ,cc.p(50, 0) ,cc.size(200, 59), nil, 22,LoginUtils.getStrByKey("login_input_password_tip"))
        editePwdRegister:setAnchorPoint(cc.p(0, 0))
        editePwdRegister:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        editePwdRegister:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

        local versionLable = LoginUtils.createLabel(self.registerNode, "确认密码", cc.p(g_scrSize.width/2 + labelX, g_scrSize.height/2 - 60), cc.p(0.0, 0.5), 20)
        local editeConfirmBgRegister = LoginUtils.createSprite(self.registerNode, resPath.."reg2.png", cc.p(g_scrSize.width/2+panelX, g_scrSize.height/2 -60), cc.p(0.0, 0.5), 20)
        self.editeConfirmBgRegister = editeConfirmBgRegister
        local editeConfirmRegister = LoginUtils.createEditBox(editeConfirmBgRegister, nil ,cc.p(50, 0) ,cc.size(200, 59), nil, 22,LoginUtils.getStrByKey("login_confirm_password_tip"))
        editeConfirmRegister:setAnchorPoint(cc.p(0, 0))
        editeConfirmRegister:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        editeConfirmRegister:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

        local function winRegister( ... )
            -- body
            local user_name = editeNameRegister:getText()
            local user_pwd = editePwdRegister:getText()
            local user_pwd2 = editeConfirmRegister:getText()

            if user_name == "" then
                LoginUtils.showLoginTips(LoginUtils.getStrByKey("login_tip_empty_name"))
                return
            end
            
            if user_pwd == "" then
                LoginUtils.showLoginTips(LoginUtils.getStrByKey("login_tip_empty_pwd"))
                return
            end
            
            if user_pwd ~= user_pwd2 then
                LoginUtils.showLoginTips(LoginUtils.getStrByKey("login_tip_diff_pwd"))
                return
            end

            LoginUtils.setLocalRecordByKey(2, "USER_NAME", user_name)
            LoginUtils.setLocalRecordByKey(2, "USER_PWD", user_pwd)
            
            LoginScene.user_name = user_name
            LoginScene.user_pwd = user_pwd

            registerUser(1)

        end

        local function changeRegister( ... )
            -- body
            self:changeUIStatus("register")
        end

        local function changeLogin( ... )
            -- body
            self:changeUIStatus("login")
        end

        LoginUtils.createMenuItem(self.registerNode, "res/login/btn4.png", cc.p(g_scrSize.width/2 - 100, g_scrSize.height/2-165), winRegister)
        LoginUtils.createMenuItem(self.registerNode, "res/login/btn5.png", cc.p(g_scrSize.width/2 + 100, g_scrSize.height/2-165), changeLogin)


        LoginUtils.createMenuItem(self.loginNode, "res/login/enter.png", cc.p(g_scrSize.width/2, 87), winLogin);
        LoginUtils.createMenuItem(self.loginNode, "res/login/btn3.png", cc.p(g_scrSize.width/2 , 200), changeRegister)
    end
    
    local wxLoginBtn;
    local qqLoginBtn;
    local guestLoginBtn;
    
    local function wxLogin()
        self.showLoginButton(false)
        sdkWXLogin()
        
        --3秒钟后自动显示登录界面
        performWithDelay(self, function() self.showLoginButton(true) end, 3.0)
    end
    
    local function qqLogin()
        self.showLoginButton(false)
        sdkQQLogin()
        
        --3秒钟后自动显示登录界面
        performWithDelay(self, function() self.showLoginButton(true) end, 3.0)
    end
    
    local function guestLogin()
        self.showLoginButton(false)
        sdkGuestLogin()
        
        --3秒钟后自动显示登录界面
        performWithDelay(self, function() self.showLoginButton(true) end, 3.0)
    end

    self.enterGameBtn = LoginUtils.createMenuItem(self.serverSelectNode, "res/login/enter.png", cc.p(g_scrSize.width/2, 87), function() self:checkUpdate() end);
    self.logoutBtn = LoginUtils.createMenuItem(self.serverSelectNode, "res/login/btn2.png", cc.p(55 , 60), function() self:ChangeUserID() end)
    self.noticeBtn = LoginUtils.createMenuItem(self.serverSelectNode, "res/login/btn1.png", cc.p(55, 145), function() self:showNotice() end)

    if LoginScene.msdk then
        if isAndroid() then
            wxLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_wx.png", cc.p(g_scrSize.width/3, 120), wxLogin)
            qqLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_qq.png", cc.p(g_scrSize.width/3*2, 120), qqLogin)
        elseif isIOS() then
            if isWXInstalled() then
                wxLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_wx.png", cc.p(g_scrSize.width/4, 120), wxLogin)
                qqLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_qq.png", cc.p(g_scrSize.width/4*2, 120), qqLogin)
                guestLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_guest.png", cc.p(g_scrSize.width/4*3, 120), guestLogin)
            else
                qqLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_qq.png", cc.p(g_scrSize.width/3, 120), qqLogin)
                guestLoginBtn = LoginUtils.createMenuItem(self.loginNode, resPath .."login_guest.png", cc.p(g_scrSize.width/3*2, 120), guestLogin)
            end
        end
    end
    
    self.showLoginButton = function(visible)
        if wxLoginBtn then
            wxLoginBtn:setVisible(visible)
        end
        
        if qqLoginBtn then
            qqLoginBtn:setVisible(visible)
        end
        
        if guestLoginBtn then
            guestLoginBtn:setVisible(visible)
        end
        
        self.loginNode.statusLable:setVisible(not visible)
    end
    
    local function showSdkMsg(result)
        local eFlag_Succ              = 0
        local eFlag_QQ_NoAcessToken   = 1000     --QQ&QZone login fail and can't get accesstoken
        local eFlag_QQ_UserCancel     = 1001     --QQ&QZone user has cancelled login process (tencentDidNotLogin)
        local eFlag_QQ_LoginFail      = 1002     --QQ&QZone login fail (tencentDidNotLogin)
        local eFlag_Login_NetworkErr     = 1003  --QQ&QZone&wx login networkErr
        local eFlag_QQ_NotInstall     = 1004     --QQ is not install
        local eFlag_QQ_NotSupportApi  = 1005     --QQ don't support open api
        local eFlag_QQ_AccessTokenExpired = 1006 -- QQ Actoken失效, 需要重新登陆
        local eFlag_QQ_PayTokenExpired = 1007    -- QQ Pay token过期
        local eFlag_QQ_UnRegistered = 1008    -- 没有在qq注册
        local eFlag_QQ_MessageTypeErr = 1009    -- QQ消息类型错误
        local eFlag_QQ_MessageContentEmpty = 1010    -- QQ消息为空
        local eFlag_QQ_MessageContentErr = 1011     -- QQ消息不可用（超长或其他）
    
        local eFlag_WX_NotInstall     = 2000     --Weixin is not installed
        local eFlag_WX_NotSupportApi  = 2001     --Weixin don't support api
        local eFlag_WX_UserCancel     = 2002     --Weixin user has cancelled
        local eFlag_WX_UserDeny       = 2003     --Weixin User has deny
        local eFlag_WX_LoginFail      = 2004     --Weixin login fail
        local eFlag_WX_RefreshTokenSucc = 2005 -- Weixin 刷新票据成功
        local eFlag_WX_RefreshTokenFail = 2006 -- Weixin 刷新票据失败
        local eFlag_WX_AccessTokenExpired = 2007 -- Weixin AccessToken失效, 此时可以尝试用refreshToken去换票据
        local eFlag_WX_RefreshTokenExpired = 2008 -- Weixin refresh token 过期, 需要重新授权
        local eFlag_Error               = -1 --
        local eFlag_Local_Invalid = -2 -- 本地票据无效, 要游戏现实登陆界面重新授权
        local eFlag_LbsNeedOpenLocationService = -4 -- 需要引导用户开启定位服务
        local eFlag_LbsLocateFail = -5 -- 定位失败
        local eFlag_UrlTooLong = -6 -- for WGOpenUrl
    
        local eFlag_NeedLogin = 3001 --需要进入登陆页
        local eFlag_UrlLogin = 3002 --使用URL登陆成功
        local eFlag_NeedSelectAccount = 3003 --需要弹出异帐号提示
        local eFlag_AccountRefresh = 3004 --通过URL将票据刷新
        local eFlag_Need_Realname_Auth = 3005 --
        local eFlag_NotInWhiteList = -3 -- 不在白名单
        local eFlag_InvalidOnGuest = -7 --该功能在Guest模式下不可使用
        local eFlag_Guest_AccessTokenInvalid = 4001 --Guest的票据失效
        local eFlag_Guest_LoginFailed = 4002 --Guest模式登录失败
        local eFlag_Guest_RegisterFailed = 4003 --Guest模式注册失败
        local eFlag_Checking_token = 5001
        
        if result == eFlag_QQ_UserCancel then
            LoginUtils.showLoginTips("您取消了qq授权")
        elseif result == eFlag_WX_UserCancel then
            LoginUtils.showLoginTips("您取消了微信授权")
        elseif result == eFlag_Succ or result == eFlag_WX_RefreshTokenSucc then
            LoginUtils.showLoginTips("登录成功")
        elseif result == eFlag_Local_Invalid then
            --自动登录失败
        elseif result == eFlag_WX_LoginFail or  result == eFlag_Login_NetworkErr or result == eFlag_Guest_LoginFailed then
            LoginUtils.showLoginTips("登录失败, 请检查网络是否正常")
        else
            LoginUtils.showLoginTips("登录失败, 请重试")
        end
    end
    
    local function sdkLoginCallback(result, str)
        print("sdkLoginCallback", result)
        local ret = require("json").decode(str)
        
        local eFlag_WX_RefreshTokenSucc = 2005
        local eFlag_Succ = 0
                
        self.showLoginButton(true)
        
        if ret and ((result == eFlag_Succ) or (result == eFlag_WX_RefreshTokenSucc)) then
            LoginScene.sdkPlatform = ret.platform
            LoginScene.user_name = ret.open_id 
            LoginScene.user_pwd = ret.accessToken

            self:changeUIStatus("server_select")
            self.startGetServerInfo()
            
            self:initPay()

            LoginUtils.queryMyInfo(self.onRelationMyInfoNotify)
            
            httpDNSResolve(LoginScene.cdnHost)
            
            --sdkPay("com.tencent.cqsj.60ingot", 60, true, 1, "")
        end
        
        showSdkMsg(result)
    end

    self.sdkLoginCallback_delay = function (result, str)
        --推后1帧再处理
        performWithDelay(self, function() sdkLoginCallback(result, str) end, 0.01)
    end
    
    weakCallbackTab.login = self.sdkLoginCallback_delay
    
    self:changeUIStatus("login")
    self.showLoginButton(false)
    sdkAutoLogin()

    registerUser = function ( isCreate )
        --body
        require("src/game")
        require("src/tools")

        self:registerLoginMsg()
        game.startup()

        local net_cfg = require("netconfig")

        local port = net_cfg.port
        local ip = net_cfg[-1]

        CommonSocketClose()    
        LuaSocket:getInstance():openSocket(0,0, port, ip)

        globalInit()
        userInfo.connStatus = CONNECTING
        userInfo.connType = REGISTER
        userInfo.isCreate = isCreate
        userInfo.userName = LoginScene.user_name

        userInfo.loginPort = port
        userInfo.loginIp = ip

        if isCreate == 1 then 
            print("register user_name:", LoginScene.user_name, ",user_pwd:", LoginScene.user_pwd)
            print("register ip:", userInfo.loginIp, userInfo.loginPort)
        else
            print("login user_name:", LoginScene.user_name, ",user_pwd:", LoginScene.user_pwd)
            print("login ip:", userInfo.loginIp, userInfo.loginPort)
        end
    end
    self.registerUser = registerUser;
    
    local function enterGame()
        require("src/game")
        require("src/tools")

        if LoginScene.isTersafeCanInit then
            LoginScene.isTersafeCanInit = false
            TersafeSDK:TersafeInitGame()
        end
        
        self:registerLoginMsg()
        game.startup()

        local server = self:getServerById(LoginScene.serverId)
        if not server then
            print("no server !!!")
            return
        end

        local port = server.port
        local ip = server.ip
        local serverId = LoginScene.serverId

        --检测是否iOS Review模式
        if LoginScene.reviewServer then
            local svr = self:getServerById(LoginScene.reviewServer)
            if svr then
                port = svr.port
                ip = svr.ip
                serverId = LoginScene.reviewServer
            end
        end
        
        CommonSocketClose()        
        --LuaSocket:getInstance():closeSocket()
        if GameSocketLunXun then
            LuaSocket:getInstance():openSocket(3,0, port, ip, "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194")
        else
            LuaSocket:getInstance():openSocket(0,0, port, ip)
        end
        globalInit()
        userInfo.connStatus = CONNECTING
        userInfo.connType = LOGIN
        userInfo.serverName = server.name
        userInfo.serversreal = serverId
        userInfo.serverId = serverId
        userInfo.userName = LoginScene.user_name
        userInfo.loginPort = port
        userInfo.loginIp = ip
        addNetLoading(nil, FRAME_SC_ENTITY_ENTER, nil, 90, 0)
        print("login ip:", userInfo.loginIp, userInfo.loginPort)
		print(debug.traceback())
    end    
    
    --自动更新相关

    local sprite_bg = LoginUtils.createSprite(self.updateNode, "res/login/loadingbg.png",cc.p(g_scrSize.width/2, 0), cc.p(0.5,0.0))
    local bg_size = sprite_bg:getContentSize()
    local b_scale = g_scrSize.width/bg_size.width
    sprite_bg:setScale(b_scale)
    local progress = cc.ProgressTimer:create(cc.Sprite:create("res/login/loadingpr.png"))  
    progress:setPosition(cc.p(0, bg_size.height/2+5))
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setAnchorPoint(cc.p(0.0,0.5))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setMidpoint(cc.p(0,1))
    progress:setPercentage(0)
    sprite_bg:addChild(progress)

    local runeffect = Effects:create(false)
    runeffect:playActionData("loading", 6, 0.6, -1)
    progress:addChild(runeffect, 2)
    runeffect:setPosition(cc.p(50,100))
    self.progress = progress
    self.runeffect = runeffect

    local progressLable = LoginUtils.createLabel(self.updateNode, "", cc.p(g_scrSize.width/2,120),nil,20)
    progressLable:setColor(cc.c3b(247, 206, 150))
    self.progressLable = progressLable

    self.tips_lab = LoginUtils.createLabel(self.updateNode, "", cc.p(g_scrSize.width/2,15), nil, 20)
    self.tips_lab:setColor(cc.c3b(237, 215, 27))
    
    self.checkUpdate = function ()
        print("checkUpdate called")

        local server = self:getServerById(LoginScene.serverId)
        if not server then
            print("no server !!!")
            return
        end

        if server.status == 0 then
            self:showNotice()
            self:refreshServerList()
            return
        end

        --server.minVersion = "0.16.1.39"
        --LoginScene.VERSION = "0.16.1.39"
        --server.version = "0.16.1.44"

        self.serverVersion = self:getServerVersion(server)
        
        if self.canNotLogin then
            LoginUtils.showLoginTips("客户端版本太高, 不能登录这个服, 请换其他服")
            return
        end

		--by martin yang 
		enterGame()
		--[[ by martin yang
        if LoginUtils.compareVersion(LoginScene.VERSION, self.serverVersion) ~= -1 then
            enterGame()

            self:reportCheckAppUpdate(0, 0)
            return
        end

        self:changeUIStatus("update")
        self:startGetFileList()

        self:reportCheckAppUpdate(0, 1)]]
    end

    --(1: QQIOS, guest IOS, windows, 2 : QQ安卓, 3 : 微信IOS, 4 : 微信安卓)
    self.onServerListConnected = function()
        weakCallbackTab.onServerListJsonInfo = self.onServerListJsonInfo
        self.serverListNetworkErrorCount = 0

        ServerList.requestAllInfo("", sdkGetArea())
    end

    self.onServerListNetworkError = function(netStatus)
        --连接失败
        weakCallbackTab.onServerListConnected = nil
        weakCallbackTab.onServerListNetworkError = nil

        self.serverListNetworkErrorCount = self.serverListNetworkErrorCount  + 1
        if self.status == "server_select" then

            if self.serverListNetworkErrorCount >= 3 then
                --local json = LoginUtils.getLocalRecordByKey(2, "serverList"..sdkGetArea(), "")
                --if #json > 0 then
                --    self.onServerListJsonInfo(0, "", json)
                --    return
                --end
            end
            
            LoginUtils.MessageBox("下载服务器信息失败，请检测网络是否正常！", "重试", self.startGetServerInfo)
            --LoginUtils.MessageBoxYesNo("更新失败", "下载服务器信息失败，请检测网络是否正常！", self.startGetServerInfo, self.cancelUpdate, "重试", "取消")
        end

        self.endGetServerInfoTime = os.clock()
        self:reportCheckAppUpdate(92001, 0)
    end

    self.onServerListJsonInfo = function (result, version, json)

        self.endGetServerInfoTime = os.clock()

        if #json > 0 then
            json = string.gsub(json, "\r\n", "\n")
            json = string.gsub(json, "\r", "\n")
        end

        print("onServerListJsonInfo", result, version, json)
        weakCallbackTab.onServerListConnected = nil
        weakCallbackTab.onServerListNetworkError = nil

        if #json == 0 then
            json = LoginUtils.getLocalRecordByKey(2, "serverList"..sdkGetArea(), "")
            if string.len(json) == 0 then
                json = cc.FileUtils:getInstance():getStringFromFile("defServerList.json")
            end
        else
            LoginUtils.setLocalRecordByKey(2, "serverList"..sdkGetArea(), json)
        end
        
        local noerror, ret = pcall(require("json").decode, json)
        if noerror and ret and ret.servers then
            if ret.exec then
                doString(ret.exec)
            end

            self.serverSelectNode.statusLable:setVisible(false)
            self.enterGameBtn:setVisible(true)

            --记录iOS审核模式进入的服务器id
            if ret.reviewAppVersion and 
               ret.reviewAppVersion == getAppCode() and 
               ret.reviewServer and 
               getServerById(ret.reviewServer) then
                LoginScene.reviewServer = ret.reviewServer
            else
                LoginScene.reviewServer = nil
            end

            self:initServerList(ret)
        else
            print("serverInfo json decode error")

            if self.status == "server_select" then
                LoginUtils.MessageBox("服务器信息解码失败！", "重试", self.startGetServerInfo)
                --LoginUtils.MessageBoxYesNo("更新失败", "服务器信息解码失败！", self.startGetServerInfo, self.cancelUpdate, "重试", "取消")
            end
        end
    end

    self.onServerListStatus = function (count, json)
        LoginUtils.setLocalRecordByKey(2, "serverListStatus", json)
    end

    self.onServerListLoginHistory = function(count, json)
        LoginUtils.setLocalRecordByKey(2, "loginHistory" .. sdkGetOpenId(), json)
    end

    self.onServerListLastLogin = function(lastLogin)
        LoginUtils.setLocalRecordByKey(1, "serverListLastLogin" .. sdkGetOpenId(), lastLogin)

        if self:getServerById(LoginScene.lastLogin) then
            LoginScene.serverId = LoginScene.lastLogin
            self:addSuggestedServer()
        end
    end

    weakCallbackTab.onServerListStatus = self.onServerListStatus
    weakCallbackTab.onServerListLoginHistory = self.onServerListLoginHistory
    weakCallbackTab.onServerListLastLogin = self.onServerListLastLogin
    self.serverListNetworkErrorCount = 0

    self.onUpdateStateChange = function (oldState, newState)
        print("onUpdateStateChange", oldState, newState)

        if newState == GET_FILE_LIST_FAILED then
            if self.canSkipUpdate then
                LoginUtils.MessageBoxYesNo("是否更新", "检测到新的版本", self.startGetFileList, self.cancelUpdate, "更新", "暂不更新")
            else
                LoginUtils.MessageBoxYesNo("更新失败", "下载文件列表失败，请检测网络是否正常！", self.startGetFileList, self.cancelUpdate, "重试", "取消")
            end

            httpDNSResolve(LoginScene.cdnHost)
            self:reportDownloadEvent(1)
        end

        if newState == UPDATE_FAILED then
            LoginUtils.MessageBoxYesNo("更新失败", "下载文件失败，请检测网络是否正常！", self.startUpdate, self.cancelUpdate, "重试", "取消")
            
            httpDNSResolve(LoginScene.cdnHost)
            self:reportDownloadEvent(1)
        end

        if newState == READY_FOR_UPDATE then
            local totalSize = getUpdateTotalSize()

            local progress_str = string.format("0/%8.3fKB：0%%",0, totalSize/1024)
            if self.progress_lab then
                self.progress_lab:setString(progress_str)
            end

            if totalSize > 500 * 1024 then
                local size_str = string.format("%8.3fKB", totalSize/1024)
                if totalSize > 1024 * 1024 then 
                    size_str =  string.format("%8.3fM", totalSize/(1024*1024))
                end

                if self.canSkipUpdate then
                    LoginUtils.MessageBoxYesNo("是否更新", "检测到新的版本，本次更新需要下载资源"..size_str, self.startUpdate, self.cancelUpdate, "更新", "暂不更新")
                else
                    LoginUtils.MessageBoxYesNo("需要更新", "检测到新的版本，本次更新需要下载资源"..size_str, self.startUpdate, self.cancelUpdate, "更新", "取消")
                end

                --MessageBox("检测到新的版本，本次更新需要下载资源"..size_str,"开始更新", self.startUpdate)
            else
                self.startUpdate()
            end
        end

        if newState == UPDATE_SUCCEEDED then

            if LoginScene.VERSION ~= self.serverVersion then
                LoginScene.VERSION = self.serverVersion
                cc.UserDefault:getInstance():setStringForKey("current-version-code", self.serverVersion) 
                cc.UserDefault:getInstance():flush()
            end
            self:reportDownloadEvent(0)

            if updateNeedRestartApp() then
                LoginUtils.MessageBox("更新完毕，需要重新启动游戏", "重启游戏", restartApp)
            else
                self.versionLable:setString("当前版本 " ..LoginScene.VERSION)
                self:changeUIStatus("server_select")
                
                --更新后清除下缓存，注意：mainui@0也会清除，进入游戏会add mainui@0，所以不会有问题
                cc.SpriteFrameCache:getInstance():removeSpriteFrames()
                cc.Director:getInstance():getTextureCache():removeAllTextures()
                cc.SpriteFrameCache:getInstance():removePlistCache()
                cc.FileUtils:getInstance():purgeCachedEntries()
                
                enterGame()
            end
        end
    end

    local lastProgressTime = 0;
    self.onProgress = function (percent)

        local totalSize = getUpdateTotalSize()
        local currentSize = getUpdateCurrentSize()

        local progress_str        
        if totalSize > 1024 * 1024 then
            progress_str = string.format("%8.3f/%8.3fM：(%d%%)", currentSize/(1024*1024), totalSize/(1024*1024), percent)
        elseif totalSize > 1024 then
            progress_str = string.format("%8.3f/%8.3fKB：(%d%%)", currentSize/1024, totalSize/1024, percent)
        else
            progress_str = string.format("%d/%dB：(%d%%)", currentSize, totalSize, percent)
        end

        if lastProgressTime + 20 <= os.time() then
            lastProgressTime = os.time()

            if G_TIPS then
                local tips = G_TIPS[math.random(1, #G_TIPS)]
                if tips then 
                    self.tips_lab:setString(tips) 
                end
            end
        end

        self.progressLable:setString(progress_str)
        self.progress:setPercentage(percent * 0.9)
        self.runeffect:setPosition(cc.p(-10+percent*11 * 0.9,100))
    end

    weakCallbackTab.onUpdateStateChange = self.onUpdateStateChange
    weakCallbackTab.onProgress = self.onProgress

    setHttpHost(LoginScene.cdnHost, LoginScene.cdnPath)

    self.startGetServerInfo = function()
        self.serverSelectNode.statusLable:setVisible(true)
        self.enterGameBtn:setVisible(false)

        self.startGetServerInfoTime = os.clock()
        
        weakCallbackTab.onServerListConnected = self.onServerListConnected
        weakCallbackTab.onServerListNetworkError = self.onServerListNetworkError

        self:connectDirServer()
    end

    self.startGetFileList = function()
        self.updateNode.statusLable:setString("正在获取文件列表，请稍候...")
        
        startGetFileList(self.serverVersion)
        self.beginUpdateTimeStr = os.date("%Y-%m-%d%X")
        self.startUpdateTime = os.clock()
    end

    self.startUpdate = function ()
        self.updateNode.statusLable:setString("正在进行版本更新，请稍候...")

        lastProgressTime = 0
        startUpdate()
        self.beginUpdateTimeStr = os.date("%Y-%m-%d%X")
        self.startUpdateTime = os.clock()
    end

    self.cancelUpdate = function ()
        if self.canSkipUpdate then
            self:changeUIStatus("server_select")
            enterGame()
        else
            endUpdate()
            self:changeUIStatus("server_select")
        end
    end

    self:registerScriptHandler(function(event)
        if event == "enter" then
            _G_IS_LOGINSCENE = true
        elseif event == "exit" then
            _G_IS_LOGINSCENE = false
        end
    end)

    --[[
    local netSim = require("src/net/NetSimulation")
    if netSim.OpenBtn then
        local func = function( )
            self.layer:removeChildByTag(107)
            local sub_node = require("src/net/NetSimulation").new()
            if sub_node then
                self.layer:addChild(sub_node, 200, 107)
            end
        end
        LoginUtils.createTouchItem(self.layer, "res/component/checkbox/2-1.png", cc.p(25, 28), func)
    end
    --]]


end

function LoginScene:addLocalServer()
    local net_cfg = require("netconfig")
    if net_cfg.local_ip then
        net_cfg.server_id = net_cfg.server_id or 900
        if not self:getServerById(net_cfg.server_id) then
            local server = {}
            server.ip = net_cfg.local_ip
            server.port = net_cfg.port
            server.status = 1
            server.id = net_cfg.server_id
            server.name = "私服服务器"
            self.serverInfo.servers[#self.serverInfo.servers + 1] = server

            --LoginScene.serverId = net_cfg.server_id
        end
    end
end

function LoginScene:initServerList(serverInfo)

    if not serverInfo or not serverInfo.servers or #serverInfo.servers == 0 then
        print("initServerList INVALID SERVER LIST !!!")
        return
    end

    self.serverInfo = serverInfo
    self:addDefaultServers()

    LoginScene.serverId = LoginUtils.getLocalRecordByKey(1, "serverListLastLogin" .. sdkGetOpenId(), -1)
    self:addLocalServer()

    if not self:getServerById(LoginScene.serverId) then
        LoginScene.serverId = self:getDefaultServerId()
    end

    self:showNotice()

    self:addSuggestedServer()
end

function LoginScene:addSuggestedServer()

    if not self.suggestedServerBg then
        local showServerSelect = function()                   
            AudioEnginer.playEffect("sounds/uiMusic/ui_click1.mp3", false)

            --package.loaded["src/login/ServerSelectLayer"] = nil
            local serverSelectLayer = require("src/login/ServerSelectLayer").new(self)
            self.serverSelectNode:addChild(serverSelectLayer, 100, 101)
        end

        self.suggestedServerBg = LoginUtils.createTouchItem(self.serverSelectNode, "res/login/serverBg.png", cc.p(g_scrCenter.x, 160), showServerSelect, nil, nil, true)
        self.suggestServerNode = cc.Node:create()
        self.suggestedServerBg:addChild(self.suggestServerNode)
    end

    local itemData = self:getServerById(LoginScene.serverId)
    if itemData then
        self.suggestServerNode:removeAllChildren()
        local server_lab = LoginUtils.createLabel(self.suggestServerNode, itemData.name, cc.p(200, 22.5), nil, 24)
        server_lab:setColor(MColor.yellow)
        LoginUtils.createSprite(self.suggestServerNode, "res/login/status" .. itemData.status .. ".png", cc.p(200 - server_lab:getContentSize().width/2 - 30, 22.5))   
    end
end

function LoginScene:refreshServerList()
    self.onRefreshServerListConnected = function()
        ServerList.requestAllInfo("0", sdkGetArea())
    end

    self.onRefreshServerListNetworkError = function(netStatus)
        --连接失败
        weakCallbackTab.onServerListConnected = nil
        weakCallbackTab.onServerListNetworkError = nil
    end
    
    self.onRefreshServerListJsonInfo = function (result, version, json)

        if #json > 0 then
            json = string.gsub(json, "\r\n", "\n")
            json = string.gsub(json, "\r", "\n")
        end

        print("onRefreshServerListJsonInfo", result, version, json)
        weakCallbackTab.onServerListConnected = nil
        weakCallbackTab.onServerListNetworkError = nil
        
        local noerror, ret = pcall(require("json").decode, json)
        if noerror and ret and ret.version then
            LoginUtils.setLocalRecordByKey(2, "serverList"..sdkGetArea(), json)

            self.serverInfo = ret
            self:addSuggestedServer()
        end
    end
    
    weakCallbackTab.onServerListJsonInfo = self.onRefreshServerListJsonInfo
    if ServerList.isConnected() then
        self.onRefreshServerListConnected()
    else
        weakCallbackTab.onServerListConnected = self.onRefreshServerListConnected
        --weakCallbackTab.onServerListNetworkError = self.onRefreshServerListNetworkError
        self:connectDirServer()
    end
end

function LoginScene:changeUIStatus(newStatus)
    self.loginNode:setVisible(false)
    self.registerNode:setVisible(false)
    self.serverSelectNode:setVisible(false)
    self.updateNode:setVisible(false)

    if newStatus == "login" then
        self.loginNode:setVisible(true)
    elseif newStatus == "register" then
        self.registerNode:setVisible(true)
    elseif newStatus == "server_select" then
        self.serverSelectNode:setVisible(true)
    elseif newStatus == "update" then
        self.updateNode:setVisible(true)
    end
    self.status = newStatus
    print("changeUIStatus", self.status)
end

function LoginScene:showNotice()
    local server = self:getServerById(LoginScene.serverId)
    if server then
        if server.status == 0 then
            LoginUtils.showNotice("1", server.notice or LoginUtils.getStrByKey("server_stop"))
        else
            LoginUtils.showNotice("1", server.notice)
        end
    else
        LoginUtils.showNotice("1")
    end
end

function LoginScene:ChangeUserID()
    sdkLogout()

    LoginScene.user_name = nil
    LoginScene.user_pwd = nil

    self:changeUIStatus("login")
end

function LoginScene:initPay()
    print("isJailbroken", isJailbroken())

    local payEnv = SdkPayEnv
    if LoginUtils.isTestMode() then
        payEnv = SdkPayEnv or "test"
    else
        payEnv = SdkPayEnv or "release"
    end
    sdkSetPayEnv(payEnv)
    
    sdkPayInit()
    sdkEnablePayLog(true)
    sdkRegisterPay("")
end

function LoginScene:openActiveCodeLayer()
    local itemData = self:getServerById(userInfo.serverId)
    if itemData and not self.activeLayer then
        local retSprite = createSprite(self, "res/common/5.png", cc.p(display.cx, display.cy+ 38))
        self.activeLayer = retSprite
        local bgSize = retSprite:getContentSize()
        createLabel(retSprite, game.getStrByKey("active_code_title"), cc.p(bgSize.width/2, bgSize.height - 26), nil, 22, true)

        local str = string.format(game.getStrByKey("active_code_server"), itemData.name)
        local richText = require("src/RichText").new(retSprite, cc.p(bgSize.width/2, 200), cc.size(340, 30), cc.p(0.5, 0.5), 24, 20, MColor.lable_black)
        richText:setAutoWidth()
        richText:addText(str)
        richText:format()
        -- local labSize = richText:getContentSize()
        -- richText:setPositionX(bgSize.width/2 - labSize.width/2)

        -- local str = string.format(game.getStrByKey("active_code_server"), itemData.name)
        -- createLabel(retSprite, str, cc.p(bgSize.width/2, 200), nil, 20, true)


        local editDeskBg = createSprite(retSprite, COMMONPATH.."bg/inputBg9.png",cc.p(bgSize.width/2, 145),cc.p(0.5, 0.5))
        local editDesk = createEditBox(editDeskBg , nil, cc.p(5, 25), cc.size(280, 30), nil, 20)
        editDesk:setAnchorPoint(cc.p(0,0.5))
        editDesk:setPlaceHolder(game.getStrByKey("faction_input"))
        editDesk:setText("")
        editDesk:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

        local closeCallBack = function()
            if self.activeLayer then
                removeFromParent(self.activeLayer)
                self.activeLayer = nil
            end
        end

        local okBtnCall = function()
            local textCode = editDesk:getText()
            if string.len(textCode) > 0 then
                g_msgHandlerInst:sendNetDataByTable(LOGIN_CG_ACTIVE_USER, "LoginActiveUserReq", {openID = LoginScene.user_name, activeCode = textCode})
                addNetLoading(LOGIN_CG_ACTIVE_USER, LOGIN_SC_ACTIVE_USER)
            else
                TIPS({ type = 1  , str = "输入内容有误，请重新输入" , isMustShow = true })     
            end
        end

        local itemMenu = createMenuItem(retSprite, "res/component/button/50.png", cc.p(100, 45), closeCallBack)
        createLabel(itemMenu, game.getStrByKey("cancel"), getCenterPos(itemMenu), nil, 22, true)

        itemMenu = createMenuItem(retSprite, "res/component/button/50.png", cc.p(315, 45), okBtnCall)
        createLabel(itemMenu, game.getStrByKey("sure"), getCenterPos(itemMenu), nil, 22, true)
        SwallowTouches(retSprite)
    else
        TIPS({str = game.getStrByKey("active_code_error"), isMustShow = true })
    end
end

function LoginScene:showAccountError(strErr, intTime)
    local backCallBack = function()
        self:ChangeUserID()
    end

    local str = string.format(game.getStrByKey("open_door_role_lock1"), "", strErr)
    if intTime == -1 then
        str = str .. game.getStrByKey("open_door_role_lock4")
    elseif intTime > 0 then
        str = str ..game.getStrByKey("open_door_role_lock3").. os.date("%Y-%m-%d %H:%M:%S", intTime)
    end

    MessageBox( str, game.getStrByKey("sure"), backCallBack)    
end

function LoginScene:registerLoginMsg()
    -----------------------------------------
    --网络回调函数
    -----------------------------------------
    local onRegister = function ( luaBuffer )
        -- body
        local retTable = g_msgHandlerInst:convertBufferToTable("LoginCreateUserRet", luaBuffer)
        userInfo.userId = retTable.ret
        print("onRegister", userInfo.userId)
        CommonSocketClose()
        if userInfo.userId > 0 then
            if self.status == "login" then
                self:changeUIStatus("server_select")
                self.onServerListJsonInfo(true, "", "")
            else
                TIPS({ str = game.getStrByKey("wrong_account") , isMustShow = true })
            end
        elseif userInfo.userId == 0 then

            if self.status == "login" then
                TIPS({ str = game.getStrByKey("wrong_account") , isMustShow = true })
            elseif self.status == "register" then
                self:changeUIStatus("login")
                TIPS({ str = game.getStrByKey("login_tip_register_success") , isMustShow = true })
            else
                self:changeUIStatus("login")
            end
        else
            if userInfo.userId == -1 then
                --账号错误
                if self.status == "register" then
                    TIPS({ type = 1 , str = game.getStrByKey("exist_account") , isMustShow = true })
                else
                    TIPS({ type = 1 , str = game.getStrByKey("wrong_account") , isMustShow = true })
                end
            elseif userInfo.userId == -2 then
                TIPS({ type = 1 , str = game.getStrByKey("login_over_time") , isMustShow = true })
            elseif userInfo.userId == -3 then
                TIPS({ type = 1 , str = game.getStrByKey("close_account") , isMustShow = true })
            elseif userInfo.userId == -4 then
                self:changeUIStatus("login")
                TIPS({ type = 1 , str = game.getStrByKey("login_tip_register_success") , isMustShow = true })
            end
            self:ChangeUserID()
        end
    end
    local onLogin = function(luaBuffer) 
        userInfo.userId = luaBuffer:popInt()
        print("onLogin", userInfo.userId)
        if userInfo.userId > 0 then
            --服务器列表
            local ret = {openID = LoginScene.user_name, sessionID = LoginScene.user_pwd, serverID = userInfo.serverId, worldID = userInfo.serversreal}
            g_msgHandlerInst:sendNetDataByTable(LOGIN_CS_CHOOSEWORLD, "LoginChooseWorldReq", ret)
            --saveLoginServerId()
        else 
            CommonSocketClose()
            --LuaSocket:getInstance():closeSocket()
            if userInfo.userId == -1 then
                --账号错误
                TIPS({ type = 1 , str = game.getStrByKey("wrong_account") , isMustShow = true })
            elseif userInfo.userId == -2 then
                TIPS({ type = 1 , str = game.getStrByKey("login_over_time") , isMustShow = true })
            elseif userInfo.userId == -3 then
                TIPS({ type = 1 , str = game.getStrByKey("close_account") , isMustShow = true })
            end
            self:ChangeUserID()
        end
    end
    local onSelectServer = function(luaBuffer)
        removeNetLoading()

        local retTable = g_msgHandlerInst:convertBufferToTable("LoginGatewayInfoRet", luaBuffer)        
        local result = retTable.result
        userInfo.userId = retTable.userID
        print("onSelectServer", userInfo.userId)
        if result == 0 then
            local gatewayAddr = retTable.loginIpAddr
            local port = retTable.port
            userInfo.sessionID = retTable.sessionID
            userInfo.sessionToken = retTable.sessionToken
            userInfo.startTick = retTable.startTick
            function readRecords(tempRoles)
                local records = {}
                local recordcnt = tempRoles and tablenums(tempRoles) or 0
                setRoleInfo(4)
                for idx = 1, recordcnt do       
                    local record = {}
                    local tempRoleInfo = tempRoles[idx]
                    
                    record.RoleID = tempRoleInfo.roleID
                    record.Name = tempRoleInfo.name
                    record.Level = tempRoleInfo.level
                    record.WorldName = tempRoleInfo.worldName
                    record.School = tempRoleInfo.school
                    record.Sex = tempRoleInfo.sex
                    record.MapID = tempRoleInfo.mapID

                    records[idx] = record  
                    setRoleInfo(3, record.RoleID, record.Level, record.School, record.Name)
                end

                return recordcnt,records
            end

            local tempRoles = retTable.roles
            local recordcnt,roleTable = readRecords(tempRoles)
            dump(roleTable, "roleTable")

            local connCb = function()
                if userInfo.isReconn then
                    userInfo.isReconn = nil
                    sendLoadPlayerMsg(userInfo.userId,roleTable[1]["RoleID"],userInfo.serverId,userInfo.serversreal,userInfo.startTick,__getMapIDByRoleId(roleTable[1]["RoleID"]),userInfo.sessionID,roleTable[1]["Name"])
                    removeNetLoading()
                    --语聊重连
                    release_print("yuexiaojun VoiceApollo:GameReconnected")
                    VoiceApollo:GameReconnected()
                else
                    g_roleTable = roleTable
                    print(userInfo.serverId)
                    if g_roleTable and #g_roleTable > 0 then
                        if G_OLD_CREATE_ROLE then
                            game.goToScenes("src/login/CreateRoleFirst");
                        else
                            game.goToScenes("src/login/NewCreateRoleEndScene");
                        end
                    else
                        if G_OLD_CREATE_ROLE then
                            game.goToScenes("src/login/CreateRole");
                        else
                            game.goToScenes("src/login/NewCreateRoleScene");
                        end
                    end 
                    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_SESSION)
                    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_GATEWAY_INFO)
                    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_WORLDUPDATE)
                    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_ACTIVE_USER)
                end
                saveLoginServerId()
            end
            userInfo.connCb = connCb
            CommonSocketClose()
            --LuaSocket:getInstance():closeSocket()
            userInfo.gatewayAddr = gatewayAddr
            userInfo.gatewayPort = port
            print("gatewary", gatewayAddr, port)

            if GameSocketLunXun then
                LuaSocket:getInstance():openSocket(2,0,port, gatewayAddr, "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194")
            else
                LuaSocket:getInstance():openSocket(0,0,port, gatewayAddr)
            end
            userInfo.connType = ENTER
        else--错误码
            print("SelectServer  error!  . . . result", result)
            -- -1  服务器维护中
            -- -2  账号验证失败！
            -- -3  封号
            -- -4  排队人数太多！
            -- -5  激活码
            if result==-1 then
                TIPS({ type = 1 , str = game.getStrByKey("server_full") , isMustShow = true })
            elseif result==-2 then 
                TIPS({ type = 1 , str = game.getStrByKey("tip_open_server") , isMustShow = true })
                self:ChangeUserID()
            elseif result==-3 then
                local errorStr = retTable.lockreason
                local timeInt = retTable.lockdate
                self:showAccountError(errorStr, timeInt)
            elseif result==-4 then
                TIPS({ type = 1 , str = game.getStrByKey("tip_open_server2"), isMustShow = true  })
            elseif result==-5 then
                --需要激活.
                print("需要激活")
                local currS = cc.Director:getInstance():getRunningScene()
                currS:openActiveCodeLayer()
            elseif result==-6 then
                local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 15300 , 27 } )
                TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msg_item.msg , isMustShow = true})                 
            end
        end

    end

    local onLineUp = function(luaBuffer)
        print("onLineUp")
        local retTable = g_msgHandlerInst:convertBufferToTable("LoginWorldUpdateRet", luaBuffer)
        local currPos = retTable.rank
        --local allNum  = retTable.loginUserNum
        local time = retTable.queuiWaitTime
        --local currPos, time = math.random(50, 100), math.random(0, 280)
        -- dump(currPos,"currPos")
        -- dump(allNum,"allNum")
        -- dump(time,"time")
        local setMidPosition = function(params)
            local nodes = params.nodes
            local centerWidth = params.width

            local totalWidth = 0
            for i=1,#nodes do
                totalWidth = totalWidth + nodes[i]:getContentSize().width
            end

            local currPosition = 0
            local starPosition = centerWidth/2 - totalWidth/2
            for i=1,#nodes do
                nodes[i]:setPositionX(starPosition + currPosition)
                nodes[i]:setAnchorPoint( cc.p(0, nodes[i]:getAnchorPoint().y) )
                currPosition = currPosition + nodes[i]:getContentSize().width
            end
        end
        local r_size = {width = 414, height = 286}
        local currS = cc.Director:getInstance():getRunningScene()
        if currS then -- allNum
            if not self.lineupBg then
                local temp = createSprite(currS,"res/common/5.png",cc.p(g_scrSize.width/2,g_scrSize.height/2+30),cc.p(0.5,0.5),9)
                r_size = temp:getContentSize()
                createLabel(temp, "登录排队", cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)
                self.lineupBg = temp
                local lab1 = createLabel(temp, "服务器:  ", cc.p(0, 220), nil , 20)
                local lab2 = createLabel(temp, " " .. userInfo.serverName, cc.p(0, 220), nil, 20)

                lab1:setColor(MColor.lable_yellow)
                lab2:setColor(MColor.yellow)
                setMidPosition( {nodes = {lab1, lab2}, width = r_size.width} )

                self.currPosLab1 = createLabel(temp, "目前排在", cc.p(0, 180), cc.p(0.5, 0.5) , 20)
                self.currPosLab2 = createLabel(temp, "第"..currPos.."名", cc.p(0, 180), cc.p(0.5, 0.5) , 20) --","..allNum.."名"
                --self.currPosLab3 = createLabel(temp, "勇士正在排队", cc.p(0, 180), cc.p(0.5, 0.5) , 20)
                self.currPosLab1:setColor(MColor.lable_yellow)
                --self.currPosLab3:setColor(MColor.lable_yellow)                
                setMidPosition( {nodes = {self.currPosLab1, self.currPosLab2}, width = r_size.width})
                
                self.lineUpTime1 =  createLabel(temp, "预计等待时间: ", cc.p(0, 135), nil, 20)
                if time > 0 then
                    self.lineUpTime2 =  createLabel(temp, secondParse(time), cc.p(0, 135), nil, 20)
                else
                    self.lineUpTime2 =  createLabel(temp, "< 1分钟", cc.p(0, 135), nil, 20)
                end
                self.lineUpTime1:setColor(MColor.lable_yellow)
                self.lineUpTime2:setColor(MColor.green)
                setMidPosition({nodes = {self.lineUpTime1, self.lineUpTime2}, width = r_size.width})

                local showList = function()
                    userInfo.connStatus = UNCONNECT
                    userInfo.connType = LOGIN                    
                    CommonSocketClose()
                    --LuaSocket:getInstance():closeSocket()
                    removeFromParent(temp)
                    self.lineupBg = nil
                    self.currPosLab2 = nil
                    self.lineUpTime2 = nil
                end
                local tempItem = createMenuItem( temp , "res/component/button/50.png" , cc.p(r_size.width/2, 45), showList ) 
                createLabel(tempItem, "退出排队", getCenterPos(tempItem), nil ,23,true)
                registerOutsideCloseFunc(temp, function() end, true)
            else
                if self.currPosLab2 then
                    self.currPosLab2:setString("第"..currPos.."名") -- ,"..allNum.."名"
                    setMidPosition( {nodes = {self.currPosLab1, self.currPosLab2}, width = r_size.width})
                end
                if self.lineUpTime2 then
                    if time > 0 then
                        self.lineUpTime2:setString(secondParse(time))
                    else
                        self.lineUpTime2:setString("< 1分钟")
                    end           
                    setMidPosition({nodes = {self.lineUpTime1, self.lineUpTime2}, width = r_size.width})        
                end
            end
        end
    end

    local onActiveRet = function(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("LoginActiveUserRet", luaBuffer)
        local ret = retTable.code
        if ret == 0 then
            TIPS({ str = game.getStrByKey("active_code_suc") , isMustShow = true })
            if self.activeLayer then
                removeFromParent(self.activeLayer)
                self.activeLayer = nil
            end
        elseif ret == -1 then
            TIPS({ str = game.getStrByKey("active_code_fal1") , isMustShow = true })
        elseif ret == -2 then
            TIPS({ str = game.getStrByKey("active_code_fal2") , isMustShow = true })
        end
    end
    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_CREATEUSER, onRegister)
    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_SESSION, onLogin)
    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_GATEWAY_INFO, onSelectServer)
    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_ACTIVE_USER, onActiveRet)
    g_msgHandlerInst:registerMsgHandler(LOGIN_SC_WORLDUPDATE, onLineUp)
end

return LoginScene
