require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.SignIn.SignInNotes"
require "Core.Module.SignIn.View.SignInPanel"


SignInMediator = Mediator:New();
function SignInMediator:OnRegister()

end

function SignInMediator:_ListNotificationInterests()
    return
    {
        SignInNotes.OPEN_SIGNINPANEL,
        SignInNotes.CLOSE_SIGNINPANEL,
        SignInNotes.UPDATE_SIGNINPANEL,
        SignInNotes.CHANGE_SIGNINPANEL,
        SignInNotes.UPDATE_SIGNINPANELTIP,
    }
end

function SignInMediator:_HandleNotification(notification)
    if notification:GetName() == SignInNotes.OPEN_SIGNINPANEL then
        if (self._signInPanel == nil) then
            self._signInPanel = PanelManager.BuildPanel(ResID.UI_SIGNINPANEL, SignInPanel);
        end
    elseif notification:GetName() == SignInNotes.CLOSE_SIGNINPANEL then
        if (self._signInPanel ~= nil) then
            PanelManager.RecyclePanel(self._signInPanel, ResID.UI_SIGNINPANEL)
            self._signInPanel = nil
        end
    elseif notification:GetName() == SignInNotes.UPDATE_SIGNINPANEL then
        if (self._signInPanel ~= nil) then
            self._signInPanel:UpdatePanel()
        end
    elseif notification:GetName() == SignInNotes.CHANGE_SIGNINPANEL then
        if (self._signInPanel ~= nil) then
            self._signInPanel:ChangePanel(notification:GetBody())
        end
    elseif notification:GetName() == SignInNotes.UPDATE_SIGNINPANELTIP then
        if (self._signInPanel ~= nil) then
            self._signInPanel:UpdateTipState()
        end
        MessageManager.Dispatch(OnlineRewardManager, OnlineRewardManager.MESSAGE_ONLINEREWARD_STATE_CHANGE);
    end
end

function SignInMediator:OnRemove()

end

