require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.LSInstance.LSInstanceNotes"
require "Core.Module.LSInstance.View.LSInstancePanel"
require "Core.Module.LSInstance.View.LSWaitForJoinPanel"


LSInstanceMediator = Mediator:New();
function LSInstanceMediator:OnRegister()

end

function LSInstanceMediator:_ListNotificationInterests()
    return {
        [1] = LSInstanceNotes.OPEN_LSINSTANCEPANEL,
        [2] = LSInstanceNotes.CLOSE_LSINSTANCEPANEL,

        [3] = LSInstanceNotes.OPEN_LSWAITFORJOINPANEL,
        [4] = LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL,

    };
end

function LSInstanceMediator:_HandleNotification(notification)

    if notification:GetName() == LSInstanceNotes.OPEN_LSINSTANCEPANEL then

        if (self._lsinstancePanel == nil) then
            self._lsinstancePanel = PanelManager.BuildPanel(ResID.UI_LSINSTANCEPANEL, LSInstancePanel, true);
        end
        local plData = notification:GetBody();
        self._lsinstancePanel:InitFbList(plData)

    elseif notification:GetName() == LSInstanceNotes.CLOSE_LSINSTANCEPANEL then
        if (self._lsinstancePanel ~= nil) then
            PanelManager.RecyclePanel(self._lsinstancePanel, ResID.UI_LSINSTANCEPANEL)
            self._lsinstancePanel = nil
        end

    elseif notification:GetName() == LSInstanceNotes.OPEN_LSWAITFORJOINPANEL then

        local plData = notification:GetBody();
        if (self._lsWaitForJoinPanel == nil) then
            self._lsWaitForJoinPanel = PanelManager.BuildPanel(ResID.UI_LSWAITFORJOINPANEL, LSWaitForJoinPanel);
        end
        self._lsWaitForJoinPanel:SetFbId(plData.instId,plData.mc);

    elseif notification:GetName() == LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL then
        if (self._lsWaitForJoinPanel ~= nil) then
            PanelManager.RecyclePanel(self._lsWaitForJoinPanel, ResID.UI_LSWAITFORJOINPANEL)
            self._lsWaitForJoinPanel = nil
        end

    end

end

function LSInstanceMediator:OnRemove()

end

