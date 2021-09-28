require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Taboo.TabooNotes"
local TabooPanel = require "Core.Module.Taboo.View.TabooPanel"

local TabooMediator = Mediator:New();
function TabooMediator:OnRegister()

end

function TabooMediator:_ListNotificationInterests()
    return {
        TabooNotes.OPEN_TABOO_PANEL,
        TabooNotes.CLOSE_TABOO_PANEL,
        TabooNotes.TABOO_COLLECT_NUM,
    };
end

function TabooMediator:_HandleNotification(notification)
    local t = notification:GetName()
    if t == TabooNotes.OPEN_TABOO_PANEL then
        if (self._panel == nil) then
            TabooProxy.SetActiveData(notification:GetBody())
            self._panel = PanelManager.BuildPanel(ResID.UI_TABOO_PANEL, TabooPanel)
        end
    elseif t == TabooNotes.CLOSE_TABOO_PANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_TABOO_PANEL)
            self._panel = nil
        end
    end
end

function TabooMediator:OnRemove()

end

return TabooMediator