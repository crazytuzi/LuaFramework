require"Lang"

require "SDK"

local KEY_ACCOUNT_NAME = "account"

UILogin = { }

UILogin.uiRoot = nil
UILogin.uiEnter = nil
UILogin.uiSrv = nil
UILogin.uiSrvIcon = nil
UILogin.uiSrvName = nil
UILogin.uiSrvShow = nil
UILogin.uiName = nil
UILogin.uiBack = nil
UILogin.uiQQ = nil
UILogin.uiWX = nil
UILogin.uiAnim = nil

UILogin.http = nil
UILogin.params = nil
UILogin.isActivated = nil
UILogin.activationCode = nil
UILogin.token = nil
UILogin.serverSuggest = nil
UILogin.serverHistory = nil
UILogin.serverListAll = nil
UILogin.serverCurrent = nil

local function cleanSplashAnim()
    if not tolua.isnull(UILogin.uiAnim) then   
        local di = SDK.getDeviceInfo()
        if di.packageName == "com.y2game.doupocangqiong" then
           -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("brushlist/splash/fm_anim.ExportJson")
        elseif di.packageName == "com.dpdl.20161009.zy" then
           -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("brushlist/splashNew/fm_anim.ExportJson")
        else
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/splash/fm_anim.ExportJson")
        end
        ccs.ArmatureDataManager:getInstance():removeArmatureData(UILogin.uiAnim:getAnimation():getCurrentMovementID())

        UILogin.uiAnim:removeFromParent()
        UILogin.uiAnim = nil
    end
end

local function playSplashAnim()
    local uiRoot = UILogin.uiRoot
    local di = SDK.getDeviceInfo()
    if di.packageName == "com.y2game.doupocangqiong" then
      --  ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("brushlist/splash/fm_anim.ExportJson")
          local imageFm_di = ccui.ImageView:create("ui/fm_logo.png")
          imageFm_di:setPosition(uiRoot:getContentSize().width / 2, uiRoot:getContentSize().height / 2)
          uiRoot:addChild(imageFm_di)
          return
    elseif di.packageName == "com.dpdl.20161009.zy" then
      -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("brushlist/splashNew/fm_anim.ExportJson")
         local imageFm_di = ccui.ImageView:create("ui/fm_qiankun.png")
         imageFm_di:setPosition(uiRoot:getContentSize().width / 2, uiRoot:getContentSize().height / 2)
         uiRoot:addChild(imageFm_di)
         return
    else
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/splash/fm_anim.ExportJson")
    end

    UILogin.uiAnim = ccs.Armature:create("fm_anim")
    UILogin.uiAnim:getAnimation():playWithIndex(0)
    UILogin.uiAnim:setPosition(uiRoot:getContentSize().width / 2, uiRoot:getContentSize().height / 2)
    uiRoot:addChild(UILogin.uiAnim)
end

local function showActivationInput()
    UIManager.pushScene("ui_activation", true)
end

function UILogin.setCurrentServerItem(serverItem)
    UILogin.serverCurrent = serverItem
    UILogin.uiSrvName:setString(serverItem.name)
end

function UILogin.onLoginOurServer()
    UIManager.hideLoading()
    if UILogin.http and UILogin.http.status == 200 then
        local ret = json.decode(UILogin.http.response)
        print("UILogin.http.response:",UILogin.http.response)
        if ret.result == 0 then
            ret.servers_history = ret.servers_history or { }
            UILogin.isActivated = true
            UILogin.token = ret.security_code
            UILogin.serverSuggest = ret.servers_suggest
            UILogin.serverHistory = ret.servers_history
            UILogin.serverListAll = ret.servers_all
            if #ret.servers_history > 0 then
                UILogin.setCurrentServerItem(ret.servers_history[1])
            else
                UILogin.setCurrentServerItem(ret.servers_suggest[1])
            end
            UILogin.uiSrv:setVisible(true)
            UILogin.uiEnter:setTitleText(Lang.ui_login1)
            if SDK.getChannel() == "qq" then
                UILogin.uiEnter:setVisible(true)
                UILogin.uiQQ:setVisible(false)
                UILogin.uiWX:setVisible(false)
            end
            SDK.saveNotifyUri(ret.notifyUri)
            -- 保存支付回调地址
            SDK.saveId(ret.user_id)
            if SDK.getChannel() == "kupai" then
                -- kupai渠道保存accessToken和openId
                SDK.saveTokenAndId(ret.customData)
            end
            local info = { "v1", ret.user_id, ret.username }
            SDK.doUserTD(info)
        elseif ret.result == 1 then
            UILogin.isActivated = false
            utils.PromptDialog(nil, ret.message and ret.message or Lang.ui_login2)
            UILogin.params = nil
        elseif ret.result == 2 then
            UILogin.isActivated = false
            showActivationInput()
            utils.PromptDialog(nil, ret.message and ret.message or Lang.ui_login3)
        elseif ret.result == 3 then
            UILogin.isActivated = false
            showActivationInput()
            -- utils.PromptDialog(nil,ret.message and ret.message or "需要激活码！")
        elseif ret.result == 4 then
            UILogin.isActivated = false
            utils.PromptDialog(nil, ret.message and ret.message or Lang.ui_login4)
        end
    end
    UILogin.http = nil
end

function UILogin.doLoginOurServer()
    UIManager.showLoading()
    UILogin.http = cc.XMLHttpRequest:new()
    UILogin.http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local url = dp.LOGIN_URL .. "?" .. UILogin.params .. "&product_id=" .. tostring(cc.JNIUtils:getProductId())
    print("url:",url)
    local di = SDK.getDeviceInfo()

    url = url .. "&channel_sub=" .. di.packageName .. "&code_version=" .. dp.PROGRAM_VER
    if UILogin.activationCode then
        url = url .. "&active_code=" .. UILogin.activationCode
    end
    UILogin.http:open("GET", url)
    UILogin.http:registerScriptHandler(UILogin.onLoginOurServer)
    UILogin.http:send()
end

local function onLogin(string)
    if device.platform == "windows" or SDK.getChannel() == "dev" then
        local userName = string
        -- dp.SERVERS_IP =
        -- dp.SERVERS_PORT=
        dp.serverId = 0
        dp.serverName = Lang.ui_login5
        cc.UserDefault:getInstance():setStringForKey(KEY_ACCOUNT_NAME, userName)
        net.connect(dp.SERVERS_IP, dp.SERVERS_PORT, userName, nil)
    else
        if #string > 0 then
            UILogin.params = string
            UILogin.isActivated = false
            UILogin.activationCode = nil
            UILogin.token = nil
            UILogin.uiBack:setVisible(true)
            UILogin.doLoginOurServer()
        else
            UIManager.showToast(Lang.ui_login6)
        end
    end
end

function UILogin.init()
    UILogin.uiRoot = ccui.Helper:seekNodeByName(UILogin.Widget, "image_basemap")
    UILogin.uiEnter = ccui.Helper:seekNodeByName(UILogin.Widget, "btn_enter")
    UILogin.uiSrv = ccui.Helper:seekNodeByName(UILogin.Widget, "image_base_name")
    UILogin.uiSrvIcon = ccui.Helper:seekNodeByName(UILogin.Widget, "image_way")
    UILogin.uiSrvName = ccui.Helper:seekNodeByName(UILogin.Widget, "text_area")
    UILogin.uiSrvShow = ccui.Helper:seekNodeByName(UILogin.Widget, "text_choose")
    UILogin.uiBack = ccui.Helper:seekNodeByName(UILogin.Widget, "btn_back")
    UILogin.uiQQ = ccui.Helper:seekNodeByName(UILogin.Widget, "btn_qq")
    UILogin.uiWX = ccui.Helper:seekNodeByName(UILogin.Widget, "btn_weixin")

    if device.platform == "windows" or SDK.getChannel() == "dev" then
        UILogin.uiEnter:setPressedActionEnabled(true)
        UILogin.uiEnter:addTouchEventListener(
        function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local name = UILogin.uiName:getText()
                if #name > 0 then
                    SDK.doLogin(name, onLogin)
                else
                    UIManager.showToast(Lang.ui_login7)
                end
            end
        end
        )
        UILogin.uiName = cc.EditBox:create(UILogin.uiSrv:getContentSize(), cc.Scale9Sprite:create("ui/fm_xuanqu_tiao01.png"))
        UILogin.uiName:setPosition(UILogin.uiSrv:getPosition())
        UILogin.uiName:setPlaceHolder(Lang.ui_login8)
        UILogin.uiName:setMaxLength(10)
        UILogin.uiRoot:addChild(UILogin.uiName, 1)
        UILogin.uiSrv:removeFromParent()
        UILogin.uiSrv = nil
    else
        local function onButtonEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if SDK.getChannel() == "qq" then
                    if sender == UILogin.uiQQ then
                        if not UILogin.params then
                            SDK.doLogin("1", onLogin)
                        elseif not UILogin.isActivated then
                            -- todo or not token
                            UILogin.doLoginOurServer()
                        elseif UILogin.serverCurrent.state == 0 then
                            UIManager.showToast(Lang.ui_login9)
                        else
                            dp.SERVERS_IP = UILogin.serverCurrent.ip
                            dp.SERVERS_PORT = UILogin.serverCurrent.port
                            dp.serverId = UILogin.serverCurrent.id
                            dp.serverName = UILogin.serverCurrent.name
                            net.connect(dp.SERVERS_IP, dp.SERVERS_PORT, nil, UILogin.token)
                        end
                        return
                    elseif sender == UILogin.uiWX then
                        if not UILogin.params then
                            SDK.doLogin("2", onLogin)
                        elseif not UILogin.isActivated then
                            -- todo or not token
                            UILogin.doLoginOurServer()
                        elseif UILogin.serverCurrent.state == 0 then
                            UIManager.showToast(Lang.ui_login10)
                        else
                            dp.SERVERS_IP = UILogin.serverCurrent.ip
                            dp.SERVERS_PORT = UILogin.serverCurrent.port
                            dp.serverId = UILogin.serverCurrent.id
                            dp.serverName = UILogin.serverCurrent.name
                            net.connect(dp.SERVERS_IP, dp.SERVERS_PORT, nil, UILogin.token)
                        end
                        return
                    end
                end
                if sender == UILogin.uiEnter then
                    if not UILogin.params then
                        SDK.doLogin("params", onLogin)
                    elseif not UILogin.isActivated then
                        -- todo or not token
                        UILogin.doLoginOurServer()
                    elseif UILogin.serverCurrent.state == 0 then
                        UIManager.showToast(Lang.ui_login11)
                    else
                        dp.SERVERS_IP = UILogin.serverCurrent.ip
                        dp.SERVERS_PORT = UILogin.serverCurrent.port
                        dp.serverId = UILogin.serverCurrent.id
                        dp.serverName = UILogin.serverCurrent.name
                        net.connect(dp.SERVERS_IP, dp.SERVERS_PORT, nil, UILogin.token)
                    end
                elseif sender == UILogin.uiSrvShow then
                    UIManager.pushScene("ui_login_choose")
                elseif sender == UILogin.uiBack then
                    SDK.doLogout("")
                    -- todo 是否需要回调
                    UILogin.params = nil
                    UILogin.uiSrv:setVisible(false)
                    UILogin.uiEnter:setTitleText(Lang.ui_login12)
                    if SDK.getChannel() == "qq" then
                        UILogin.uiEnter:setVisible(false)
                        UILogin.uiQQ:setVisible(true)
                        UILogin.uiWX:setVisible(true)
                    end
                    UILogin.uiBack:setVisible(false)
                end
            end
        end
        UILogin.uiSrvShow:addTouchEventListener(onButtonEvent)
        UILogin.uiBack:addTouchEventListener(onButtonEvent)
        UILogin.uiEnter:addTouchEventListener(onButtonEvent)
        UILogin.uiEnter:setPressedActionEnabled(true)
        if SDK.getChannel() == "uc" then
            SDK.doLogin("params", onLogin)
        end
        if SDK.getChannel() == "qq" then
            UILogin.uiEnter:setVisible(false)
            UILogin.uiQQ:addTouchEventListener(onButtonEvent)
            UILogin.uiWX:addTouchEventListener(onButtonEvent)
        end
    end
end

function UILogin.setup()
    playSplashAnim()
    if device.platform == "windows" or SDK.getChannel() == "dev" then
        UILogin.uiName:setText(cc.UserDefault:getInstance():getStringForKey(KEY_ACCOUNT_NAME))
    else
        UILogin.params = nil
        UILogin.uiSrv:setVisible(false)
        UILogin.uiEnter:setTitleText(Lang.ui_login13)
        UILogin.uiBack:setVisible(false)
        if SDK.getChannel() == "qq" then
            UILogin.uiEnter:setVisible(false)
            UILogin.uiQQ:setVisible(true)
            UILogin.uiWX:setVisible(true)
        end
    end
    AudioEngine.playMusic("sound/login.mp3", true)

    if SDK.getChannel() == "yijie" then
        local di = SDK.getDeviceInfo()
        if UILogin.uiEnter and di.packageName == "com.doupo.anzhi" then
            UILogin.uiEnter:releaseUpEvent()
        end
    end
end

function UILogin.free()
    cleanSplashAnim()
    UILogin.params = nil
    UILogin.isActivated = nil
    UILogin.token = nil
    UILogin.activationCode = nil
    UILogin.serverSuggest = nil
    UILogin.serverHistory = nil
    UILogin.serverListAll = nil
    UILogin.serverCurrent = nil
end
