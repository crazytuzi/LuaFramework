
local NotifyMessageLayer = class("NotifyMessageLayer", BaseLayer)

function NotifyMessageLayer:ctor()
    self.super.ctor(self)
   
    self:init("lua.uiconfig_mango_new.notify.NotifyMessage")
end

function NotifyMessageLayer:initUI(ui)
    self.super.initUI(self,ui)

    local richTextWidth = GameConfig.WS.width * 1.7

    self.textLabel = TFScrollRichText:create("")
    self.textLabel:setZOrder(10)
    self.textLabel:setPosition(ccp(-richTextWidth/2,-25)) 
    self.textLabel:setSize(CCSizeMake(richTextWidth, 50))
    self.textLabel:setSpeed(2.5)
    self.textLabel:setChangeFunc(NotifyMessageLayer, NotifyMessageLayer.OnShowEnd)
    ui:addChild(self.textLabel)
end

function NotifyMessageLayer:OnShowEnd()
    -- NotifyManager:RemoveNotifyMessage()
    NotifyManager:displayMessageCompelete()
end

function NotifyMessageLayer:ShowText(text)
    if not tolua.isnull(self.textLabel) then
        self.textLabel:setText(text)
    end
end


return NotifyMessageLayer