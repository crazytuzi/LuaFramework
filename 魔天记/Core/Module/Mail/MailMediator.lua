require "Core.Module.Pattern.Mediator";
require "Core.Module.Common.ResID";
require "Core.Module.Mail.MailNotes";
require "Core.Module.Friend.FriendNotes";

MailMediator = Mediator:New();
function MailMediator:OnRegister()

end

function MailMediator:_ListNotificationInterests()
    return {
        --[1] = MailNotes.OPEN_MAILPANEL,
    };
end

function MailMediator:_HandleNotification(notification)
    --[[if notification:GetName() == MailNotes.OPEN_MAILPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_MAILPANEL, MailPanel);            
        end
    elseif notification:GetName() == MailNotes.CLOSE_MAILPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil;
        end
    end]]
end

function MailMediator:OnRemove()

end

