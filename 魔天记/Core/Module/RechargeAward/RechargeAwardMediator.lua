require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.RechargeAward.RechargeAwardNotes"
local RechargeAwardPanel = require "Core.Module.RechargeAward.View.RechargeAwardPanel"

local RechargeAwardMediator = Mediator:New();
local notes = {
RechargeAwardNotes.OPEN_RECHARGET_PANEL,
RechargeAwardNotes.CLOSE_RECHARGET_PANEL,
}
function RechargeAwardMediator:OnRegister()

end

function RechargeAwardMediator:_ListNotificationInterests()
	return notes
end

function RechargeAwardMediator:_HandleNotification(notification)
	local n = notification:GetName()
    if n == RechargeAwardNotes.OPEN_RECHARGET_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_RECHARGE_AWARD_PANEL, RechargeAwardPanel);
        end
    elseif n == RechargeAwardNotes.CLOSE_RECHARGET_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_RECHARGE_AWARD_PANEL)
            self._panel = nil
        end
    end
end

function RechargeAwardMediator:OnRemove()

end

return RechargeAwardMediator