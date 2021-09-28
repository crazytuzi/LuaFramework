require "Core.Module.Pattern.Mediator";
require "Core.Module.Login.LoginNotes";
require "Core.Module.Common.ResID";
require "Core.Module.Login.View.LoginPanel";
require "Core.Module.Login.View.GotoGamePanel";
require "Core.Module.Login.View.SelectServerPanel";
require "Core.Module.Login.View.TestCodePanel";
LoginMediator = Mediator:New()
function LoginMediator:OnRegister()
    self._loginPanel = PanelManager.BuildPanel(ResID.UI_LOGINPANEL, LoginPanel, true);

    local isShow = Util.GetInt("korea_agreement", 0)
    if (isShow == 0 and(GameConfig.instance.platformId == 3)) then
        local AgreeMentPanel = require "Core.Module.Login.View.AgreeMentPanel"
        self._agreeMentPanel = PanelManager.BuildPanel(ResID.UI_AGREEMENTPANEL, AgreeMentPanel, false);
    else
        -- Warning(tostring(GameConfig.PreloadAppSplit()) .. '---' .. tostring(AppSplitDownProxy.ForceLoad()))
        if GameConfig.PreloadAppSplit() and not AppSplitDownProxy.ForceLoad() then return end
    end
end

function LoginMediator:_ListNotificationInterests()
    return {
        LoginNotes.OPEN_LOGIN_PANEL,
        LoginNotes.CLOSE_LOGIN_PANEL,
        LoginNotes.OPEN_GOTOGAME_PANEL,
        LoginNotes.CLOSE_GOTOGAME_PANEL,
        LoginNotes.OPEN_SELECTSERVER_PANEL,
        LoginNotes.CLOSE_SELECTSERVER_PANEL,
        LoginNotes.OPEN_TESTCODE_PANEL,
        LoginNotes.CLOSE_TESTCODE_PANEL,
        LoginNotes.CLOSE_AGREENMENTPANEL,
    };
end

function LoginMediator:_HandleNotification(notification)

    if notification:GetName() == LoginNotes.OPEN_LOGIN_PANEL then
        if (self._loginPanel == nil) then
            self._loginPanel = PanelManager.BuildPanel(ResID.UI_LOGINPANEL, LoginPanel, true);
        end
    elseif notification:GetName() == LoginNotes.CLOSE_LOGIN_PANEL then
        if self._loginPanel ~= nil then
            PanelManager.RecyclePanel(self._loginPanel, ResID.UI_LOGINPANEL)
            self._loginPanel = nil
        end
    elseif (notification:GetName() == LoginNotes.OPEN_GOTOGAME_PANEL) then
        if (self._gotoGamePanel == nil) then
            self._gotoGamePanel = PanelManager.BuildPanel(ResID.UI_GOTOGAMEPANEL, GotoGamePanel, true, nil, true);
        end
    elseif (notification:GetName() == LoginNotes.CLOSE_GOTOGAME_PANEL) then
        if (self._gotoGamePanel ~= nil) then
            PanelManager.RecyclePanel(self._gotoGamePanel, ResID.UI_GOTOGAMEPANEL, true)
            self._gotoGamePanel = nil
        end
    elseif (notification:GetName() == LoginNotes.UPDATE_GOTOGAME_PANEL) then
        if (self._gotoGamePanel ~= nil) then
            self._gotoGamePanel:UpdateGoToGamePanel()
        end
    elseif (notification:GetName() == LoginNotes.OPEN_SELECTSERVER_PANEL) then
        if (self._selectServerPanel == nil) then
            self._selectServerPanel = PanelManager.BuildPanel(ResID.UI_SELECTSERVERPANEL, SelectServerPanel, false, nil, true)
        end
    elseif (notification:GetName() == LoginNotes.CLOSE_SELECTSERVER_PANEL) then
        if (self._selectServerPanel ~= nil) then
            PanelManager.RecyclePanel(self._selectServerPanel, ResID.UI_SELECTSERVERPANEL, true)
            self._selectServerPanel = nil
        end

    elseif notification:GetName() == LoginNotes.OPEN_TESTCODE_PANEL then
        if (self._testCodePanel == nil) then
            self._testCodePanel = PanelManager.BuildPanel(ResID.UI_TESTCODEPANEL, TestCodePanel, false, nil, true);
        end
    elseif notification:GetName() == LoginNotes.CLOSE_TESTCODE_PANEL then
        if (self._testCodePanel ~= nil) then
            PanelManager.RecyclePanel(self._testCodePanel, ResID.UI_TESTCODEPANEL, true)
            self._testCodePanel = nil
        end
    elseif LoginNotes.CLOSE_AGREENMENTPANEL then
        if (self._agreeMentPanel) then
            Util.SetInt("korea_agreement", 1)
            PanelManager.RecyclePanel(self._agreeMentPanel, ResID.UI_AGREEMENTPANEL)
            self._agreeMentPanel = nil
            if GameConfig.PreloadAppSplit() and not AppSplitDownProxy.ForceLoad() then return end

        end

    end
end

function LoginMediator:OnRemove()

end 