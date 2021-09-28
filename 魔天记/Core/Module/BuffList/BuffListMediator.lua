require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.BuffList.BuffListNotes"
require "Core.Module.BuffList.View.BuffListPanel"

BuffListMediator = Mediator:New();
function BuffListMediator:OnRegister()

end

BuffListNotes.OPEN_BUFFLIST = "OPEN_BUFFLIST";
BuffListNotes.CLOSE_BUFFLIST = "CLOSE_BUFFLIST";

function BuffListMediator:_ListNotificationInterests()
    return {
        [1] = BuffListNotes.OPEN_BUFFLIST,
        [2] = BuffListNotes.CLOSE_BUFFLIST,
    };
end

function BuffListMediator:_HandleNotification(notification)
    if notification:GetName() == BuffListNotes.OPEN_BUFFLIST then
        local body = notification:GetBody()
        if (body) then
            if (self._panel == nil) then
                self._panel = PanelManager.BuildPanel(ResID.UI_BUFFLISTPANEL, BuffListPanel);
            end
            self._panel:SetData(body);
        end
    elseif notification:GetName() == BuffListNotes.CLOSE_BUFFLIST then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_BUFFLISTPANEL)
            self._panel = nil
        end
    end
end

function BuffListMediator:OnRemove()

end