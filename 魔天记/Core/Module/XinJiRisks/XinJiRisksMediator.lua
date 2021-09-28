require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.XinJiRisks.XinJiRisksNotes"

local XinJiRisksPanel = require "Core.Module.XinJiRisks.View.XinJiRisksPanel";

local XinJiRisksMediator = Mediator:New();

function XinJiRisksMediator:OnRegister()

end

local notes =
{
    XinJiRisksNotes.OPEN_XINJIRISKSPANEL,
    XinJiRisksNotes.CLOSE_XINJIRISKSPANEL,

}

function XinJiRisksMediator:_ListNotificationInterests()
    return notes
end

function XinJiRisksMediator:_HandleNotification(notification)
    local notificationName = notification:GetName()

    local data = notification:GetBody();

    if notificationName == XinJiRisksNotes.OPEN_XINJIRISKSPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_XinJiRisksPanel, XinJiRisksPanel, true);
           
        end
        self._panel:SetData(data)
    elseif notificationName == XinJiRisksNotes.CLOSE_XINJIRISKSPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_XinJiRisksPanel)
           
            self._panel = nil
        end
    end

end

function XinJiRisksMediator:OnRemove()

end

return XinJiRisksMediator