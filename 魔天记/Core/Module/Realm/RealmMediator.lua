require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Realm.RealmNotes"
require "Core.Module.Realm.View.RealmPanel"

RealmMediator = Mediator:New();
function RealmMediator:OnRegister()

end

function RealmMediator:_ListNotificationInterests()
	return {
		[1] = RealmNotes.OPEN_REALM,
		[2] = RealmNotes.CLOSE_REALM,
	};
end

function RealmMediator:_HandleNotification(notification)
	if notification:GetName() == RealmNotes.OPEN_REALM then
		local tab = notification:GetBody() or 1;
		if (self._panel == nil) then
			self._panel = PanelManager.BuildPanel(ResID.UI_REALMPANEL, RealmPanel, true);
		end
		self._panel:SelectSubPanel(tab);
	elseif notification:GetName() == RealmNotes.CLOSE_REALM then
		if (self._panel ~= nil) then
			PanelManager.RecyclePanel(self._panel, ResID.UI_REALMPANEL)
			self._panel = nil
		end
	end
end

function RealmMediator:OnRemove()

end

