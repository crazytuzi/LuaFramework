require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.UIRequest.UIRequestNotes"
require "Core.Module.UIRequest.View.UIRequestPanel"

UIRequestMediator = Mediator:New();
function UIRequestMediator:OnRegister()

end

function UIRequestMediator:_ListNotificationInterests()
    return {
        [1] = UIRequestNotes.OPEN_REQUEST_PANEL,
        [2] = UIRequestNotes.CLOSE_REQUEST_PANEL,
    };
end

function UIRequestMediator:_HandleNotification(notification)
    --log("UIRequestMediator:_HandleNotification:" .. tostring(notification:GetName()));
    if notification:GetName() == UIRequestNotes.OPEN_REQUEST_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_REQUEST_PANEL, UIRequestPanel);
        end
    elseif notification:GetName() == UIRequestNotes.CLOSE_REQUEST_PANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    end
end

function UIRequestMediator:OnRemove()

end

