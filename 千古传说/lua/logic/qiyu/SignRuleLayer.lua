
local SignRuleLayer = class("SignRuleLayer", BaseLayer)

function SignRuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.SignRuleLayer")
end

function SignRuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
end

function SignRuleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    -- self.ruleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ruleBtnClickHandle));
    -- self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClickHandle));

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function SignRuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function SignRuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end


return SignRuleLayer