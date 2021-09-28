require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.FirstRechargeAward.FirstRechargeAwardNotes"
require "Core.Module.FirstRechargeAward.View.FirstRechargeAwardPanel"

FirstRechargeAwardMediator = Mediator:New();
function FirstRechargeAwardMediator:OnRegister()

end

function FirstRechargeAwardMediator:_ListNotificationInterests()
    return {
         FirstRechargeAwardNotes.OPEN_FIRSTRECHARGEAWARDPANEL,
         FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGEAWARDPANEL,
         FirstRechargeAwardNotes.OPEN_FIRSTRECHARG_ALERT_PANEL,
         FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGE_ALERT_PANEL,
    };
end

function FirstRechargeAwardMediator:_HandleNotification(notification)
    
    local t  = notification:GetName()
    if t == FirstRechargeAwardNotes.OPEN_FIRSTRECHARGEAWARDPANEL then

        if (self.firstRechargeAwardPanel == nil) then
            self.firstRechargeAwardPanel = PanelManager.BuildPanel(ResID.UI_FIRSTRECHARGEAWARDPANEL, FirstRechargeAwardPanel, false);
        end

    elseif t == FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGEAWARDPANEL then
        if (self.firstRechargeAwardPanel ~= nil) then
            PanelManager.RecyclePanel(self.firstRechargeAwardPanel, ResID.UI_FIRSTRECHARGEAWARDPANEL)
            self.firstRechargeAwardPanel = nil
        end
    elseif t == FirstRechargeAwardNotes.OPEN_FIRSTRECHARG_ALERT_PANEL then
        if (self.alertPanel == nil) then
            local FirstChargeTipsPanel = require "Core.Module.FirstRechargeAward.View.FirstChargeTipsPanel"
            self.alertPanel = PanelManager.BuildPanel(ResID.UI_FIRSTRECHARGE_TIPS_PANEL, FirstChargeTipsPanel, false);
        end

    elseif t == FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGE_ALERT_PANEL then
        if (self.alertPanel ~= nil) then
            PanelManager.RecyclePanel(self.alertPanel, ResID.UI_FIRSTRECHARGE_TIPS_PANEL)
            self.alertPanel = nil
        end
    end


end

function FirstRechargeAwardMediator:OnRemove()

end

