require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.WiseEquip.WiseEquipPanelNotes"

local WiseEquipPanel = require "Core.Module.WiseEquip.View.WiseEquipPanel";

local WiseEquipPanelMediator = Mediator:New();
function WiseEquipPanelMediator:OnRegister()

end

local _notification =
{
    WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL,
    WiseEquipPanelNotes.CLOSE_WISEEQUIPPANEL,

}

function WiseEquipPanelMediator:_ListNotificationInterests()
    return _notification;
end

function WiseEquipPanelMediator:_HandleNotification(notification)

    local notificationName = notification:GetName()
    local data = notification:GetBody();

    if notificationName == WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL then
        if (self._wiseEquipPanel == nil) then
            self._wiseEquipPanel = PanelManager.BuildPanel(ResID.UI_WISEEQUIPPANEL, WiseEquipPanel,true);
        end
        self._wiseEquipPanel:SetData(data)
    elseif notificationName == WiseEquipPanelNotes.CLOSE_WISEEQUIPPANEL then
        if (self._wiseEquipPanel ~= nil) then
            PanelManager.RecyclePanel(self._wiseEquipPanel, ResID.UI_WISEEQUIPPANEL)
            self._wiseEquipPanel = nil
        end
    end


end

function WiseEquipPanelMediator:OnRemove()

end

return WiseEquipPanelMediator