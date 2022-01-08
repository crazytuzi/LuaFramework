
local WeekRaceRuleLayer = class("WeekRaceRuleLayer", BaseLayer)

function WeekRaceRuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiRule2")
end

function WeekRaceRuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
end

function WeekRaceRuleLayer:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function WeekRaceRuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function WeekRaceRuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

return WeekRaceRuleLayer