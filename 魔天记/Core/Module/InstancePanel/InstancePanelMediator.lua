require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.InstancePanel.InstancePanelNotes"
require "Core.Module.InstancePanel.View.InstancePanel"
require "Core.Module.InstancePanel.View.InstanceAwardPanel"
require "Core.Module.InstancePanel.View.InstanceShaoDangInfoPanel"



InstancePanelMediator = Mediator:New();
local notice = LanguageMgr.Get("InstancePanelMediator/quitNotice")
function InstancePanelMediator:OnRegister()

end

function InstancePanelMediator:_ListNotificationInterests()
    return {
        [1] = InstancePanelNotes.OPEN_INSTANCEPANEL,
        [2] = InstancePanelNotes.CLOSE_INSTANCEPANEL,
        [3] = InstancePanelNotes.OPEN_INSTANCEAWARDPANEL,
        [4] = InstancePanelNotes.CLOSE_INSTANCEAWARDPANEL,
        [5] = InstancePanelNotes.OPEN_INSTANCESHAODANGINFOPANEL,
        [6] = InstancePanelNotes.CLOSE_INSTANCESHAODANGINFOPANEL,
        [7]=InstancePanelNotes.WANT_TO_LEAVE_FB,
    };
end

function InstancePanelMediator:_HandleNotification(notification)

    if notification:GetName() == InstancePanelNotes.OPEN_INSTANCEPANEL then

        if (self._instancePanel == nil) then
            self._instancePanel = PanelManager.BuildPanel(ResID.UI_INSTANCEPANEL, InstancePanel,true);
        end
         local data = notification:GetBody();
        self._instancePanel :SetData(data)

    elseif notification:GetName() == InstancePanelNotes.CLOSE_INSTANCEPANEL then
        if (self._instancePanel ~= nil) then
            PanelManager.RecyclePanel(self._instancePanel,ResID.UI_INSTANCEPANEL)
            self._instancePanel = nil
        end


    elseif notification:GetName() == InstancePanelNotes.OPEN_INSTANCEAWARDPANEL then
        if (self._instanceAwardPanel == nil) then
            self._instanceAwardPanel = PanelManager.BuildPanel(ResID.UI_INSTANCEAWARDPANEL, InstanceAwardPanel);
        end

        local data = notification:GetBody();
        self._instanceAwardPanel:SetData(data);

    elseif notification:GetName() == InstancePanelNotes.CLOSE_INSTANCEAWARDPANEL then
        if (self._instanceAwardPanel ~= nil) then
            PanelManager.RecyclePanel(self._instanceAwardPanel)
            self._instanceAwardPanel = nil
        end


    elseif notification:GetName() == InstancePanelNotes.OPEN_INSTANCESHAODANGINFOPANEL then

        if (self._instanceShaoDangInfoPanel == nil) then
            self._instanceShaoDangInfoPanel = PanelManager.BuildPanel(ResID.UI_INSTANCESHAODANGINFOPANEL, InstanceShaoDangInfoPanel);
        end

       
        local data = notification:GetBody();
        self._instanceShaoDangInfoPanel:SetData(data);

    elseif notification:GetName() == InstancePanelNotes.CLOSE_INSTANCESHAODANGINFOPANEL then
        if (self._instanceShaoDangInfoPanel ~= nil) then
            PanelManager.RecyclePanel(self._instanceShaoDangInfoPanel)
            self._instanceShaoDangInfoPanel = nil
        end

          elseif notification:GetName() == InstancePanelNotes.WANT_TO_LEAVE_FB then

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            msg = notice,
            hander = InstancePanelProxy.OutFBHandler,
            data = nil
        } );

    end

end



function InstancePanelMediator:OnRemove()

end

