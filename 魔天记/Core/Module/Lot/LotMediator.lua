require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Lot.LotNotes"
local LotPanel = require "Core.Module.Lot.View.LotPanel"

local LotMediator = Mediator:New();
function LotMediator:OnRegister()

end

function LotMediator:_ListNotificationInterests()
    return {
        LotNotes.OPEN_LOT_PANEL,
        LotNotes.CLOSE_LOT_PANEL,
    }
end

function LotMediator:_HandleNotification(notification)
    local n = notification:GetName()
    if n == LotNotes.OPEN_LOT_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_LOT_PANEL, LotPanel, true);
        end
    elseif n == LotNotes.CLOSE_LOT_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_LOT_PANEL)
            self._panel = nil
        end
    end
end

function LotMediator:OnRemove()

end

return LotMediator