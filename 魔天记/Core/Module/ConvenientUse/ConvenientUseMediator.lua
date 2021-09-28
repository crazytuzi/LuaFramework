require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ConvenientUse.ConvenientUseNotes"

require "Core.Module.ConvenientUse.View.ConvenientUsePanel"

local ConvenientBuyPanel = require "Core.Module.ConvenientUse.View.ConvenientBuyPanel";

ConvenientUseMediator = Mediator:New();
function ConvenientUseMediator:OnRegister()

end

function ConvenientUseMediator:_ListNotificationInterests()

    return {
        [1] = ConvenientUseNotes.SHOW_CONVENIENTUSEPANEL,
        [2] = ConvenientUseNotes.CLOSE_CONVENIENTUSEPANEL,
        [3] = ConvenientUseNotes.CLOSE_CONVENIENTUSEPANEL_FORCE,
        -- 强制广播
        [4] = TaskNotes.OPEN_TASKACTIONPANEL,
        [5] = TaskNotes.CLOSE_TASKACTIONPANEL,

        [6] = ConvenientUseNotes.SHOW_CONVENIENTBUYPANEL,
        [7] = ConvenientUseNotes.CLOSE_CONVENIENTBUYPANEL,


    };

end

function ConvenientUseMediator:_HandleNotification(notification)


    if notification:GetName() == ConvenientUseNotes.SHOW_CONVENIENTUSEPANEL then

        if (self._convenientUsePanel == nil) then
            self._convenientUsePanel = PanelManager.BuildPanel(ResID.UI_CONVENIENTUSEPANEL, ConvenientUsePanel, false, ConvenientUseNotes.CLOSE_CONVENIENTUSEPANEL_FORCE);
        end
        local pinfo = notification:GetBody();
        self._convenientUsePanel:SetData(pinfo);

        ConvenientUseControll.GetIns():OpenConvenientUsePanel();

    elseif notification:GetName() == ConvenientUseNotes.CLOSE_CONVENIENTUSEPANEL then

        if (self._convenientUsePanel ~= nil) then
            PanelManager.RecyclePanel(self._convenientUsePanel)
            self._convenientUsePanel = nil;

            ConvenientUseControll.GetIns():CloseConvenientUsePanel();

        end

    elseif notification:GetName() == ConvenientUseNotes.CLOSE_CONVENIENTUSEPANEL_FORCE then
        -- 强制关闭
        if (self._convenientUsePanel ~= nil) then
            PanelManager.RecyclePanel(self._convenientUsePanel)
            self._convenientUsePanel = nil;

            ConvenientUseControll.GetIns():CleanData();

        end
        ------------------------------------------------------

    elseif notification:GetName() == TaskNotes.OPEN_TASKACTIONPANEL then
        ConvenientUseControll.GetIns():OpenTaskActPane();

    elseif notification:GetName() == TaskNotes.CLOSE_TASKACTIONPANEL then
        ConvenientUseControll.GetIns():CloseTaskActPane();

        ------------------------------------------------------------------------
    elseif notification:GetName() == ConvenientUseNotes.SHOW_CONVENIENTBUYPANEL then
        if (self._convenientBuyPanel == nil) then
            self._convenientBuyPanel = PanelManager.BuildPanel(ResID.UI_CONVENIENTBUYPANEL, ConvenientBuyPanel, false);
        end
        local pinfo = notification:GetBody();
        self._convenientBuyPanel:SetData(pinfo);

    elseif notification:GetName() == ConvenientUseNotes.CLOSE_CONVENIENTBUYPANEL then
        if (self._convenientBuyPanel ~= nil) then
            PanelManager.RecyclePanel(self._convenientBuyPanel)
            self._convenientBuyPanel = nil;

        end
    end

end

function ConvenientUseMediator:OnRemove()

end

