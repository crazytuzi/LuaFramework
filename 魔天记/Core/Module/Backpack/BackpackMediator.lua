require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Backpack.BackpackNotes"
require "Core.Module.Backpack.View.BackpackPanel"


BackpackMediator = Mediator:New();
function BackpackMediator:OnRegister()

end

function BackpackMediator:_ListNotificationInterests()
    return {
        [1] = BackpackNotes.OPEN_BAG_ALL,
        [2] = BackpackNotes.CLOSE_BAG_ALL,
        [3] = BackpackNotes.PRODUCTITEM_INIT,
        [4] = BackpackNotes.OPEN_UNLOCKTIP,
    };
end

function BackpackMediator:_HandleNotification(notification)


    if notification:GetName() == BackpackNotes.OPEN_BAG_ALL then
        local plData = notification:GetBody();
        if (self._backBagPanel == nil) then
            self._backBagPanel = PanelManager.BuildPanel(ResID.UI_BACKPACKPANEL, BackpackPanel,true);
            self._backBagPanel:InitData();
        end
        self._backBagPanel:SetData(plData);

    elseif notification:GetName() == BackpackNotes.CLOSE_BAG_ALL then
        if (self._backBagPanel ~= nil) then
            PanelManager.RecyclePanel(self._backBagPanel,ResID.UI_BACKPACKPANEL)
            self._backBagPanel = nil
        end
    elseif notification:GetName() == BackpackNotes.PRODUCTITEM_INIT then
        if (self._backBagPanel ~= nil) then
            local plData = notification:GetBody();
            self._backBagPanel:AddProductItem(plData);
        end
    elseif notification:GetName() == BackpackNotes.OPEN_UNLOCKTIP then
      local idx = notification:GetBody();
        BackpackProxy.UnLockProudctBox(idx);
    end
end



function BackpackMediator:OnRemove()

end

