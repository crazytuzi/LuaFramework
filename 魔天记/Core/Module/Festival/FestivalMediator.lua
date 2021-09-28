require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Festival.FestivalNotes"

local FestivalMediator = Mediator:New();
local notes = {
    FestivalNotes.OPEN_FESTIVAL_PANEL
    ,FestivalNotes.CLOSE_FESTIVAL_PANEL
}
function FestivalMediator:OnRegister()

end

function FestivalMediator:_ListNotificationInterests()
	return notes
end

function FestivalMediator:_HandleNotification(notification)
	local n = notification:GetName()
    if n == FestivalNotes.OPEN_FESTIVAL_PANEL  then
        if (self._panel == nil) then
            local panel = require "Core.Module.Festival.View.FestivalPanel"
            self._panel = PanelManager.BuildPanel(ResID.UI_FESTIVAL_PANEL, panel, false)
        end
    elseif n == FestivalNotes.CLOSE_FESTIVAL_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_FESTIVAL_PANEL)
            self._panel = nil
        end
    end
end

function FestivalMediator:OnRemove()

end

return FestivalMediator