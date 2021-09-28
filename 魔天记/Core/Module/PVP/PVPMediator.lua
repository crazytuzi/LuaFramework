require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.PVP.PVPNotes"
require "Core.Module.PVP.View.PVPPanel"
require "Core.Module.PVP.View.PVPRankPanel"


PVPMediator = Mediator:New();
function PVPMediator:OnRegister()

end

function PVPMediator:_ListNotificationInterests()
    return
    {
        [1] = PVPNotes.OPEN_PVPPANEL,
        [2] = PVPNotes.CLOSE_PVPPANEL,
        [3] = PVPNotes.UPDATE_PVPPANEL,
        [4] = PVPNotes.UPDATE_PVPPANEL_SELECTPLAYER,
        [5] = PVPNotes.UPDATE_PVPPANEL_LIMITTIME,
        [6] = PVPNotes.UPDATE_PVPPANEL_PVPPOINT,
        [7] = PVPNotes.UPDATE_PVPPANEL_PLAYERLIST,

        [8] = PVPNotes.OPEN_PVPRANKPANEL,
        [9] = PVPNotes.CLOSE_PVPRANKPANEL,
        [10] = PVPNotes.UPDATE_PVPRANKPANEL,

    }
end

function PVPMediator:_HandleNotification(notification)
    if notification:GetName() == PVPNotes.OPEN_PVPPANEL then
        if (self._pvpPanel == nil) then
            self._pvpPanel = PanelManager.BuildPanel(ResID.UI_PVPPANEL, PVPPanel,true);
        end
        if (self._pvpPanel ~= nil) then
            self._pvpPanel:UpdateOtherPlayerList()
        end
    elseif notification:GetName() == PVPNotes.CLOSE_PVPPANEL then
        if (self._pvpPanel ~= nil) then
            PanelManager.RecyclePanel(self._pvpPanel,ResID.UI_PVPPANEL)
            self._pvpPanel = nil
        end
    elseif notification:GetName() == PVPNotes.UPDATE_PVPPANEL then
        if (self._pvpPanel ~= nil) then

        end
    elseif notification:GetName() == PVPNotes.UPDATE_PVPPANEL_SELECTPLAYER then
        if (self._pvpPanel ~= nil) then
            self._pvpPanel:UpdateOtherPlayer(notification:GetBody())
        end
    elseif notification:GetName() == PVPNotes.UPDATE_PVPPANEL_LIMITTIME then
        if (self._pvpPanel ~= nil) then
            self._pvpPanel:UpdatePVPLimitTime()
        end
    elseif notification:GetName() == PVPNotes.UPDATE_PVPPANEL_PVPPOINT then
        if (self._pvpPanel ~= nil) then
            self._pvpPanel:UpdatePVPPoint()
        end
    elseif notification:GetName() == PVPNotes.UPDATE_PVPPANEL_PLAYERLIST then
        if (self._pvpPanel ~= nil) then
            self._pvpPanel:UpdateOtherPlayerList()
        end
    elseif notification:GetName() == PVPNotes.OPEN_PVPRANKPANEL then
        if (self._pvpRankPanel == nil) then
            self._pvpRankPanel = PanelManager.BuildPanel(ResID.UI_PVPRANKPANEL, PVPRankPanel);
        end
    elseif notification:GetName() == PVPNotes.CLOSE_PVPRANKPANEL then
        if (self._pvpRankPanel ~= nil) then
            PanelManager.RecyclePanel(self._pvpRankPanel,ResID.UI_PVPRANKPANEL)
            self._pvpRankPanel = nil
        end
    elseif notification:GetName() == PVPNotes.UPDATE_PVPRANKPANEL then
        if (self._pvpRankPanel ~= nil) then
            self._pvpRankPanel:UpdatePVPRankPanel()
        end
    end


end

function PVPMediator:OnRemove()
    if (self._pvpPanel ~= nil) then
        PanelManager.RecyclePanel(self._pvpPanel,ResID.UI_PVPPANEL)
        self._pvpPanel = nil
    end
    if (self._pvpRankPanel ~= nil) then
        PanelManager.RecyclePanel(self._pvpRankPanel,ResID.UI_PVPRANKPANEL)
        self._pvpRankPanel = nil
    end
end

