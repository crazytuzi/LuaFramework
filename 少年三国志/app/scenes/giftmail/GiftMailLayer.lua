local GiftMailLayer = class("GiftMailLayer",UFCCSModelLayer)


function GiftMailLayer.create()
   return GiftMailLayer.new("ui_layout/giftmail_GiftMailLayer.json", require("app.setting.Colors").modelColor)
end

function GiftMailLayer:ctor(...)
    self.super.ctor(self,...)
    self._listView = nil
    

    
    self:_initViews()
    self:_initButtonEvent()


    if G_PlatformProxy:getLoginServer().id == 9 then
        self:gameInit()
    end
    
    --先请求数据
    __LogTag("ldx", "new layer")
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_MAIL_CONTENT_READY, self._onGiftMailContentReady, self) 
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_MAIL_PROCESS, self._onGiftMailProcess, self) 

end

function GiftMailLayer:onLayerEnter( ... )
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    self:closeAtReturn(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_MAIL_CONTENT_READY, self._onGiftMailContentReady, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_MAIL_PROCESS, self._onGiftMailProcess, self) 

    G_HandlersManager.giftMailHandler:sendGetGiftMail()
end

function GiftMailLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

function GiftMailLayer:_onGiftMailContentReady()    
    self:_updateData() 

    --快捷领取物品
    -- local listData = G_Me.giftMailData:getMailList()
    -- for k,v in pairs(listData) do 
    --     G_HandlersManager.giftMailHandler:sendProcessGiftMail(v.id )
    -- end
end


function GiftMailLayer:gameInit()
    self._gameButton = Button:create()
    self:getImageViewByName("Image_listbg"):addChild(self._gameButton,100)
    self._gameButton:loadTextureNormal("btn-big.png", UI_TEX_TYPE_PLIST)
    self._gameButton:setTouchEnabled(true)
    self._gameButton:setName("Button_play")
    self._gameButton:setPosition(ccp(0,-300))
    self._gameButton:setTitleText("一键领取")
    self._gameButton:setTitleFontSize(40)
    self:registerBtnClickEvent("Button_play",function(widget)
        local listData = G_Me.giftMailData:getMailList()
        for k,v in pairs(listData) do 
            G_HandlersManager.giftMailHandler:sendProcessGiftMail(v.id )
        end
    end)
end

function GiftMailLayer:_onGiftMailProcess(data)    
    if data.ret == 1 then
         --update or close
        local listData = G_Me.giftMailData:getMailList()
        if #listData > 0 then
            self:_updateData() 
        else
            self:animationToClose()
        end
        
        --popup result dialog
        -- local dialog = require("app.scenes.giftmail.GiftMailResultLayer").create(data.mail)
        -- uf_notifyLayer:getModelNode():addChild(dialog)
        -- dialog:showAtCenter(true)

        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.mail.awards)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
    else
        -- MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"),G_NetMsgError.getMsg(data.ret))
    end
end

function GiftMailLayer:_initViews()    
    self._listView =  CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.giftmail.GiftMailCell").new(list, index)
    end)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
        local listData = G_Me.giftMailData:getMailList()
        if  index < #listData then
           cell:updateData(listData[index+1]) 
        end
    end)
    self._listView:initChildWithDataLength( 0)

end

function GiftMailLayer:_initButtonEvent()
    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    
end

function GiftMailLayer:_updateData()
    
    local listData = G_Me.giftMailData:getMailList()
    
    self._listView:reloadWithLength( #listData)
end

function GiftMailLayer:onLayerUnload()
    __LogTag("ldx", "onLayerUnLoad layer")
    uf_eventManager:removeListenerWithTarget(self)
    
    --通知首页更新
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GIFT_MAIL_NEW_COUNT, nil, false)

end



return GiftMailLayer


