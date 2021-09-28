require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Confirm.ConfirmNotes"

require "Core.Module.Confirm.View.Confirm1Panel"
require "Core.Module.Confirm.View.Confirm2Panel"
require "Core.Module.Confirm.View.Confirm3Panel"
require "Core.Module.Confirm.View.Confirm4Panel"
require "Core.Module.Confirm.View.Confirm5Panel"
require "Core.Module.Confirm.View.Confirm6Panel"
require "Core.Module.Confirm.View.Confirm7Panel"


ConfirmMediator = Mediator:New();
local id = 0
function ConfirmMediator:OnRegister()
	self._allConfirmPanels = {}
end
local _notification =
{
	ConfirmNotes.OPEN_CONFIRM1PANEL,
	ConfirmNotes.CLOSE_CONFIRM1PANEL,
	ConfirmNotes.OPEN_CONFIRM2PANEL,
	ConfirmNotes.CLOSE_CONFIRM2PANEL,
	ConfirmNotes.OPEN_CONFIRM3PANEL,
	ConfirmNotes.CLOSE_CONFIRM3PANEL,
	ConfirmNotes.OPEN_CONFIRM4PANEL,
	ConfirmNotes.CLOSE_CONFIRM4PANEL,
	ConfirmNotes.OPEN_CONFIRM5PANEL,
	ConfirmNotes.CLOSE_CONFIRM5PANEL,
	ConfirmNotes.OPEN_CONFIRM6PANEL,
	ConfirmNotes.CLOSE_CONFIRM6PANEL,
	ConfirmNotes.OPEN_CONFIRM7PANEL,
	ConfirmNotes.CLOSE_CONFIRM7PANEL,
	
};
function ConfirmMediator:_ListNotificationInterests()
	return _notification
end

function ConfirmMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if(notificationName == ConfirmNotes.OPEN_CONFIRM1PANEL
	or notificationName == ConfirmNotes.OPEN_CONFIRM2PANEL
	or notificationName == ConfirmNotes.OPEN_CONFIRM3PANEL
	or notificationName == ConfirmNotes.OPEN_CONFIRM4PANEL
	or notificationName == ConfirmNotes.OPEN_CONFIRM5PANEL
	or notificationName == ConfirmNotes.OPEN_CONFIRM6PANEL
	or notificationName == ConfirmNotes.OPEN_CONFIRM7PANEL
	
	) then
		id = id + 1
	end
	
	if notificationName == ConfirmNotes.OPEN_CONFIRM1PANEL then
		self:OpenConfirmPanel(ResID.UI_CONFIRM1PANEL, Confirm1Panel, ConfirmNotes.CLOSE_CONFIRM1PANEL, notification:GetBody())
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM1PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
	elseif notificationName == ConfirmNotes.OPEN_CONFIRM2PANEL then
		self:OpenConfirmPanel(ResID.UI_CONFIRM2PANEL, Confirm2Panel, ConfirmNotes.CLOSE_CONFIRM2PANEL, notification:GetBody())
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM2PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
	elseif notificationName == ConfirmNotes.OPEN_CONFIRM3PANEL then
		self:OpenConfirmPanel(ResID.UI_CONFIRM3PANEL, Confirm3Panel, ConfirmNotes.CLOSE_CONFIRM3PANEL, notification:GetBody())
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM3PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
	elseif notificationName == ConfirmNotes.OPEN_CONFIRM4PANEL then
		self:OpenConfirmPanel(ResID.UI_CONFIRM4PANEL, Confirm4Panel, ConfirmNotes.CLOSE_CONFIRM4PANEL, notification:GetBody())
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM4PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
	elseif notificationName == ConfirmNotes.OPEN_CONFIRM5PANEL then
		self:OpenConfirmPanel(ResID.UI_CONFIRM5PANEL, Confirm5Panel, ConfirmNotes.CLOSE_CONFIRM5PANEL, notification:GetBody())
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM5PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
	elseif notificationName == ConfirmNotes.OPEN_CONFIRM6PANEL then	
		if(self._confirmPanel6 == nil) then
			self._confirmPanel6 = self:OpenConfirmPanel(ResID.UI_CONFIRM6PANEL, Confirm6Panel, ConfirmNotes.CLOSE_CONFIRM6PANEL, notification:GetBody())
		else
			id = id - 1
			self._confirmPanel6:SetData(notification:GetBody())		
		end
		
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM6PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
		self._confirmPanel6 = nil
	elseif notificationName == ConfirmNotes.OPEN_CONFIRM7PANEL then
		self:OpenConfirmPanel(ResID.UI_CONFIRM7PANEL, Confirm7Panel, ConfirmNotes.CLOSE_CONFIRM7PANEL, notification:GetBody())
	elseif notificationName == ConfirmNotes.CLOSE_CONFIRM7PANEL then
		local data = notification:GetBody();
		self:CloseConfirmPanel(data)
	end
end

function ConfirmMediator:CloseConfirmPanel(id)
	if(self._allConfirmPanels[id]) then
		PanelManager.RecyclePanel(self._allConfirmPanels[id])
		self._allConfirmPanels[id] = nil
	else
		for i, v in pairs(self._allConfirmPanels) do
			PanelManager.RecyclePanel(v)
			self._allConfirmPanels[i] = nil;
		end
	end
end

function ConfirmMediator:OpenConfirmPanel(path, panel, closeNote, data)
	local panel = PanelManager.BuildPanel(path, panel, false, closeNote);
	panel:SetPanelId(id)
	panel:SetData(data);
	self._allConfirmPanels[id] = panel
	return panel
end

function ConfirmMediator:OnRemove()
	
end

