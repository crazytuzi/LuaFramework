require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.LD.LDNotes"
require "Core.Module.LD.View.LDPanel"

LDMediator = Mediator:New();
function LDMediator:OnRegister()

end

function LDMediator:_ListNotificationInterests()
    return
    {
        [1] = LDNotes.OPEN_LDPANEL,
        [2] = LDNotes.CLOSE_LDPANEL,
    }
end

function LDMediator:_HandleNotification(notification)
    if (notification:GetName() == LDNotes.OPEN_LDPANEL) then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_LDPANEL, LDPanel,false,LDNotes.CLOSE_LDPANEL);
        end
    elseif notification:GetName() == LDNotes.CLOSE_LDPANEL then
        PanelManager.RecyclePanel(self._panel,ResID.UI_LDPANEL)
        self._panel = nil
    end
end

function LDMediator:OnRemove()

end