require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ActivityGifts.ActivityGiftsNotes"

require "Core.Module.ActivityGifts.View.ActivityGiftsPanel"

ActivityGiftsMediator = Mediator:New();
function ActivityGiftsMediator:OnRegister()

end

function ActivityGiftsMediator:_ListNotificationInterests()
    return {
        ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,
        ActivityGiftsNotes.CLOSE_ACTIVITYGIFTSPANEL,
        ActivityGiftsNotes.UPDATE_ACTIVITYGIFTSPANEL
    };
end

function ActivityGiftsMediator:_HandleNotification(notification)

    if notification:GetName() == ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_ACTIVITYGIFTSPANEL, ActivityGiftsPanel);
        end
        local data = notification:GetBody();
        
        if data ~= nil then
         self._panel:SetData(data)
        end 
       

    elseif notification:GetName() == ActivityGiftsNotes.CLOSE_ACTIVITYGIFTSPANEL then

        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel)
            self._panel = nil
        end
    elseif notification:GetName() == ActivityGiftsNotes.UPDATE_ACTIVITYGIFTSPANEL then
        if (self._panel ~= nil) then
            self._panel:UpdatePanel()
        end
    end


end

function ActivityGiftsMediator:OnRemove()

end

