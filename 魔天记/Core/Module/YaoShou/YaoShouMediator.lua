require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.YaoShou.YaoShouNotes"

local YaoShouBossPanel = require "Core.Module.YaoShou.View.YaoShouBossPanel"
local YaoShouHelpPanel = require "Core.Module.YaoShou.View.YaoShouHelpPanel"

local YaoShouMediator = Mediator:New();
local notes = {
	YaoShouNotes.OPEN_YAOSHOUPANEL,
	YaoShouNotes.CLOSE_YAOSHOUPANEL,
	YaoShouNotes.OPEN_YAOSHOU_HELP_PANEL,
	YaoShouNotes.CLOSE_YAOSHOU_HELP_PANEL,
}

function YaoShouMediator:OnRegister()

end

function YaoShouMediator:_ListNotificationInterests()
	return notes
end

function YaoShouMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()

	if notificationName == YaoShouNotes.OPEN_YAOSHOUPANEL then
		if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_YaoShou_Panel, YaoShouBossPanel, false, YaoShouNotes.CLOSE_YAOSHOUPANEL);            
        end
	elseif notificationName == YaoShouNotes.CLOSE_YAOSHOUPANEL then
		if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel);
            self._panel = nil;
        end
    elseif notificationName == YaoShouNotes.OPEN_YAOSHOU_HELP_PANEL then
		if(self._helpPanel == nil) then
			self._helpPanel = PanelManager.BuildPanel(ResID.UI_YaoShou_Help_Panel, YaoShouHelpPanel, false);
		end
	elseif notificationName == YaoShouNotes.CLOSE_YAOSHOU_HELP_PANEL then
		if(self._helpPanel ~= nil) then
			PanelManager.RecyclePanel(self._helpPanel, ResID.UI_YaoShou_Help_Panel)
			self._helpPanel = nil
		end


	end

end

function YaoShouMediator:OnRemove()
	
end

return YaoShouMediator