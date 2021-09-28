require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Formation.FormationNotes"

local FormationMediator = Mediator:New();
local notes = {
FormationNotes.OPEN_FORMATION_PANEL
,FormationNotes.CLOSE_FORMATION_PANEL
}
function FormationMediator:OnRegister()

end

function FormationMediator:_ListNotificationInterests()
	return notes
end

function FormationMediator:_HandleNotification(notification)
	local n = notification:GetName()
    if n == FormationNotes.OPEN_FORMATION_PANEL  then
        if (self._panel == nil) then
            local panel = require "Core.Module.Formation.View.FormationPanel"
            self._panel = PanelManager.BuildPanel(ResID.UI_FORMATION_PANEL, panel, true)
        end
        local bd = notification:GetBody()
        self._panel:SetPanel(bd)
    elseif n == FormationNotes.CLOSE_FORMATION_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_FORMATION_PANEL)
            self._panel = nil
        end
    end
end

function FormationMediator:OnRemove()

end

return FormationMediator