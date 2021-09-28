require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.AddFriends.AddFriendsNotes"
require "Core.Module.AddFriends.View.AddFriendsPanel"

AddFriendsMediator = Mediator:New();
function AddFriendsMediator:OnRegister()

end

function AddFriendsMediator:_ListNotificationInterests()
 return {
        [1] = AddFriendsNotes.OPEN_ADDFRIENDSPANEL,
        [2] = AddFriendsNotes.CLOSE_ADDFRIENDSPANEL,
      
    };
end

function AddFriendsMediator:_HandleNotification(notification)
 if notification:GetName() == AddFriendsNotes.OPEN_ADDFRIENDSPANEL then
        if (self._addFriendsPanel == nil) then
            self._addFriendsPanel = PanelManager.BuildPanel(ResID.UI_ADDFRIENDSPANEL, AddFriendsPanel);
        end
         self._addFriendsPanel:Show();

    elseif notification:GetName() == AddFriendsNotes.CLOSE_ADDFRIENDSPANEL then
        if (self._addFriendsPanel ~= nil) then
            PanelManager.RecyclePanel(self._addFriendsPanel)
            self._addFriendsPanel = nil
        end
 
    end
end

function AddFriendsMediator:OnRemove()

end

