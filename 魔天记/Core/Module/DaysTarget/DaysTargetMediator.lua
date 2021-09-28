require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.DaysTarget.DaysTargetNotes"
require "Core.Module.DaysTarget.View.DaysTargetPanel"


DaysTargetMediator = Mediator:New();
function DaysTargetMediator:OnRegister()

end

function DaysTargetMediator:_ListNotificationInterests()
	return {
        [1] = DaysTargetNotes.OPEN_DAYSTARGET_PANEL,
        [2] = DaysTargetNotes.CLOSE_DAYSTARGET_PANEL,
    }
end

function DaysTargetMediator:_HandleNotification(notification)
	if notification:GetName() == DaysTargetNotes.OPEN_DAYSTARGET_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_DaysTarget, DaysTargetPanel);
        end
    elseif notification:GetName() == DaysTargetNotes.CLOSE_DAYSTARGET_PANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_DaysTarget);
            self._panel = nil;
        end
    end
end

function DaysTargetMediator:OnRemove()
	if (self._panel ~= nil) then
        PanelManager.RecyclePanel(self._panel, ResID.UI_DaysTarget);
        self._panel = nil;
    end

end

