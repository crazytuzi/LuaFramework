require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.HirePlayer.HirePlayerNotes"
require "Core.Module.HirePlayer.View.HirePlayerPanel"

HirePlayerMediator = Mediator:New();
function HirePlayerMediator:OnRegister()

end

function HirePlayerMediator:_ListNotificationInterests()
    return {
        [1] = HirePlayerNotes.OPEN_HIREPLAYERPANEL,
        [2] = HirePlayerNotes.CLOSE_HIREPLAYERPANEL,
    };
end

function HirePlayerMediator:_HandleNotification(notification)
    if notification:GetName() == HirePlayerNotes.OPEN_HIREPLAYERPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_HIREPLAYERPANEL, HirePlayerPanel, false);
        end
        self._panel:SetData(notification:GetBody());
    elseif notification:GetName() == HirePlayerNotes.CLOSE_HIREPLAYERPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_HIREPLAYERPANEL)
            self._panel = nil
        end
    end
end

function HirePlayerMediator:OnRemove()

end

