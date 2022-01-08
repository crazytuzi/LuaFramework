
local BloodRuleLayer = class("BloodRuleLayer", BaseLayer)

function BloodRuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.bloodybattle.BloodybattleSignRuleLayer")
end

function BloodRuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')


end

function BloodRuleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    -- self.ruleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ruleBtnClickHandle));
    -- self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeBtnClickHandle));

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function BloodRuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function BloodRuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end




return BloodRuleLayer