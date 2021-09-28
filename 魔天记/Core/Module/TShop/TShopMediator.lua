require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.TShop.TShopNotes"
require "Core.Module.TShop.View.TShopPanel"

TShopMediator = Mediator:New();
function TShopMediator:OnRegister()

end

function TShopMediator:_ListNotificationInterests()
    return {
        [1] = TShopNotes.OPEN_TSHOP,
        [2] = TShopNotes.CLOSE_TSHOP,
    };
end

function TShopMediator:_HandleNotification(notification)

    if notification:GetName() == TShopNotes.OPEN_TSHOP then

        local data = notification:GetBody();
        if (self._tshopPanel == nil) then
            self._tshopPanel = PanelManager.BuildPanel(ResID.UI_TSHOPPANEL, TShopPanel);
        end
        
        self._tshopPanel:SetData(data);

    elseif notification:GetName() == TShopNotes.CLOSE_TSHOP then
        if (self._tshopPanel ~= nil) then
            PanelManager.RecyclePanel(self._tshopPanel)
            self._tshopPanel = nil
        end

    end

end

function TShopMediator:OnRemove()

end

