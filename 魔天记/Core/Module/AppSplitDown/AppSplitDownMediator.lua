require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.AppSplitDown.AppSplitDownNotes"
require "Core.Module.AppSplitDown.View.UI_AppSplitPanel"

AppSplitDownMediator = Mediator:New();
function AppSplitDownMediator:OnRegister()
    
end

function AppSplitDownMediator:_ListNotificationInterests()
    return {
        AppSplitDownNotes.OPEN_APPSPLITDOWN,
        AppSplitDownNotes.CLOSE_APPSPLITDOWN ,
        AppSplitDownNotes.HIDE_APPSPLITDOWN ,
        AppSplitDownNotes.OPEN_APPSPLITDOWN2,
        AppSplitDownNotes.CLOSE_APPSPLITDOWN2,
        }
end

function AppSplitDownMediator:_HandleNotification(notification)
    local n = notification:GetName()
    if n == AppSplitDownNotes.OPEN_APPSPLITDOWN then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_APP_SPLIT, UI_AppSplitPanel, false);
        else
            self._panel:Show()
        end
    elseif n == AppSplitDownNotes.CLOSE_APPSPLITDOWN  then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    elseif n == AppSplitDownNotes.OPEN_APPSPLITDOWN2 then
        if (self._panel2 == nil) then
            local UI_AppSplitPanel2 = require "Core.Module.AppSplitDown.View.UI_AppSplitPanel2"
            self._panel2 = PanelManager.BuildPanel(ResID.UI_APP_SPLIT2, UI_AppSplitPanel2, false);
        else
            self._panel2:Show()
        end
    elseif n == AppSplitDownNotes.CLOSE_APPSPLITDOWN2  then
        if (self._panel2 ~= nil) then
            PanelManager.RecyclePanel(self._panel2)
            self._panel2 = nil
        end
    elseif n == AppSplitDownNotes.HIDE_APPSPLITDOWN  then
        if (self._panel ~= nil) then
            self._panel:Hide()
        end
    end
end

function AppSplitDownMediator:OnRemove()

end

