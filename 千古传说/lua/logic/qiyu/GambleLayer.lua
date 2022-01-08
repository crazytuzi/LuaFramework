
local GambleLayer = class("GambleLayer", BaseLayer)

function GambleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.Dushi")
    -- QiyuManager:SengQueryEatPigMsg()
end

function GambleLayer:onShow()
    print("GambleLayer onShow")
    self.super.onShow(self)
end

function GambleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_go = TFDirector:getChildByPath(ui, 'btn_go')
    self.btn_help = TFDirector:getChildByPath(ui, 'btn_help')
    self.btn_help:setVisible(false)
end

function GambleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.btn_go:addMEListener(TFWIDGET_CLICK, audioClickfun(self.goBtnClickHandle),1)
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpBtnClickHandle),1)
end

function GambleLayer:removeEvents()
    self.super.removeEvents(self)
end

function GambleLayer.goBtnClickHandle(sender)
    GambleManager:openGambleMainLayer()
end

function GambleLayer.helpBtnClickHandle(sender)
    CommonManager:showRuleLyaer("dushi")
end

return GambleLayer