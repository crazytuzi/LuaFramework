require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Wing.WingNotes"
require "Core.Module.Wing.View.WingPanel"
local WingActivePanel = require "Core.Module.Wing.View.WingActivePanel"

local notice = {
	WingNotes.OPEN_WINGPANEL,
	WingNotes.CLOSE_WINGPANEL,
	WingNotes.UPDATE_WINGPANEL,
	
	WingNotes.OPEN_WINGACTIVEPANEL,
	WingNotes.CLOSE_WINGACTIVEPANEL,
	
	WingNotes.OPEN_WINGPREVIEWPANEL,
	WingNotes.CLOSE_WINGPREVIEWPANEL,
	WingNotes.UPDATE_WINGPREVIEWPANEL,
	
	WingNotes.UPDATE_WINGUIMODEL,
	WingNotes.SHOW_WINGPANELEFFECT,
	WingNotes.SHOW_WINGACTIVEEFFECT,
	WingNotes.SHOW_WINGUPDATELEVELLABEL,
	WingNotes.UPDATE_SUBWINGPANEL_EXP,
	WingNotes.UPDATE_SUBWINGPANEL_LEVEL
	
}
WingMediator = Mediator:New();
function WingMediator:OnRegister()
	
end

function WingMediator:_ListNotificationInterests()
	return notice
end

function WingMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName == WingNotes.OPEN_WINGPANEL then
		if(self._wingPanel == nil) then
			self._wingPanel = PanelManager.BuildPanel(ResID.UI_WINGPANEL, WingPanel, true);
			self._wingPanel:SelectPanel(1)
		end
		
		if(not WingManager.GetHadShow()) then
			local data = WingManager.GetShowRenewWingData()
			if(data) then
				ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
					msg = LanguageMgr.Get("wing/WingManager/renew", {time = TimeTranslate(data.time * 1000), name = data.name, num = data.continue_price}),
					ok_Label = LanguageMgr.Get("common/ok"),
					cance_lLabel = LanguageMgr.Get("common/cancle"),
					hander = WingProxy.RenewWing,
					data = data.id
				});
			end
		end
	elseif notificationName == WingNotes.CLOSE_WINGPANEL then
		if(self._wingPanel ~= nil) then
			PanelManager.RecyclePanel(self._wingPanel, ResID.UI_WINGPANEL)
			self._wingPanel = nil
		end
		
	elseif notificationName == WingNotes.OPEN_WINGACTIVEPANEL then
		if(self._wingActivePanel == nil) then
			self._wingActivePanel = PanelManager.BuildPanel(ResID.UI_WINGACTIVEPANEL, WingActivePanel, false);
		end
		self._wingActivePanel:SetData(notification:GetBody())
		
	elseif notificationName == WingNotes.CLOSE_WINGACTIVEPANEL then
		if(self._wingActivePanel ~= nil) then
			PanelManager.RecyclePanel(self._wingActivePanel, ResID.UI_WINGACTIVEPANEL)
			self._wingActivePanel = nil
		end
		
		
		
	elseif notificationName == WingNotes.UPDATE_WINGPANEL then
		if(self._wingPanel ~= nil) then
			self._wingPanel:UpdateWingPanel(notification:GetBody())
		end
	elseif notificationName == WingNotes.UPDATE_WINGPREVIEWPANEL then
		if(self._wingPanel ~= nil) then
			self._wingPanel:UpdatePanelByActive(notification:GetBody())
		end
	elseif notificationName == WingNotes.UPDATE_WINGUIMODEL then
		if(self._wingPanel ~= nil) then
			self._wingPanel:UpdateAnimationModel(notification:GetBody())
		end
	elseif notificationName == WingNotes.SHOW_WINGPANELEFFECT then
		if(self._wingPanel) then
			self._wingPanel:ShowEffect()
		end
	elseif notificationName == WingNotes.SHOW_WINGACTIVEEFFECT then
		if(self._wingPanel) then
			self._wingPanel:ShowActiveEffect()
		end
	elseif notificationName == WingNotes.SHOW_WINGUPDATELEVELLABEL then
		if(self._wingPanel) then
			self._wingPanel:ShowUpdateLevelLabel(notification:GetBody())
		end
	elseif notificationName == WingNotes.UPDATE_SUBWINGPANEL_EXP then
		if(self._wingPanel) then
			self._wingPanel:UpdateExp( )
		end
	elseif notificationName ==	WingNotes.UPDATE_SUBWINGPANEL_LEVEL then
		if(self._wingPanel) then
			self._wingPanel:UpdateLevel( )
		end
	end
end

function WingMediator:OnRemove()
	if(self._wingPanel ~= nil) then
		PanelManager.RecyclePanel(self._wingPanel, ResID.UI_WINGPANEL)
		self._wingPanel = nil
	end
end

