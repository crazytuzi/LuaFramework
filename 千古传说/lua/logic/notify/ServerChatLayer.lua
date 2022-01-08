
local ServerChatLayer = class("ServerChatLayer", BaseLayer)

function ServerChatLayer:ctor()
    self.super.ctor(self)
   
    self:init("lua.uiconfig_mango_new.notify.NotifyMessage")
end

function ServerChatLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.bg     = TFDirector:getChildByPath(ui, 'bg')
    self.bg:setTexture("ui_new/home/bg_worldchat.png")
    self.bg:setScaleX(1)
    local richTextWidth = 644--GameConfig.WS.width

    self.textLabel = TFScrollRichText:create("")
    self.textLabel:setZOrder(10)
    self.textLabel:setPosition(ccp(-richTextWidth/2,-25)) 
    self.textLabel:setSize(CCSizeMake(richTextWidth, 50))
    self.textLabel:setSpeed(2.5)
    self.textLabel:setChangeFunc(ServerChatLayer, ServerChatLayer.OnShowEnd)
    ui:addChild(self.textLabel)
end

function ServerChatLayer:OnShowEnd()
    -- NotifyManager:RemoveNotifyMessage()
    NotifyManager:displayServerChatCompelete()
end

function ServerChatLayer:setVipLevel(vipLevel)
    self.bg:setTexture("ui_new/home/bg_worldchat.png")
    if not vipLevel then
        return
    end

    if vipLevel == 17 then
        self.bg:setTexture("ui_new/home/bg_worldchat2.png")
    elseif vipLevel == 18 then
        self.bg:setTexture("ui_new/home/bg_worldchat3.png")
    end
end

function ServerChatLayer:ShowText(text)
    if not tolua.isnull(self.textLabel) then
        self.textLabel:setText(text)
    end
end


return ServerChatLayer