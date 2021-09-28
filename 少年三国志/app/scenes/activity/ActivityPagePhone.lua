local ActivityPagePhone = class("ActivityPagePhone", UFCCSNormalLayer )
KnightPic = require("app.scenes.common.KnightPic")
require "app.cfg.share_info"

local key = "34d5f52f7df9a630"
-- local testUrl = "http://10.0.9.140/"
local testUrl = "http://qavipsupport.youzu.com/"
local formalUrl = "http://vipsupport.youzu.com/"

ActivityPagePhone.AWARD = {{type=2,value=0,size=300},{type=1,value=0,size=500000}}

function ActivityPagePhone.create(...)
    return ActivityPagePhone.new("ui_layout/activity_ActivityPhone.json")
end


function ActivityPagePhone:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_PHONE_BIND_NOTI, self._onRecShareState, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_SHARE_FINISH, self._onRecShareAward, self) 

    self:updateAward()
end

function ActivityPagePhone:onLayerExit()
   uf_eventManager:removeListenerWithTarget(self)
   if self._schedule then
       GlobalFunc.removeTimer(self._schedule)
       self._schedule = nil
   end
end

function ActivityPagePhone:ctor(...)
    self.super.ctor(self, ...)

    self._bindStatus = -1
    self._ServerBindState = -1
    self._schedule = nil
    self._url = formalUrl
    self._layerMoveOffset  = 0
    -- if G_Setting:get("phone_test") == "1" then
    --     self._url = testUrl
    -- else
    --     self._url = formalUrl
    -- end
    self._url = G_Setting:get("phone_send_url")

    self:setMeinv()
    self:getLabelByName("Label_txt1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_input1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_input2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_phoneState"):createStroke(Colors.strokeBrown, 1)

    self:attachImageTextForBtn("Button_getAward","Image_getAward")

    self._bindLabel = self:getLabelByName("Label_phoneState")
    self._bindPanel = self:getPanelByName("Panel_phonebind")
    self._bindButton = self:getButtonByName("Button_getAward")
    self._sendButton = self:getButtonByName("Button_getCode")
    self._getImage = self:getImageViewByName("Image_get")
    self._getLabel = self:getLabelByName("Label_gettxt")
    self._getLabel:createStroke(Colors.strokeBrown, 1)
    
    self:registerBtnClickEvent("Button_getCode", function()
        -- self:httpPost("http://vipsupport.youzu.com/gameapp/queryBindPhoneStatus.json")
        if G_Me.activityData.phone.count <= 0 then
            local textfield = self:getTextFieldByName("TextField_input1")
            local txt = ""
            if textfield then 
             txt = textfield:getStringValue()
            end
            self:httpPost(self._url.."gameapp/sendDynamicCode.json",txt,nil,function ( data )
                G_Me.activityData.phone.count = data.body.sendInterval
                if G_SceneObserver:getSceneName() ~= "ActivityMainScene" then
                    return
                end
                self:updateView()
            end)
        end
    end)
    self:registerBtnClickEvent("Button_getAward", function()
        -- G_HandlersManager.activityHandler:sendRechargeBackGold()
        if self._bindStatus == 0 then
            local textfield1 = self:getTextFieldByName("TextField_input1")
            local txt1 = ""
            if textfield1 then 
                txt1 = textfield1:getStringValue()
            end
            local textfield2 = self:getTextFieldByName("TextField_input2")
            local txt2 = ""
            if textfield2 then 
                txt2 = textfield2:getStringValue()
            end
            self:httpPost(self._url.."/gameapp/bindPhone.json",txt1,txt2,function ( data )
                G_HandlersManager.shareHandler:sendShare(8)
                G_RoleService:bindMobile( txt1 )
                if G_SceneObserver:getSceneName() ~= "ActivityMainScene" then
                    return
                end
                self._bindStatus = 1
                self:updateView()
            end)
        elseif self._bindStatus == 1 then
            G_HandlersManager.shareHandler:sendShare(8)
            -- G_RoleService:bindMobile( 手机号 )
        end
    end)

    self:registerTextfieldEvent("TextField_input1",function ( textfield, eventType )
        self:callAfterFrameCount(1, function ( ... )
            self:_onInputNumEvent(eventType,"TextField_input1",self:getWidgetByName("Panel_8")) 
        end)
     end)
    self:registerTextfieldEvent("TextField_input2",function ( textfield, eventType )
        self:callAfterFrameCount(1, function ( ... )
            self:_onInputNumEvent(eventType,"TextField_input2",self:getWidgetByName("Panel_8")) 
        end)
     end)

    self._isAttached = {TextField_input1 = false,TextField_input2 = false}

    local textfield1 = self:getTextFieldByName("TextField_input1")
    local textfield2 = self:getTextFieldByName("TextField_input2")
    textfield1:setMaxLengthEnabled(true)
    textfield2:setMaxLengthEnabled(true)
    textfield1:setMaxLength(11)
    textfield2:setMaxLength(6)
    textfield1:setInputMode(kCCSEditBoxInputModeNumeric)
    textfield2:setInputMode(kCCSEditBoxInputModeNumeric)
end

function ActivityPagePhone:setMeinv()
    local GlobalConst = require("app.const.GlobalConst")
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    local knight = nil
    if appstoreVersion or IS_HEXIE_VERSION  then 
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
    else
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    end
    if knight then
        local hero = KnightPic.createKnightPic( knight.res_id, self:getPanelByName("Panel_hero"), "meinv",true )
        hero:setScale(0.8)
        -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
    end
end

function ActivityPagePhone:adapterLayer()
    -- self:adapterWidgetHeight("Panel_content","","",0,0)
    -- self:adapterWidgetHeight("Panel_content2","Panel_content","",0,0)
    local panel = self:getPanelByName("Panel_alot")
    local height = display.height
    -- print(height)
    local y = 128 - (display.height - 853)/2 
    local pos = ccp(panel:getPosition())
    panel:setPosition(ccp(pos.x,y))
end

function ActivityPagePhone:_onInputNumEvent( eventType,fieldname,root )
    local textfield = self:getTextFieldByName(fieldname)
    -- local textfield = field
    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()

    -- local widgetRoot = self:getWidgetByName("Image_21")
    local widgetRoot = root
    if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
        if self._isAttached[fieldname] == false then
            return
        end
        if target == kTargetIphone or target == kTargetIpad then 
            if self._layerMoveOffset < 1 and textfield then 
                    local textSize = textfield:getSize()
                    local screenPosx, screenPosy = textfield:convertToWorldSpaceXY(0, 0)
                    local keyboardHeight = textfield:getKeyboardHeight()
                    if display.contentScaleFactor >= 2 then 
                        keyboardHeight = keyboardHeight/2
                    end
                    if keyboardHeight > screenPosy - 2*textSize.height then 
                        self._layerMoveOffset = keyboardHeight - screenPosy + 2*textSize.height
                    end

                    if self._layerMoveOffset > 0 then 
                        widgetRoot:runAction(CCMoveBy:create(0.2, ccp(0, self._layerMoveOffset)))
                        textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
                    end
            end
        end
    elseif eventType == CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME then 
        self._isAttached[fieldname] = true
    elseif eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_HIDE then 
        if self._isAttached[fieldname] == false then
            return
        end
        self._isAttached[fieldname] = false
        if self._layerMoveOffset > 0 then 
            widgetRoot:runAction(CCMoveBy:create(0.2, ccp(0, -self._layerMoveOffset)))
            textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
            self._layerMoveOffset = 0
        end
    end
end

function ActivityPagePhone:showPage()   
    --进界面的时候强刷一次数据
    G_HandlersManager.shareHandler:sendShareState(2)
    self:updateView()
    self:httpPost(self._url.."gameapp/queryBindPhoneStatus.json",nil,nil,function ( data )
        self._bindStatus = data.body.bindStatus
        if G_SceneObserver:getSceneName() ~= "ActivityMainScene" then
            return
        end
        self:updateView()
    end)
end

function ActivityPagePhone:updatePage()

end

function ActivityPagePhone:updateAward()
    for k , v in pairs(ActivityPagePhone.AWARD) do 
        local img = self:getImageViewByName("Image_icon"..k)
        local btn = self:getButtonByName("Button_pinji"..k)
        local num = self:getLabelByName("Label_num"..k)
        if img and btn then
            local good = G_Goods.convert(v.type,v.value)
            img:loadTexture(good.icon)
            btn:loadTextureNormal(G_Path.getEquipColorImage(good.quality))
            num:setText("x"..G_GlobalFunc.ConvertNumToCharacter3(v.size))
            num:createStroke(Colors.strokeBrown, 1)

            self:registerBtnClickEvent("Button_pinji"..k, function ( widget )
                require("app.scenes.common.dropinfo.DropInfo").show(v.type, v.value)  
            end)  
        end
    end
end

function ActivityPagePhone:updateView()

    -- self._bindStatus = 0
    -- self._ServerBindState = -1
    if self._bindStatus == -1 then
        self._bindLabel:setText(G_lang:get("LANG_ACTIVITY_PHONE_BINDTXT1"))
        self._bindLabel:setVisible(true)
        self._bindPanel:setVisible(false)
        self._bindButton:setTouchEnabled(false)
    elseif self._bindStatus == 0 then
        self._bindLabel:setVisible(false)
        self._bindPanel:setVisible(true)
        self._bindButton:setTouchEnabled(true)
    elseif self._bindStatus == 1 then
        if self._ServerBindState == -1 then
            self._bindLabel:setText(G_lang:get("LANG_ACTIVITY_PHONE_BINDTXT1"))
            self._bindLabel:setVisible(true)
            self._bindPanel:setVisible(false)
            self._bindButton:setTouchEnabled(false)
        elseif self._ServerBindState == 1 then
            self._bindLabel:setText(G_lang:get("LANG_ACTIVITY_PHONE_BINDTXT3"))
            self._bindLabel:setVisible(true)
            self._bindPanel:setVisible(false)
            self._bindButton:setTouchEnabled(true)
            self:getImageViewByName("Image_getAward"):loadTexture("ui/text/txt-big-btn/lingjiang.png")
        elseif self._ServerBindState == 2 then
            self._bindLabel:setText(G_lang:get("LANG_ACTIVITY_PHONE_BINDTXT2"))
            self._bindLabel:setVisible(true)
            self._bindPanel:setVisible(false)
            self._bindButton:setTouchEnabled(false)
            self:getImageViewByName("Image_getAward"):loadTexture("ui/text/txt-big-btn/bangding.png")
        else
        end
    else

    end

    local count = G_Me.activityData.phone.count
    if count > 0 and self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
        self._getLabel:setText(G_Me.activityData.phone.count.."s")
        self._getLabel:setVisible(true)
        self._getImage:setVisible(false)
    end
    if count <= 0 then
        self._getLabel:setVisible(false)
        self._getImage:setVisible(true)
    end
end

function ActivityPagePhone:_refreshTimeLeft()

    if G_Me.activityData.phone.count <= 0 then
        if self._schedule then
            self._getLabel:setVisible(false)
            self._getImage:setVisible(true)
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end
    end

    self._getLabel:setText(G_Me.activityData.phone.count.."s")

end

function ActivityPagePhone:_onRecShareState(data)
    -- dump(data)
    self._ServerBindState = data.state[1].step
    self:updateView()
end

function ActivityPagePhone:_onRecShareAward(data)
    if data.ret == 1 then
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(ActivityPagePhone.AWARD)
        uf_notifyLayer:getModelNode():addChild(_layer)
        self._ServerBindState = 2 
        G_Me.activityData.phone.state = true
        self:updateView()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    end
end

local function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end

function ActivityPagePhone:httpPostData(msg)
    local str = ""
    local strList = {}
    -- local sortFunc = function(a,b)

    -- end
    for k , v in pairs(msg) do 
        -- if string.len(str) < 1 then
        --     str = str..k.."="..url_encode(v)
        -- else
        --     str = str.."&"..k.."="..url_encode(v)
        -- end
        table.insert(strList,#strList+1,k.."="..v) 

    end
    table.sort(strList)
    for i = 1 , #strList do 
        if i == 1 then
            str = str .. strList[i]
        else
            str = str .."&" .. strList[i]
        end
    end
    return str
end

function ActivityPagePhone:httpPostEncodeData(msg)
    local str = ""
    for k , v in pairs(msg) do 
        if string.len(str) < 1 then
            str = str..k.."="..url_encode(v)
        else
            str = str.."&"..k.."="..url_encode(v)
        end
    end
    return str
end

function ActivityPagePhone:httpPost(url,phone,code,func)
    -- print("=================post")
    local msg = {
        deviceId = G_PlatformProxy:getDeviceId(),
        gameId = SPECIFIC_GAME_ID,
        opId = G_PlatformProxy:getOpId(),
        osdkTicket = G_PlatformProxy:getTokenTicket(),
        osType = G_NativeProxy.platform ,
        roleName = G_Me.userData.name,
        serverId = G_PlatformProxy:getLoginServer().id,
        serverName = G_PlatformProxy:getLoginServer().name,
        activityId = 1
    }
    if phone then
        msg["phone"] = phone
    end
    if code then
        msg["dynamicCode"] = code
    end

    local str = self:httpPostData(msg)
    local md5 = CCCrypto:MD5(str .. key, false)
    -- md5 = string.sub(md5,0,16)
    -- print(str..key)
    str = self:httpPostEncodeData(msg).."&sign="..md5
    -- print(string.sub(md5,16,16))
    local request = uf_netManager:createHttpRequestPost(url, function(event) 
        local request = event.request
        local response = request:getResponseString()
        local t=json.decode(response)
        dump(t)
        if t ~= nil then
            if t.respCode ~= nil  then
                if t.respCode == "0" then
                    -- print("ok")
                    if func then
                        func(t)
                    end
                    -- self._bindStatus = t.body.bindStatus
                    -- self:updateView()
                elseif t.respCode == "200" then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_PHONE_WEBERROR"))
                else
                    G_MovingTip:showMovingTip(t.respMsg)
                end
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_PHONE_WEBERROR"))
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_PHONE_WEBERROR"))
        end
    end)
    request:setPOSTData(str)
    -- print("url:"..url)
    -- print("post:"..str)
    request:start()
end

return ActivityPagePhone
