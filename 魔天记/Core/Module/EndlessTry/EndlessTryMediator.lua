require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.EndlessTry.EndlessTryNotes"
local InspirePanel = require "Core.Module.EndlessTry.View.InspirePanel"
local UseExpPanel = require "Core.Module.EndlessTry.View.UseExpPanel"

local EndlessTryMediator = Mediator:New();
function EndlessTryMediator:OnRegister()

end

function EndlessTryMediator:_ListNotificationInterests()
    return {
        EndlessTryNotes.OPEN_ENDLESS_EXP_BUY_PANEL ,
        EndlessTryNotes.CLOSE_ENDLESS_EXP_BUY_PANEL ,

        EndlessTryNotes.OPEN_ENDLESS_INSPRIE_PANEL,
        EndlessTryNotes.CLOSE_ENDLESS_INSPRIE_PANEL 
    };
end

function EndlessTryMediator:_HandleNotification(notification)
    local nn = notification:GetName()
    if nn == EndlessTryNotes.OPEN_ENDLESS_INSPRIE_PANEL then
        if (self._inspirePanel == nil) then
            self._inspirePanel = PanelManager.BuildPanel(ResID.UI_ENDLESSTRY_INSPIRE, InspirePanel, false)
        end
    elseif nn == EndlessTryNotes.CLOSE_ENDLESS_INSPRIE_PANEL then
        if (self._inspirePanel ~= nil) then
            PanelManager.RecyclePanel(self._inspirePanel, ResID.UI_ENDLESSTRY_INSPIRE)
            self._inspirePanel = nil
        end
     elseif nn == EndlessTryNotes.OPEN_ENDLESS_EXP_BUY_PANEL then
        if (self._useExpPanel == nil) then
            self._useExpPanel = PanelManager.BuildPanel(ResID.UI_ENDLESSTRY_USEEXP, UseExpPanel, false)
        end
    elseif nn == EndlessTryNotes.CLOSE_ENDLESS_EXP_BUY_PANEL then
        if (self._useExpPanel ~= nil) then
            PanelManager.RecyclePanel(self._useExpPanel, ResID.UI_ENDLESSTRY_USEEXP)
            self._useExpPanel = nil
        end
    end
end

function EndlessTryMediator:OnRemove()

end

return EndlessTryMediator