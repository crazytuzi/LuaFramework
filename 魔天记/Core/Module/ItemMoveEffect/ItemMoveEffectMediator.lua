require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ItemMoveEffect.ItemMoveEffectNotes"

local ItemMoveEffectPanel = require "Core.Module.ItemMoveEffect.View.ItemMoveEffectPanel"

local ItemMoveEffectMediator = Mediator:New();
local notes = {
    ItemMoveEffectNotes.OPEN_ITEMMOVEEFFECTPANEL,
    ItemMoveEffectNotes.CLOSE_ITEMMOVEEFFECTPANEL,
}

function ItemMoveEffectMediator:OnRegister()

end

function ItemMoveEffectMediator:_ListNotificationInterests()
    return notes
end

function ItemMoveEffectMediator:_HandleNotification(notification)
    local notificationName = notification:GetName();
     local data = notification:GetBody();

       if notificationName == ItemMoveEffectNotes.OPEN_ITEMMOVEEFFECTPANEL then

        if (self._panel == nil) then
        
            self._panel = PanelManager.BuildPanel(ResID.UI_ITEMMOVEEFFECTPANEL, ItemMoveEffectPanel, false);
        end
        self._panel:SetData(data);

    elseif notificationName == ItemMoveEffectNotes.CLOSE_ITEMMOVEEFFECTPANEL then

        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_ITEMMOVEEFFECTPANEL)
            self._panel = nil;
        end

    end

end

function ItemMoveEffectMediator:OnRemove()

end

return ItemMoveEffectMediator