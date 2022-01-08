
local AssistFightRuleLayer = class("AssistFightRuleLayer", BaseLayer)

function AssistFightRuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanRule")
end

function AssistFightRuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
end

function AssistFightRuleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function AssistFightRuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function AssistFightRuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

return AssistFightRuleLayer