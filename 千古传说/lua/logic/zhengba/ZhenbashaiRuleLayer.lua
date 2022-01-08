
local ZhenbashaiRuleLayer = class("ZhenbashaiRuleLayer", BaseLayer)

function ZhenbashaiRuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiRule")
end

function ZhenbashaiRuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
end

function ZhenbashaiRuleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    -- self.ruleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ruleBtnClickHandle));
    -- self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClickHandle));

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function ZhenbashaiRuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function ZhenbashaiRuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end


return ZhenbashaiRuleLayer