require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.WildBoss.WildBossNotes"
local WildBossNewPanel = require "Core.Module.WildBoss.View.WildBossNewPanel"
require "Core.Module.WildBoss.View.WildBossRankPanel"
require "Core.Module.WildBoss.View.WildBossHurtRankPanel"
require "Core.Module.WildBoss.View.WildBossInfoPanel"
require "Core.Module.WildBoss.View.WildBossHelpPanel"
require "Core.Module.WildBoss.View.WildBossVipHelpPanel"

WildBossMediator = Mediator:New();
function WildBossMediator:OnRegister()
	
end
local _notification =
{
	WildBossNotes.OPEN_WILDBOSSPANEL,
	WildBossNotes.CLOSE_WILDBOSSPANEL,
	WildBossNotes.UPDATE_WILDBOSSPANEL,	
	WildBossNotes.OPEN_WILDBOSSHELPPANEL,
	WildBossNotes.CLOSE_WILDBOSSHELPPANEL,
	WildBossNotes.OPEN_WILDBOSSRANKPANEL,
	WildBossNotes.CLOSE_WILDBOSSRANKPANEL,
	WildBossNotes.OPEN_WILDBOSSHURTRANKPANEL,
	WildBossNotes.CLOSE_WILDBOSSHURTRANKPANEL,
	WildBossNotes.OPEN_WILDBOSSINFOPANEL,
	WildBossNotes.CLOSE_WILDBOSSINFOPANEL,
	WildBossNotes.OPEN_WILDBOSSVIPHELPPANEL,
	WildBossNotes.CLOSE_WILDBOSSVIPHELPPANEL,
}
function WildBossMediator:_ListNotificationInterests()
	return _notification
end

function WildBossMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName == WildBossNotes.OPEN_WILDBOSSPANEL then
		if(self._wildBossPanel == nil) then
			self._wildBossPanel = PanelManager.BuildPanel(ResID.UI_WILDBOSSPANEL, WildBossNewPanel, true);
			local p = notification:GetBody();
			if p then
				if p.tab == 1 then
					self._wildBossPanel:SetIndex(p.idx);
				else
					self._wildBossPanel:SetOpenParam(p);
				end
			end
		end
	elseif notificationName == WildBossNotes.CLOSE_WILDBOSSPANEL then
		if(self._wildBossPanel ~= nil) then
			PanelManager.RecyclePanel(self._wildBossPanel, ResID.UI_WILDBOSSPANEL)
			self._wildBossPanel = nil
		end
	elseif notificationName == WildBossNotes.UPDATE_WILDBOSSPANEL then
		if(self._wildBossPanel ~= nil) then
			self._wildBossPanel:UpdatePanel()
		end
	elseif notificationName == WildBossNotes.OPEN_WILDBOSSHELPPANEL then
		if(self._wildBossHelpPanel == nil) then
			self._wildBossHelpPanel = PanelManager.BuildPanel(ResID.UI_WILDBOSSHELPPANEL, WildBossHelpPanel, false);
		end
	elseif notificationName == WildBossNotes.CLOSE_WILDBOSSHELPPANEL then
		if(self._wildBossHelpPanel ~= nil) then
			PanelManager.RecyclePanel(self._wildBossHelpPanel, ResID.UI_WILDBOSSHELPPANEL)
			self._wildBossHelpPanel = nil
		end
	elseif notificationName == WildBossNotes.OPEN_WILDBOSSRANKPANEL then
		if(self._wildBossRankPanel == nil) then
			self._wildBossRankPanel = PanelManager.BuildPanel(ResID.UI_WILDBOSSRANKPANEL, WildBossRankPanel, false);
		end
		
		self._wildBossRankPanel:UpdatePanel(notification:GetBody())
		
	elseif notificationName == WildBossNotes.CLOSE_WILDBOSSRANKPANEL then
		if(self._wildBossRankPanel ~= nil) then
			PanelManager.RecyclePanel(self._wildBossRankPanel, ResID.UI_WILDBOSSRANKPANEL)
			self._wildBossRankPanel = nil
		end
	elseif notificationName == WildBossNotes.OPEN_WILDBOSSHURTRANKPANEL then
		if(self._wildBossHurtRankPanel == nil) then
			self._wildBossHurtRankPanel = PanelManager.BuildPanel(ResID.UI_WILDBOSSHURTRANKPANEL, WildBossHurtRankPanel, false);
			self._wildBossHurtRankPanel:SetData(notification:GetBody());
		end
	elseif notificationName == WildBossNotes.CLOSE_WILDBOSSHURTRANKPANEL then
		if(self._wildBossHurtRankPanel ~= nil) then
			PanelManager.RecyclePanel(self._wildBossHurtRankPanel, ResID.UI_WILDBOSSHURTRANKPANEL)
			self._wildBossHurtRankPanel = nil
		end
	elseif notificationName == WildBossNotes.OPEN_WILDBOSSINFOPANEL then
		if(self._wildBossInfoPanel == nil) then
			self._wildBossInfoPanel = PanelManager.BuildPanel(ResID.UI_WILDBOSSINFOPANEL, WildBossInfoPanel, false);
			self._wildBossInfoPanel:SetData(notification:GetBody());
		end
	elseif notificationName == WildBossNotes.CLOSE_WILDBOSSINFOPANEL then
		if(self._wildBossInfoPanel ~= nil) then
			PanelManager.RecyclePanel(self._wildBossInfoPanel, ResID.UI_WILDBOSSINFOPANEL)
			self._wildBossInfoPanel = nil
		end
	elseif notificationName == WildBossNotes.OPEN_WILDBOSSVIPHELPPANEL then
		if(self._wildBossVipHelpPanel == nil) then
			self._wildBossVipHelpPanel = PanelManager.BuildPanel(ResID.UI_WILDBOSSVIPHELPPANEL, WildBossVipHelpPanel, false);
		end
	elseif notificationName == WildBossNotes.CLOSE_WILDBOSSVIPHELPPANEL then
		if(self._wildBossVipHelpPanel ~= nil) then
			PanelManager.RecyclePanel(self._wildBossVipHelpPanel, ResID.UI_WILDBOSSVIPHELPPANEL)
			self._wildBossVipHelpPanel = nil
		end
	end
end

function WildBossMediator:OnRemove()
	
end

