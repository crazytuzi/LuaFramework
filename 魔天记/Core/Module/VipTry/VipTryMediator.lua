require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.VipTry.VipTryNotes"
local VipTryPanel = require "Core.Module.VipTry.View.VipTryPanel"

local VipTryMediator = Mediator:New();
local notes = {
    VipTryNotes.OPEN_VIP_TRY_PANEL
    ,VipTryNotes.CLOSE_VIP_TRY_PANEL
}
function VipTryMediator:OnRegister()

end

function VipTryMediator:_ListNotificationInterests()
	return notes
end

function VipTryMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
    if notificationName == VipTryNotes.OPEN_VIP_TRY_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_VIP_TRY_PANEL, VipTryPanel)
        end
        self._panel:SetData(notification:GetBody())
    elseif notificationName == VipTryNotes.CLOSE_VIP_TRY_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_VIP_TRY_PANEL)
            self._panel = nil
        end
    end
end

function VipTryMediator:OnRemove()

end

return VipTryMediator