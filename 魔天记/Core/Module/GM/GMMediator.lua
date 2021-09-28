require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.GM.GMNotes"
require "Core.Module.GM.View.GMPanel"

GMMediator = Mediator:New();
function GMMediator:OnRegister()

end

function GMMediator:_ListNotificationInterests()
    return
    {
        [1] = GMNotes.OPEN_GMPANEL,
        [2] = GMNotes.CLOSE_GMPANEL,
    }
end

function GMMediator:_HandleNotification(notification)
    if (notification:GetName() == GMNotes.OPEN_GMPANEL) then
        if (self._gmPanel == nil) then
            self._gmPanel = PanelManager.BuildPanel(ResID.UI_GMPANEL, GMPanel,false,GMNotes.CLOSE_GMPANEL);
        end
    elseif notification:GetName() == GMNotes.CLOSE_GMPANEL then
        PanelManager.RecyclePanel(self._gmPanel,ResID.UI_GMPANEL)
        self._gmPanel = nil
    end
end

function GMMediator:OnRemove()

end

