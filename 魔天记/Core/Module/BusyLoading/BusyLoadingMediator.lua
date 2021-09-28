require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.BusyLoading.BusyLoadingNotes"
require "Core.Module.BusyLoading.View.BusyLoadingPanel"

BusyLoadingMediator = Mediator:New();
function BusyLoadingMediator:OnRegister()

end

function BusyLoadingMediator:_ListNotificationInterests()
    return {
        [1] = BusyLoadingNotes.OPEN_BUSYLOADINGPANEL,
        [2] = BusyLoadingNotes.CLOSE_BUSYLOADINGPANEL,

    };
end

function BusyLoadingMediator:_HandleNotification(notification)



    if notification:GetName() == BusyLoadingNotes.OPEN_BUSYLOADINGPANEL then
        local plData = notification:GetBody();
        if (self._busyLoadingPanel == nil) then
            self._busyLoadingPanel = PanelManager.BuildPanel(ResID.UI_BUSYLOADINGPANEL, BusyLoadingPanel, false);
        end
        self._busyLoadingPanel:SetData(plData);

    elseif notification:GetName() == BusyLoadingNotes.CLOSE_BUSYLOADINGPANEL then
        if (self._busyLoadingPanel ~= nil) then
            PanelManager.RecyclePanel(self._busyLoadingPanel, ResID.UI_BUSYLOADINGPANEL)
            self._busyLoadingPanel = nil
        end

    end

end

function BusyLoadingMediator:OnRemove()

end

