require "Core.Module.Pattern.Mediator";
require "Core.Module.Common.ResID";

require "Core.Module.SelectRole.SelectRoleNotes";
require "Core.Module.SelectRole.View.SelectRolePanel";
-- require "Core.Module.SelectRole.View.CreateRolePanel";
local CreateRoleNewPanel = require "Core.Module.SelectRole.View.CreateRoleNewPanel";


SelectRoleMediator = Mediator:New()
function SelectRoleMediator:OnRegister()
	self._selectRolePanel = nil;
	self._createRolePanel = nil;
end
local notification =
{
	SelectRoleNotes.OPEN_SELECTROLE_PANEL,
	SelectRoleNotes.CLOSE_SELECTROLE_PANEL,
	SelectRoleNotes.CAREERITEM_CHANGE,
	SelectRoleNotes.OPEN_CREATEROLEPANEL,
	SelectRoleNotes.CLOSE_CREATEROLEPANEL,
	SelectRoleNotes.CREATEROLEITEM_CHANGE,
	SelectRoleNotes.UPDATE_NAME,
	
}
function SelectRoleMediator:_ListNotificationInterests()
	return notification
end

function SelectRoleMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName == SelectRoleNotes.OPEN_SELECTROLE_PANEL then
		if self._selectRolePanel == nil then
			self._selectRolePanel = PanelManager.BuildPanel(ResID.UI_SELECTROLEPANEL, SelectRolePanel, false, nil, true);		
		end
		self._selectRolePanel:UpData();
	elseif(notificationName == SelectRoleNotes.CLOSE_SELECTROLE_PANEL) then
		
		if self._selectRolePanel ~= nil then
			PanelManager.RecyclePanel(self._selectRolePanel, ResID.UI_SELECTROLEPANEL, true);
			self._selectRolePanel = nil
		end
	elseif(notificationName == SelectRoleNotes.CAREERITEM_CHANGE) then
		if(self._selectRolePanel ~= nil) then
			local data = notification:GetBody();
			self._selectRolePanel:SetSelectHero(data);
		end
	elseif(notificationName == SelectRoleNotes.OPEN_CREATEROLEPANEL) then
		if self._createRolePanel == nil then
			
			self._createRolePanel = PanelManager.BuildPanel(ResID.UI_CREATEROLEPANEL, CreateRoleNewPanel);
			-- math.randomseed(os.time());
			local index = math.round(math.Random(1, 4))
			self._createRolePanel:_OnClickToggle(index)
		end
	elseif(notificationName == SelectRoleNotes.CLOSE_CREATEROLEPANEL) then		
		if self._createRolePanel ~= nil then
			PanelManager.RecyclePanel(self._createRolePanel, ResID.UI_CREATEROLEPANEL);
			self._createRolePanel = nil
		end
	elseif(notificationName == SelectRoleNotes.CREATEROLEITEM_CHANGE) then
		if(self._createRolePanel) then
			local data = notification:GetBody();
			self._createRolePanel:SetSelectHero(data);			
		end
	elseif(notificationName == SelectRoleNotes.UPDATE_NAME) then
		if(self._createRolePanel) then
			self._createRolePanel:UpdateName(notification:GetBody())
		end
		
	end
end

-- function SelectRoleMediator:ShowCreateRolePanel()
--    if self._createRolePanel == nil then
--        self._createRolePanel = PanelManager.BuildPanel(ResID.UI_CREATEROLEPANEL, CreateRolePanel);
--    end
-- end
-- function SelectRoleMediator:CreateHeroChange(info)
--    self._createRolePanel:SetSelectHero(info.id);
-- end
-- function SelectRoleMediator:OnRemove()
-- end
