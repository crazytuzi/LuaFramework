require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.NumInput.NumInputNotes"
require "Core.Module.NumInput.View.NumInputPanel"

NumInputMediator = Mediator:New();
function NumInputMediator:OnRegister()

end

function NumInputMediator:_ListNotificationInterests()
  return {
        [1] = NumInputNotes.OPEN_NUMINPUT,
        [2] = NumInputNotes.CLOSE_NUMINPUT,
    };
end

function NumInputMediator:_HandleNotification(notification)
  
   if notification:GetName() == NumInputNotes.OPEN_NUMINPUT then

        local data = notification:GetBody();
        if (self._numInputPanel == nil) then
            self._numInputPanel = PanelManager.BuildPanel("UI_NumInputPanel", NumInputPanel);
        end
       self._numInputPanel:SetData(data);

    elseif notification:GetName() == NumInputNotes.CLOSE_NUMINPUT then
        if (self._numInputPanel ~= nil) then
            PanelManager.RecyclePanel(self._numInputPanel)
            self._numInputPanel = nil
        end

    end

end

function NumInputMediator:OnRemove()

end

