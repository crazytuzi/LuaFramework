require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ChoosePKType.ChoosePKTypeNotes"
require "Core.Module.ChoosePKType.View.ChoosePKTypePanel"

ChoosePKTypeMediator = Mediator:New();
function ChoosePKTypeMediator:OnRegister()

end

function ChoosePKTypeMediator:_ListNotificationInterests()
	return {
        [1] = ChoosePKTypeNotes.OPEN_CHOOSEPKTYPE,
        [2] = ChoosePKTypeNotes.CLOSE_CHOOSEPKTYPE,
    }
end

function ChoosePKTypeMediator:_HandleNotification(notification)	
	if notification:GetName() == ChoosePKTypeNotes.OPEN_CHOOSEPKTYPE then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_CHOOSEPKTYPE, ChoosePKTypePanel);            
        end        
    elseif notification:GetName() == ChoosePKTypeNotes.CLOSE_CHOOSEPKTYPE then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    end
end

function ChoosePKTypeMediator:OnRemove()

end

