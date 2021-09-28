require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Trump.TrumpNotes"
require "Core.Module.Trump.View.TrumpPanel"
-- require "Core.Module.Trump.View.TrumpObtainPanel"
require "Core.Module.Trump.View.TrumpInfoPanel"



TrumpMediator = Mediator:New();
function TrumpMediator:OnRegister()

end

function TrumpMediator:_ListNotificationInterests()
    return
    {
        [1] = TrumpNotes.OPEN_TRUMPPANEL,
        [2] = TrumpNotes.CLOSE_TRUMPPANEL,
        [3] = TrumpNotes.UPDATE_TRUMPPANEL,
        [4] = TrumpNotes.UPDATE_TRUMPPANEL_SELECTMATERIAL,

        [5] = TrumpNotes.OPEN_TRUMPOBTAINPANEL,
        [6] = TrumpNotes.CLOSE_TRUMPOBTAINPANEL,
        [7] = TrumpNotes.UPDATE_TRUMPOBTAINPANEL,

        [8] = TrumpNotes.OPEN_TRUMPINFOPANEL,
        [9] = TrumpNotes.CLOSE_TRUMPINFOPANEL,

        [10] = TrumpNotes.UPDATE_SUBTRUMPPANEL_DATA,
        [11] = TrumpNotes.SET_ACTIVESELECT_PANEL,

        [12] = TrumpNotes.UPDATE_SUBTRUMPREFINEPANEL_DATA,
        [13] = TrumpNotes.SET_TRUMPOBTAINPANELSELECTPANEL,
    }
end

function TrumpMediator:_HandleNotification(notification)
    if notification:GetName() == TrumpNotes.OPEN_TRUMPPANEL then
        if (self._trumpPanel == nil) then
            self._trumpPanel = PanelManager.BuildPanel(ResID.UI_TRUMPPANEL, TrumpPanel, true)
        end
    elseif notification:GetName() == TrumpNotes.CLOSE_TRUMPPANEL then
        if (self._trumpPanel ~= nil) then
            PanelManager.RecyclePanel(self._trumpPanel, ResID.UI_TRUMPPANEL)
            self._trumpPanel = nil
        end
    elseif notification:GetName() == TrumpNotes.UPDATE_TRUMPPANEL then
        if (self._trumpPanel ~= nil) then
            self._trumpPanel:UpdateTrumpSubPanel()
        end
    elseif notification:GetName() == TrumpNotes.UPDATE_TRUMPPANEL_SELECTMATERIAL then
        if (self._trumpPanel ~= nil) then
            self._trumpPanel:UpdateSelectMaterial()
        end
    elseif notification:GetName() == TrumpNotes.SET_ACTIVESELECT_PANEL then
        if (self._trumpPanel ~= nil) then
            self._trumpPanel:SetActiveSelectPanel()
        end

        --    elseif notification:GetName() == TrumpNotes.OPEN_TRUMPOBTAINPANEL then
        --        if (self._trumpObtainPanel == nil) then
        --            self._trumpObtainPanel = PanelManager.BuildPanel(ResID.UI_TRUMPOBTAINPANEL, TrumpObtainPanel)
        --            --            self._trumpObtainPanel:UpdateTrumpObtainPanel()
        --        end
        --    elseif notification:GetName() == TrumpNotes.CLOSE_TRUMPOBTAINPANEL then
        --        if (self._trumpObtainPanel ~= nil) then
        --            PanelManager.RecyclePanel(self._trumpObtainPanel)
        --            self._trumpObtainPanel = nil
        --        end
    elseif notification:GetName() == TrumpNotes.UPDATE_TRUMPOBTAINPANEL then
        if (self._trumpObtainPanel ~= nil) then
            self._trumpObtainPanel:UpdateTrumpObtainPanel()
        end
    elseif notification:GetName() == TrumpNotes.OPEN_TRUMPINFOPANEL then
        if (self._trumpInfoPanel == nil) then
            self._trumpInfoPanel = PanelManager.BuildPanel(ResID.UI_TRUMPINFOPANEL, TrumpInfoPanel)
            self._trumpInfoPanel:UpdatePanel(notification:GetBody())
        end
    elseif notification:GetName() == TrumpNotes.CLOSE_TRUMPINFOPANEL then
        if (self._trumpInfoPanel ~= nil) then
            PanelManager.RecyclePanel(self._trumpInfoPanel, ResID.UI_TRUMPINFOPANEL)
            self._trumpInfoPanel = nil
        end
    elseif notification:GetName() == TrumpNotes.UPDATE_SUBTRUMPPANEL_DATA then
        if (self._trumpPanel ~= nil) then
            self._trumpPanel:UpdateSubPanelTrumpData(notification:GetBody())
        end
    elseif notification:GetName() == TrumpNotes.UPDATE_SUBTRUMPREFINEPANEL_DATA then
        if (self._trumpPanel ~= nil) then
            self._trumpPanel:UpdateSubRefinePanelTrumpData(notification:GetBody())
        end
    elseif notification:GetName() == TrumpNotes.SET_TRUMPOBTAINPANELSELECTPANEL then
        if (self._trumpPanel ~= nil) then
            self._trumpPanel:SetObtainPanelSelectPanel()
        end
    end

end

function TrumpMediator:OnRemove()
    if (self._trumpPanel ~= nil) then
        PanelManager.RecyclePanel(self._trumpPanel, ResID.UI_TRUMPPANEL)
        self._trumpPanel = nil
    end
    --    if (self._trumpObtainPanel ~= nil) then
    --        PanelManager.RecyclePanel(self._trumpObtainPanel)
    --        self._trumpObtainPanel = nil
    --    end

    if (self._trumpInfoPanel ~= nil) then
        PanelManager.RecyclePanel(self._trumpInfoPanel, ResID.UI_TRUMPINFOPANEL)
        self._trumpInfoPanel = nil
    end
end

