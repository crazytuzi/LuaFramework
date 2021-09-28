require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.NewestNotice.NewestNoticeNotes"
local NewestNoticePanel = require "Core.Module.NewestNotice.View.NewestNoticePanel"


local NewestNoticeMediator = Mediator:New();
local notes =
{
	NewestNoticeNotes.OPEN_NEWESTNOTICENOTESPANEL,
	NewestNoticeNotes.CLOSE_NEWESTNOTICENOTESPANEL,
	NewestNoticeNotes.UPDATE_NEWESTNOTICENOTESPANEL,
}
function NewestNoticeMediator:OnRegister()
	
end

function NewestNoticeMediator:_ListNotificationInterests()
	return notes
end

function NewestNoticeMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName ==	NewestNoticeNotes.OPEN_NEWESTNOTICENOTESPANEL then
		if(self._noticePanel == nil) then
			self._noticePanel = PanelManager.BuildPanel(ResID.UI_NEWESTNOTICEPANEL, NewestNoticePanel);		
			self._noticePanel:_InitPanel() 
		end
	elseif notificationName == NewestNoticeNotes.CLOSE_NEWESTNOTICENOTESPANEL then
		if(self._noticePanel) then
			PanelManager.RecyclePanel(self._noticePanel, ResID.UI_NEWESTNOTICEPANEL)
			self._noticePanel = nil
		end
	elseif notificationName == NewestNoticeNotes.UPDATE_NEWESTNOTICENOTESPANEL then
		if(self._noticePanel) then
			self._noticePanel:UpdatePanel(notification:GetBody())
		end
	end
end

function NewestNoticeMediator:OnRemove()
	
end

return NewestNoticeMediator 