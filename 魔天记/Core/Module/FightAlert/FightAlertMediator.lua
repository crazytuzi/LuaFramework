require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.FightAlert.FightAlertNotes"
require "Core.Module.FightAlert.View.FightAlertPanel"

FightAlertMediator = Mediator:New();
function FightAlertMediator:OnRegister()

end

function FightAlertMediator:_ListNotificationInterests()
    return {
        [1] = FightAlertNotes.OPEN_FIGHTALERT,
        [2] = FightAlertNotes.CLOSE_FIGHTALERT,
    };
end

function FightAlertMediator:_HandleNotification(notification)
    if notification:GetName() == FightAlertNotes.OPEN_FIGHTALERT then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_FIGHTALERT, FightAlertPanel);            
        end        
    elseif notification:GetName() == FightAlertNotes.CLOSE_FIGHTALERT then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    end
end

function FightAlertMediator:OnRemove()

end

