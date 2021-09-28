require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Compose.ComposeNotes"
require "Core.Module.Compose.View.ComposePanel"

ComposeMediator = Mediator:New();
function ComposeMediator:OnRegister()

end

function ComposeMediator:_ListNotificationInterests()
    return {
        [1] = ComposeNotes.OPEN_COMPOSE_PANEL,
        [2] = ComposeNotes.CLOSE_COMPOSE_PANEL,
    };
end

function ComposeMediator:_HandleNotification(notification)
    if notification:GetName() == ComposeNotes.OPEN_COMPOSE_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_COMPOSE, ComposePanel);
        end
        local param = notification:GetBody();
        self._panel:Update(param);
    elseif notification:GetName() == ComposeNotes.CLOSE_COMPOSE_PANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_COMPOSE);
            self._panel = nil;
        end
    end
end

function ComposeMediator:OnRemove()
    
end