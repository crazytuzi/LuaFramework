require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Promote.PromoteNotes"
require "Core.Module.Promote.View.PromotePanel"

PromoteMediator = Mediator:New();
function PromoteMediator:OnRegister()

end



function PromoteMediator:_ListNotificationInterests()
	return {
		[1] = PromoteNotes.OPEN_PROMOTE,
		[2] = PromoteNotes.CLOSE_PROMOTE,
	};
end

function PromoteMediator:_HandleNotification(notification)
	if notification:GetName() == PromoteNotes.OPEN_PROMOTE then
		if (self._panel == nil) then
			self._panel = PanelManager.BuildPanel(ResID.UI_PROMOTEPANEL, PromotePanel, true);
		end
	elseif notification:GetName() == PromoteNotes.CLOSE_PROMOTE then
		if (self._panel ~= nil) then
			PanelManager.RecyclePanel(self._panel, ResID.UI_PROMOTEPANEL)
			self._panel = nil
		end
	end
end

function PromoteMediator:OnRemove()

end