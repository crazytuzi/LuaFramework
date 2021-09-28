require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.XuanBao.XuanBaoNotes"

local XuanBaoPanel = require "Core.Module.Xuanbao.View.XuanBaoPanel"


local XuanBaoMediator = Mediator:New();
local notes = {
	XuanBaoNotes.OPEN_XUANBAOPANEL,
	XuanBaoNotes.CLOSE_XUANBAOPANEL,
}

function XuanBaoMediator:OnRegister()

end

function XuanBaoMediator:_ListNotificationInterests()
	return notes
end

function XuanBaoMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()

	if notificationName == XuanBaoNotes.OPEN_XUANBAOPANEL then
		if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_XuanBaoPanel, XuanBaoPanel, false, XuanBaoNotes.CLOSE_XUANBAOPANEL);            
        end
	elseif notificationName == XuanBaoNotes.CLOSE_XUANBAOPANEL then
		if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel);
            self._panel = nil;
        end
	end

end

function XuanBaoMediator:OnRemove()
	
end

return XuanBaoMediator