require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.LingYao.LingYaoNotes"
require "Core.Module.LingYao.View.LingYaoPanel"

LingYaoMediator = Mediator:New();
function LingYaoMediator:OnRegister()

end

function LingYaoMediator:_ListNotificationInterests()
    return {
        [1] = LingYaoNotes.OPEN_LINGYAOPANEL,
        [2] = LingYaoNotes.CLOSE_LINGYAOPANEL,

    };
end

function LingYaoMediator:_HandleNotification(notification)

    if notification:GetName() == LingYaoNotes.OPEN_LINGYAOPANEL then
        if (self._lingYaoPanel == nil) then
            self._lingYaoPanel = PanelManager.BuildPanel(ResID.UI_LINGYAOPANEL, LingYaoPanel, true);
        end

        local data = notification:GetBody();

        if data ~= nil and data.selectIndex ~= nil then
            self._lingYaoPanel:SetSelect(data.selectIndex);
        end


    elseif notification:GetName() == LingYaoNotes.CLOSE_LINGYAOPANEL then

        if (self._lingYaoPanel ~= nil) then
            PanelManager.RecyclePanel(self._lingYaoPanel, ResID.UI_LINGYAOPANEL)
            self._lingYaoPanel = nil
        end


    end


end

function LingYaoMediator:OnRemove()

end

