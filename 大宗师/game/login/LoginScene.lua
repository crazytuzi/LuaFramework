--[[
--
-- @authors shan
-- @date    2014-06-16 15:19:47
-- @version
--
--]]
require("utility.CCBReaderLoad")
require("utility.Func")
require("network.NetworkHelper")
require("game.game")
require("data.data_serverurl_serverurl")

--[[--------------------------------------------]]

local MANAGE_STATUS_1 = 1 -- 爆满
local MANAGE_STATUS_2 = 2 -- 忙碌
local MANAGE_STATUS_3 = 3 -- 正常
local MANAGE_STATUS_4 = 4 -- 维护

--[[--------------------------------------------]]


local function resetData()
    require("game.Bag.BagCtrl").setRequest(false)
    require("game.Spirit.SpiritCtrl").clear()
end

local LoginScene = class("LoginScene", function ( ... )
    return display.newScene("LoginScene")
end)

function LoginScene:ctor()

    if GAME_DEBUG then
        CCFileUtils:sharedFileUtils():setPopupNotify(true)
    end

    game.runningScene = self
    self:init()
    GameAudio.preloadMusic(ResMgr.getSFX(SFX_NAME.u_queding))
    GameAudio.playMainmenuMusic(true)

    -- reset gamestate
    resetData()
    GameStateManager:resetState()
    PageMemoModel.Reset()
end

--[[
    与服务器通信，验证登陆状态
]]
function LoginScene:verifyLogin( callback )
    local channelID = checkint(CSDKShell.getChannelID())
    local deviceinfo = CSDKShell.GetDeviceInfo()

    local uac = game.player.m_sdkID
    local acc = game.player.m_sdkID
    local function loadStorge( ... )
        uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
        acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid") 
    end
	if(GAME_DEBUG == true) then
		if(device.platform == "mac" or device.platform == "windows") then
		   loadStorge()
		end
	end
    if(device.platform == "android") then
        if(GAME_DEBUG == true and ANDROID_NO_SDK == true) or (CSDKShell.GetSDKTYPE() == SDKType.SIMULATOR) then
            loadStorge()
        end
    end



    local network = require ("utility.GameHTTPNetWork").new()
    local msg = {}
    msg.m          = "login"
    msg.a          = "login"
    msg.platformID = CSDKShell.getChannelID()
    msg.SessionId  = game.player.m_sessionID
    msg.acc        = acc
    msg.uac        = uac
    msg.deviceinfo = deviceinfo
    msg.loginName  = game.player.m_loginName

    dump(msg)

    local function cb( data )
		print("LOGIN: CB----------------------------->>>>>>")
        if(data.errorCode == 101) then
                device.showAlert("提示", "sdk异常，请重新登录！","好的",function ( ... )                     
                    -- CSDKShell.Login()        
                    game.player.m_logout = true
                    display.replaceScene(require("app.scenes.VersionCheckScene").new())
                    CSDKShell.onLogout()
                end)
        end
        dump(data)
        self._serverlist = {}
        if(data.errCode ~= 0) then
            dump(data)
            show_tip_label(data_error_error[data.errCode].prompt)
            return
        end
        -- 有些sdk无法从客户端获取登录名，所以需要从服务器获取
        game.player.m_loginName = data.rtnObj.user.lac

        if tostring(CSDKShell.getChannelID()) ~= CHANNELID.TEST then   
            game.player:setUid(data.rtnObj.user.acc) 
            if data.rtnObj.user.extend ~= nil then 
                game.player:setExtendData(data.rtnObj.user.extend)
                dump(data.rtnObj.user.extend) 
            end
        end 

        if GAME_DEBUG == true or DEV_BUILD == true then
            self._serverlist = data.rtnObj.servers
            dump(self._serverlist)
        else            
            --[[
                debugID 
                1.正式
                2.玩家服务器
                3.渠道
            ]]
            local debugID = 1 -- 封测服
            if(CHANNEL_BUILD == true) then
                debugID = 3  -- 渠道包
            end
            self._serverlist = {}
                
            for k, v in ipairs(data.rtnObj.servers) do
                if v.debug == debugID then
                    table.insert(self._serverlist, v)
                end
            end
            dump(self._serverlist)
        end
        -- 设置默认服务器id
        game.player.m_defaultServer = CCUserDefault:sharedUserDefault():getIntegerForKey("dfs", 1)            
        if(game.player.m_defaultServer == nil or game.player.m_defaultServer == 0) then
            game.player.m_defaultServer = 1
        else
            local len = CCUserDefault:sharedUserDefault():getIntegerForKey("serlen",0)
            local currentLen = #self._serverlist

            if(len > 0 and currentLen > len) then
                game.player.m_defaultServer = game.player.m_defaultServer + (currentLen - len)
            end

        end
        device.hideActivityIndicator()
        -- show_tip_label(game.player.m_defaultServer)
        self:onSelectedServer(game.player.m_defaultServer)
        if callback then
            callback()
        end
    end

    device.showActivityIndicator()
    local _loginUrl = data_serverurl_serverurl[channelID].loginUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[channelID].loginUrldev                
    end
    network:SendRequest(1,msg, cb, nil, _loginUrl)

    printf(_loginUrl)
end

--[[

    选择服务器，列表刷新
]]
function LoginScene:refreshServerList( callback )
    local channelID = checkint(CSDKShell.getChannelID())
    local deviceinfo = CSDKShell.GetDeviceInfo()

    
    local acc = game.player.m_uid
    if(device.platform == "mac" or device.platform == "windows") then
        uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
        acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid")        
    end

    if(GAME_DEBUG == true and ANDROID_NO_SDK == true) then
        uac = CCUserDefault:sharedUserDefault():getStringForKey("accid")
        acc = "simulate__" .. CCUserDefault:sharedUserDefault():getStringForKey("accid")         
    end

    local network = require ("utility.GameHTTPNetWork").new()
    local msg = {}
    msg.m          = "login"
    msg.a          = "list"
    msg.platformID = CSDKShell.getChannelID()
    msg.SessionId  = game.player.m_sessionID
    msg.acc        = acc


    local function cb( data )
        
        if( data.errCode ~= nil and data.errCode ~= 0) then
            dump(data)
            show_tip_label(data_error_error[data.errCode].prompt)
            return
        end
        -- 有些sdk无法从客户端获取登录名，所以需要从服务器获取
        -- game.player.m_loginName = data.rtnObj.user.lac

        -- if CSDKShell.getChannelID() ~= CHANNELID.TEST then             
        --     game.player:setUid(data.rtnObj.user.acc) 
        -- end 

        if GAME_DEBUG == true or DEV_BUILD == true then
            self._serverlist = data.rtnObj.servers
            dump(self._serverlist)
        else            
            --[[
                debugID 
                1.正式
                2.玩家服务器
                3.渠道
            ]]
            local debugID = 1 -- 封测服
            if(CHANNEL_BUILD == true) then
                debugID = 3  -- 渠道包
            end
            self._serverlist = {}
                
            for k, v in ipairs(data.rtnObj.servers) do
                if v.debug == debugID then
                    table.insert(self._serverlist, v)
                end
            end
            dump(self._serverlist)
        end
        -- 设置默认服务器id

        if callback then
            callback()
        end
    end


    local _loginUrl = data_serverurl_serverurl[channelID].loginUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[channelID].loginUrldev                
    end
    network:SendRequest(1,msg, cb, nil, _loginUrl)

end

function LoginScene:onEnter()
    game.runningScene = self
    -- 播放背景音乐 
    GameAudio.playMainmenuMusic(false)
    local deviceInfo = CSDKShell.GetDeviceInfo()
    if(game.player.m_logout == true) then
        game.player.m_logout = false
        CSDKShell.logout()
    end
    
end

function LoginScene:onSelectedServer(index)
    self._rootnode["selectServer"]:setEnabled(true)
    self._rootnode["bottomNode"]:setVisible(true)
    if index then
        if self._serverlist[index].status == MANAGE_STATUS_4 then
            show_tip_label(self._serverlist[index].msg)
            -- return
        end

        if  self._serverlist[index] then
            if game.player.m_defaultServer ~= index then 
                game.player.m_isChangedServer = true 
            end 

            game.player.m_serverID = self._serverlist[index].idx
            game.player.m_serverName = self._serverlist[index].name
            game.player.m_zoneID = self._serverlist[index].zoneId
            game.player.m_defaultServer = index

            CCUserDefault:sharedUserDefault():setIntegerForKey("dfs", game.player.m_defaultServer)   
            CCUserDefault:sharedUserDefault():setIntegerForKey("serlen", #self._serverlist)   
            self._rootnode["chooseServerName"]:setString(self._serverlist[index].name)
            self._rootnode["serverState"]:setDisplayFrame(display.newSpriteFrame(string.format("login_state_%d.png", self._serverlist[index].status)))
            ServerInfo.SERVER_URL = string.format("http://%s:%s/", self._serverlist[index].ip, self._serverlist[index].port)
        end
    end
end

function LoginScene:init()

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local contentNode = CCBuilderReaderLoad("login/login_scene.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, display.height))
    contentNode:setPosition(display.cx, display.cy)
    self:addChild(contentNode, 1)
--
--    local effect = ResMgr.createArma({
--        resType = ResMgr.UI_EFFECT,
--        armaName = "jiazai",
--        isRetain = false,
--        finishFunc = function()
--
--        end
--    })
--    effect:setPosition(display.cx, display.cy)
--    self:addChild(effect, 100)

    self._rootnode["versionLabel"]:setString("V" .. DISPLAY_VERSION)
    --  背景
    local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")
    local bottomLogoOffY = 0
    if (display.widthInPixels / display.heightInPixels) == 0.75 then
        bgSprite:setPosition(display.cx, display.height*0.55)
        bgSprite:setScale(0.9)


    elseif(display.widthInPixels == 640 and display.heightInPixels == 960) then
        bgSprite:setPosition(display.cx, display.height*0.55)

    else
        bgSprite:setPosition(display.cx, display.cy)
        self._rootnode["bottomNode"]:setPositionY(display.height*0.065)
    end
    self:addChild(bgSprite)

    --  game title logo anim  
    local logoName_default = "jiemian_biaotidonghua"
    local xunhuanname = "jiemian_biaotidonghua_xunhuan"
    if isrexueproj() then
        logoName_default = "jiemian_biaotidonghua_rexue"
    end

    if CSDKShell.GetSDKTYPE() == SDKType.ANDROID_LENOVO then
        logoName_default = "luandouwuxia"
        xunhuanname = "luandouwuxia_xunhuan"
    end

    self.logoAnim = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT, 
        armaName = logoName_default, 
        isRetain = true ,
        finishFunc = function ( ... )            
            if isrexueproj() == false then
                self.logoAnim:removeSelf()
                local logo2 = ResMgr.createArma({
                    resType = ResMgr.UI_EFFECT,
                    armaName = xunhuanname,
                    isRetain = true
                    })

                logo2:setPosition(self._rootnode["tag_logo_pos"]:getContentSize().width/2, self._rootnode["tag_logo_pos"]:getContentSize().height/2)
                self._rootnode["tag_logo_pos"]:addChild(logo2)
            end
        end
    })
    self.logoAnim:setPosition(self._rootnode["tag_logo_pos"]:getContentSize().width/2, self._rootnode["tag_logo_pos"]:getContentSize().height/2)
    self._rootnode["tag_logo_pos"]:addChild(self.logoAnim)

    local heroAnim = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT, 
        armaName = "jiemian_dadoudonghua", 
        isRetain = true 
    })
    heroAnim:setPosition(self._rootnode["tag_anim_pos"]:getContentSize().width/2, self._rootnode["tag_anim_pos"]:getContentSize().height/2)
    self._rootnode["tag_anim_pos"]:addChild(heroAnim)
    if (display.widthInPixels / display.heightInPixels) == 0.75 then
        heroAnim:setScale(0.8)
    end
    --  进入游戏
    -- self._rootnode["enterGameBtn"]:addHandleOfControlEvent(enterGame, CCControlEventTouchUpInside)
    self._enterGame = false
    self._rootnode["enterGameBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function ( ... )
        if(self._serverlist == nil) then
            show_tip_label("连接中...")
            return
        end
        if self._serverlist[game.player.m_defaultServer].status == MANAGE_STATUS_4 then
            show_tip_label(self._serverlist[game.player.m_defaultServer].msg)
            return
        end
        if(self._enterGame == false) then
            self._enterGame = true
            self:enterGame()
            self:performWithDelay(function ( ... )
                self._enterGame = false
            end, 1)
        end
    end)

    --  切换账号
    self._rootnode["switchAccBtn"]:addHandleOfControlEvent(function()
    end, CCControlEventTouchDown)

    local function selectServerLayer()   
        
        local function serverLayer( ... )
            self._rootnode["selectServer"]:setEnabled(false)
            self._rootnode["bottomNode"]:setVisible(false)
            if(self:getChildByTag(100) == nil) then
                local layer = require("game.login.ServerChooseLayer").new(self._serverlist, handler(self, self.onSelectedServer))
                self:addChild(layer, 100, 100)
            end
        end

        self:refreshServerList(serverLayer)
    end

    self._rootnode["selectServer"]:addHandleOfControlEvent(function()
        if(game.player.m_defaultServer ~= nil) then
            if self._serverlist ~= nil  then
                selectServerLayer()
            else
                self:verifyLogin(function()
                    selectServerLayer()
                end)
            end
        end
    end, CCControlEventTouchDown)

    if device.platform == "android" then
        local layer = display.newLayer()
        layer:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                CSDKShell.back(function(a)
                    dump(a)
                end)
            end
        end, 0.5)
        self:addChild(layer)
        layer:setKeypadEnabled(true)
    end
end

function LoginScene:onExit()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    display.removeUnusedSpriteFrames()

    ResMgr.ReleaseUIArmature( "jiemian_biaotidonghua" )
    ResMgr.ReleaseUIArmature( "jiemian_biaotidonghua_xunhuan" )
    ResMgr.ReleaseUIArmature( "jiemian_biaotidonghua_rexue" )
    ResMgr.ReleaseUIArmature( "jiemian_dadoudonghua" )
end

function LoginScene:enterGame()
    -- 获取3rd sdk 用户信息
    if ServerInfo.SERVER_URL then
        printf(ServerInfo.SERVER_URL)
        RequestHelper.game.loginGame({
            sessionId  = game.player.m_sessionID,
            uin        = game.player.m_uid,
            platformID = game.player.m_platformID,
            callback   = function ( data )
                if data["0"] == "" then 
                    game.player:setAppOpenData(data.open) 

                    local isNewUser = 1
                    -- 为模拟器用户 特殊处理
					if ANDROID_DEBUG then
						isNewUser = data["3"]
                    elseif (device.platform == "mac" or device.platform == "windows") then
                        if(GAME_DEBUG == true) then
                            local name = CCUserDefault:sharedUserDefault():getStringForKey("playerName")
                            if(name ~= "") then
                                isNewUser = 2
                            end
                        end
--                    elseif device.platform == "android" then
--                        local name = CCUserDefault:sharedUserDefault():getStringForKey("playerName")
--                        if(name ~= "") then
--                            isNewUser = 2
--                        end
                    else
                        isNewUser = data["3"]
                    end

                    if(isNewUser == 1) then  -- 1 新建用户
                        -- game.player.m_uid = data["5"]
                        -- gameworks 登陆
                        DramaMgr.isSkipDrama = false
                        local channelPrefix = CSDKShell.getChannelID()
                        SDKGameWorks.Login( channelPrefix .."_".. game.player.m_uid, 2, "1")
                        DramaMgr.createChoseLayer(data)
                        CSDKShell.HideToolbar()
                    elseif(isNewUser == 2) then -- 2 已创建用户
                        -- game.player.m_uid = data["1"].account
                        -- gameworks 登陆
                        SDKGameWorks.Login(game.player.m_uid, 2, "1")
                        if(data["4"] ~= nil and data["4"] ~= "") then
                            game.player.m_serverKey = data["4"]
                        end
                        DramaMgr.request(isNewUser, data)
                    end
                    CSDKShell.EnterGame()
                else
                    local errorCode = data["0"]
                    if(errorCode == "91_11" or errorCode == "91_5" or errorCode == "91_0") then -- 91 sessionid 过期，需要重新登录验证
                        CSDKShell.Login()
                    elseif(errorCode == "PP_0xE0000101") then -- pp会话超时
                        CSDKShell.Login()
                    end
                end
            end
        })
    else
        show_tip_label("连接中...")
    end
end

function LoginScene:onEnterTransitionFinish()
    print("+>--------------LoginScene:onEnterTransitionFinish()")
    local function reLogin(  )
		print("+>--------------LoginScene:onEnterTransitionFinish() reLogin")
       CSDKShell.Login()
        local scheduler = require("framework.scheduler")
        local loginSche
        loginSche = scheduler.scheduleGlobal(function()
            if(CSDKShell.isLogined()) then
                local info = CSDKShell.userInfo()
                if(info ~= nil) then
                    game.player:initBaseInfo(info)
                end
                self:verifyLogin()
                scheduler.unscheduleGlobal(loginSche)
            end
        end, 0.1)
    end

    if(CSDKShell.isLogined()) then
		print("+>--------------LoginScene:onEnterTransitionFinish() isLogined")
        local info = CSDKShell.userInfo()
        
        if(info ~= nil) then
            game.player:initBaseInfo(info)
        end
        -- 如果第一次获取userinfo不成功，再登陆一次，
        if(game.player.m_sdkID == "" or game.player.m_sdkID == nil) then
            -- 排除从服务器获取uid的 sdk
            if(CSDKShell.getSDKIdFromServer() == false) then
                reLogin()
            else
                self:verifyLogin() 
            end
        else
            self:verifyLogin()    
        end
    end
end


return LoginScene