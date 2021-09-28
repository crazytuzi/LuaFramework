require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.AutoFight.AutoFightNotes"
require "Core.Module.AutoFight.View.AutoFightPanel"
require "Core.Module.AutoFight.View.AutoUseDrugPanel"
require "Core.Module.AutoFight.View.AutoFightEQSetPanel"

AutoFightMediator = Mediator:New();
function AutoFightMediator:OnRegister()
    self._isAutoFight = false;
end

function AutoFightMediator:_ListNotificationInterests()
    return {
        [1] = AutoFightNotes.OPEN_AUTOFIGHTPANEL,
        [2] = AutoFightNotes.CLOSE_AUTOFIGHTPANEL,
        [3] = AutoFightNotes.START_AUTOFIGHT,
        [4] = AutoFightNotes.STOP_AUTOFIGHT,

        [5] = AutoFightNotes.OPEN_AUTOUSEDRUGPANEL,
        [6] = AutoFightNotes.CLOSE_AUTOUSEDRUGPANEL,

        [7] = AutoFightNotes.OPEN_AUTOFIGHTEQSETPANEL,
        [8] = AutoFightNotes.CLOSE_AUTOFIGHTEQSETPANEL,

    };
end

function AutoFightMediator:_HandleNotification(notification)
    if notification:GetName() == AutoFightNotes.OPEN_AUTOFIGHTPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_AutoFightPanel, AutoFightPanel, false, CLOSE_AUTOFIGHTPANEL);
        end
        self._panel:SetData(notification:GetBody());
    elseif notification:GetName() == AutoFightNotes.CLOSE_AUTOFIGHTPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    elseif notification:GetName() == AutoFightNotes.START_AUTOFIGHT then
        if (not self._isAutoFight and self._panel) then
            self._isAutoFight = true;
            -- PlayerManager.hero.StartAutoFight();
            -- 开始自动
        end
    elseif notification:GetName() == AutoFightNotes.STOP_AUTOFIGHT then
        if (self._isAutoFight) then
            self._isAutoFight = false;
            -- 结束自动
            PlayerManager.hero.StopAutoFight();
        end

        ------------------------------------------------------------
    elseif notification:GetName() == AutoFightNotes.OPEN_AUTOUSEDRUGPANEL then
        if (self._autoUseDrugPanel == nil) then
            self._autoUseDrugPanel = PanelManager.BuildPanel(ResID.UI_AUTOUSEDRUGPANEL, AutoUseDrugPanel);
        end
        self._autoUseDrugPanel:SetData(notification:GetBody());
    elseif notification:GetName() == AutoFightNotes.CLOSE_AUTOUSEDRUGPANEL then
        if (self._autoUseDrugPanel ~= nil) then
            PanelManager.RecyclePanel(self._autoUseDrugPanel)
            self._autoUseDrugPanel = nil
        end

        ------------------------------------------------------------------
    elseif notification:GetName() == AutoFightNotes.OPEN_AUTOFIGHTEQSETPANEL then
        if (self._autoFightEQSetPanel == nil) then
            self._autoFightEQSetPanel = PanelManager.BuildPanel(ResID.UI_AUTOFIGHTEQSETPANEL, AutoFightEQSetPanel);
        end

    elseif notification:GetName() == AutoFightNotes.CLOSE_AUTOFIGHTEQSETPANEL then
        if (self._autoFightEQSetPanel ~= nil) then
            PanelManager.RecyclePanel(self._autoFightEQSetPanel)
            self._autoFightEQSetPanel = nil
        end


    end
end

function AutoFightMediator:OnRemove()

end