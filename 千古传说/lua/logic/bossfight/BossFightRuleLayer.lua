
local BossFightRuleLayer = class("BossFightRuleLayer", BaseLayer)

function BossFightRuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.demond.Rule")
end

function BossFightRuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'Btn_close')


end

function BossFightRuleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    -- self.ruleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ruleBtnClickHandle));
    -- self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClickHandle));

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function BossFightRuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function BossFightRuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end




return BossFightRuleLayer