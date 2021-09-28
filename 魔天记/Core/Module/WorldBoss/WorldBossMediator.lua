require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.WorldBoss.WorldBossNotes"
require "Core.Module.WorldBoss.View.WorldBossPanel"
require "Core.Module.WorldBoss.View.WorldBossHelpPanel"
require "Core.Module.WorldBoss.View.WorldBossHurtRankPanel"

WorldBossMediator = Mediator:New();
function WorldBossMediator:OnRegister()

end

function WorldBossMediator:_ListNotificationInterests()
	return
	{
		[1] = WorldBossNotes.OPEN_WORLDBOSSPANEL,
		[2] = WorldBossNotes.CLOSE_WORLDBOSSPANEL,
		[3] = WorldBossNotes.OPEN_WORLDBOSSHELPPANEL,
		[4] = WorldBossNotes.CLOSE_WORLDBOSSHELPPANEL,
		[5] = WorldBossNotes.OPEN_WORLDBOSSHURTRANKPANEL,
		[6] = WorldBossNotes.CLOSE_WORLDBOSSHURTRANKPANEL,
	}
end

function WorldBossMediator:_HandleNotification(notification)
	if notification:GetName() == WorldBossNotes.OPEN_WORLDBOSSPANEL then
		if (self._worldBossPanel == nil) then
			self._worldBossPanel = PanelManager.BuildPanel(ResID.UI_WORLDBOSSPANEL, WorldBossPanel, true);
		end
	elseif notification:GetName() == WorldBossNotes.CLOSE_WORLDBOSSPANEL then
		if (self._worldBossPanel ~= nil) then
			PanelManager.RecyclePanel(self._worldBossPanel, ResID.UI_WORLDBOSSPANEL)
			self._worldBossPanel = nil
		end
	elseif notification:GetName() == WorldBossNotes.OPEN_WORLDBOSSHELPPANEL then
		if (self._worldBossHelpPanel == nil) then
			self._worldBossHelpPanel = PanelManager.BuildPanel(ResID.UI_WORLDBOSSHELPPANEL, WorldBossHelpPanel, false);
		end
	elseif notification:GetName() == WorldBossNotes.CLOSE_WORLDBOSSHELPPANEL then
		if (self._worldBossHelpPanel ~= nil) then
			PanelManager.RecyclePanel(self._worldBossHelpPanel, ResID.UI_WORLDBOSSHELPPANEL)
			self._worldBossHelpPanel = nil
		end
	elseif notification:GetName() == WorldBossNotes.OPEN_WORLDBOSSHURTRANKPANEL then
		if (self._worldBossHurtRankPanel == nil) then
			self._worldBossHurtRankPanel = PanelManager.BuildPanel(ResID.UI_WORLDBOSSHURTRANKPANEL, WorldBossHurtRankPanel, false);
		end
	elseif notification:GetName() == WorldBossNotes.CLOSE_WORLDBOSSHURTRANKPANEL then
		if (self._worldBossHurtRankPanel ~= nil) then
			PanelManager.RecyclePanel(self._worldBossHurtRankPanel, ResID.UI_WORLDBOSSHURTRANKPANEL)
			self._worldBossHurtRankPanel = nil
		end
	end
end

function WorldBossMediator:OnRemove()

end

