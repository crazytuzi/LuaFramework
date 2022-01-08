
local TuhaoChatLayer = class("TuhaoChatLayer", BaseLayer)

function TuhaoChatLayer:ctor()
    self.super.ctor(self)
   
    self:init("lua.uiconfig_mango_new.notify.NotifyMessage")
end

function TuhaoChatLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.bg = TFDirector:getChildByPath(ui, 'bg')
    self.bg:setTexture("ui_new/home/bg_worldchat.png")
    self.bg:setScaleX(1)
    self.bg:setVisible(false)

    local richTextWidth = 644--GameConfig.WS.width

    --test add
    --[[
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/vip_chat.xml")
    local effect = TFArmature:create("vip_chat_anim")
    if effect == nil then
        self.img_success:removeFromParent(true)
        self.img_success = nil
        return
    end
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(0, 0))
    effect:setScale(0.75)
    effect:setZOrder(1)
    ui:addChild(effect)
    self.effect = effect
    self.effect:addMEListener(TFARMATURE_COMPLETE,function()
        self.effect:removeMEListener(TFARMATURE_COMPLETE) 
        self.effect = nil
    end)
    ]]
    self.textLabel = TFScrollRichText:create("")
    self.textLabel:setZOrder(10)
    --self.textLabel:setPosition(ccp(-richTextWidth/4, 50)) 
    self.textLabel:setPosition(ccp(-richTextWidth/4 - 73, 50)) 
    self.textLabel:setSize(CCSizeMake(468, 50))
    self.textLabel:setSpeed(1.7)
    self.textLabel:setChangeFunc(TuhaoChatLayer, TuhaoChatLayer.OnShowEnd)
    ui:addChild(self.textLabel, 100)
end

function TuhaoChatLayer:OnShowEnd()
    -- NotifyManager:RemoveNotifyMessage()
    NotifyManager:displayTuhaoChatCompelete()
end

function TuhaoChatLayer:setVipLevel(vipLevel)
    if self.effect then
        self.effect:removeFromParent()
        self.effect = nil
    end
    if not vipLevel then
        return
    end
    if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
        return
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/vip_chat_" .. vipLevel .. ".xml")
    local effect = TFArmature:create("vip_chat_" .. vipLevel .. "_anim")
    --print("+++++++fps = ", GameConfig.ANIM_FPS)
    effect:setAnimationFps(GameConfig.ANIM_FPS - 11)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(0, 0))
    --effect:setScale(0.75)
    effect:setZOrder(1)
    self.ui:addChild(effect, 10)
    self.effect = effect
    self.effect:addMEListener(TFARMATURE_COMPLETE, function()
        self.effect:removeMEListener(TFARMATURE_COMPLETE) 
        self.effect = nil
    end)
end

function TuhaoChatLayer:ShowText(text)
    if not tolua.isnull(self.textLabel) then
        self.textLabel:setText(text)
    end
end


return TuhaoChatLayer