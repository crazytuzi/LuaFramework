require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Arathi.View.ArathiPanel"
require "Core.Module.Arathi.View.ArathiHelpPanel"
require "Core.Module.Arathi.View.ArathiTipsPanel"
require "Core.Module.Arathi.View.ArathiWarPanel"
require "Core.Module.Arathi.View.ArathiWarTipPanel"
require "Core.Module.Arathi.View.ArathiSignupPanel"
require "Core.Module.Arathi.View.ArathiSignupTipsPanel"
require "Core.Module.Arathi.View.ArathiOverResultPanel"
require "Core.Module.Arathi.View.ArathiEnterTipsPanel"

ArathiMediator = Mediator:New();
function ArathiMediator:OnRegister()

end

function ArathiMediator:_ListNotificationInterests()
    return {
        [1] = ArathiNotes.OPEN_ARATHIPANEL,
        [2] = ArathiNotes.CLOSE_ARATHIPANEL,
        [3] = ArathiNotes.OPEN_ARATHIHELPPANEL,
        [4] = ArathiNotes.CLOSE_ARATHIHELPPANEL,
        [5] = ArathiNotes.OPEN_ARATHITIPSPANEL,
        [6] = ArathiNotes.CLOSE_ARATHITIPSPANEL,
        [7] = ArathiNotes.OPEN_ARATHIWARPANEL,
        [8] = ArathiNotes.CLOSE_ARATHIWARPANEL,
        [9] = ArathiNotes.OPEN_ARATHIWARTIPSPANEL,
        [10] = ArathiNotes.CLOSE_ARATHIWARTIPSPANEL,
        [11] = ArathiNotes.OPEN_ARATHISIGNUPPANEL,
        [12] = ArathiNotes.CLOSE_ARATHISIGNUPPANEL,
        [13] = ArathiNotes.OPEN_ARATHISIGNUPTIPSPANEL,
        [14] = ArathiNotes.CLOSE_ARATHISIGNUPTIPSPANEL,
        [15] = ArathiNotes.OPEN_ARATHIOVERRESULTPANEL,
        [16] = ArathiNotes.CLOSE_ARATHIOVERRESULTPANEL,
        [17] = ArathiNotes.OPEN_ARATHIENTERTIPSPANEL,
        [18] = ArathiNotes.CLOSE_ARATHIENTERTIPSPANEL
    };
end

function ArathiMediator:_HandleNotification(notification)
    if notification:GetName() == ArathiNotes.OPEN_ARATHIPANEL then
        if (self._arathiPanel == nil) then
            self._arathiPanel = PanelManager.BuildPanel(ResID.UI_ARATHIPANEL, ArathiPanel, true);
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHIPANEL then
        if (self._arathiPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiPanel)
            self._arathiPanel = nil
        end
        -- HelpPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHIHELPPANEL then
        if (self._arathiHelpPanel == nil) then
            self._arathiHelpPanel = PanelManager.BuildPanel(ResID.UI_ARATHIHELPPANEL, ArathiHelpPanel, false);
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHIHELPPANEL then
        if (self._arathiHelpPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiHelpPanel)
            self._arathiHelpPanel = nil
        end
        -- TipsPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHITIPSPANEL then
        if (self._arathiTipsPanel == nil) then
            self._arathiTipsPanel = PanelManager.BuildPanel(ResID.UI_ARATHITIPSPANEL, ArathiTipsPanel, false);
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHITIPSPANEL then
        if (self._arathiTipsPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiTipsPanel)
            self._arathiTipsPanel = nil
        end
        -- WarkPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHIWARPANEL then
        if (self._arathiWarkPanel == nil) then
            self._arathiWarkPanel = PanelManager.BuildPanel(ResID.UI_ARATHIWARPANEL, ArathiWarPanel, false);
            self._arathiWarkPanel:SetData(notification:GetBody());
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHIWARPANEL then
        if (self._arathiWarkPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiWarkPanel)
            self._arathiWarkPanel = nil
        end
        -- WarTipPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHIWARTIPSPANEL then
        if (self._arathiWarTipPanel == nil) then
            self._arathiWarTipPanel = PanelManager.BuildPanel(ResID.UI_ARATHIWARTIPSPANEL, ArathiWarTipPanel, false);
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHIWARTIPSPANEL then
        if (self._arathiWarTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiWarTipPanel)
            self._arathiWarTipPanel = nil
        end
        -- SignupPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHISIGNUPPANEL then
        if (self._arathiSignupPanel == nil) then
            self._arathiSignupPanel = PanelManager.BuildPanel(ResID.UI_ARATHISIGNUPPANEL, ArathiSignupPanel, false,ArathiNotes.CLOSE_ARATHISIGNUPPANEL);
            self._arathiSignupPanel:SetData(notification:GetBody());
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHISIGNUPPANEL then
        if (self._arathiSignupPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiSignupPanel)
            self._arathiSignupPanel = nil
        end
        -- SignupTipsPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHISIGNUPTIPSPANEL then
        -- if (self._arathiPanel == nil) then
        if (self._arathiSignupTpisPanel == nil) then
            self._arathiSignupTpisPanel = PanelManager.BuildPanel(ResID.UI_ARATHISCENETIPSPANEL, ArathiSignupTipsPanel, false,ArathiNotes.CLOSE_ARATHISIGNUPTIPSPANEL );
        end
        -- end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHISIGNUPTIPSPANEL then
        if (self._arathiSignupTpisPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiSignupTpisPanel)
            self._arathiSignupTpisPanel = nil
        end
        -- ArathiOverResultPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHIOVERRESULTPANEL then
        if (self._arathiOverResultPanel == nil) then
            self._arathiOverResultPanel = PanelManager.BuildPanel(ResID.UI_ARATHIOVERRESULTPANEL, ArathiOverResultPanel, false,ArathiNotes.CLOSE_ARATHIOVERRESULTPANEL);
            self._arathiOverResultPanel:SetData(notification:GetBody());

        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHIOVERRESULTPANEL then
        if (self._arathiOverResultPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiOverResultPanel)
            self._arathiOverResultPanel = nil
        end
        -- ArathiEnterTipsPanel
    elseif notification:GetName() == ArathiNotes.OPEN_ARATHIENTERTIPSPANEL then
        if (self._arathiEnterTpisPanel == nil) then
            self._arathiEnterTpisPanel = PanelManager.BuildPanel(ResID.UI_ARATHISCENETIPSPANEL, ArathiEnterTipsPanel, false,ArathiNotes.CLOSE_ARATHIENTERTIPSPANEL );
        end
    elseif notification:GetName() == ArathiNotes.CLOSE_ARATHIENTERTIPSPANEL then
        if (self._arathiEnterTpisPanel ~= nil) then
            PanelManager.RecyclePanel(self._arathiEnterTpisPanel)
            self._arathiEnterTpisPanel = nil
        end
    end
end

function ArathiMediator:OnRemove()

end