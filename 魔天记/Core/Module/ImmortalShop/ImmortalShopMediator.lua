require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ImmortalShop.ImmortalShopNotes"

local ImmortalShopMediator = Mediator:New();
local notes = {
    ImmortalShopNotes.OPEN_IMMORTAL_SHOP_PANEL 
    ,ImmortalShopNotes.CLOSE_IMMORTAL_SHOP_PANEL
}
function ImmortalShopMediator:OnRegister()

end

function ImmortalShopMediator:_ListNotificationInterests()
	return notes
end

function ImmortalShopMediator:_HandleNotification(notification)
	local n = notification:GetName()
    if n == ImmortalShopNotes.OPEN_IMMORTAL_SHOP_PANEL  then
        if (self._panel == nil) then
            local ImmortalShopPanel = require "Core.Module.ImmortalShop.View.ImmortalShopPanel"
            self._panel = PanelManager.BuildPanel(ResID.UI_IMMORTAL_SHOP_PANEL, ImmortalShopPanel, false);
            local d = notification:GetBody() -- 1 抢购,2排行, 3狂欢
            if d then self._panel:_ChangePanel(d) end
        end
    elseif n == ImmortalShopNotes.CLOSE_IMMORTAL_SHOP_PANEL then
        if self._panel ~= nil then
            PanelManager.RecyclePanel(self._panel, ResID.UI_IMMORTAL_SHOP_PANEL)
            self._panel = nil
        end
    end
end

function ImmortalShopMediator:OnRemove()

end

return ImmortalShopMediator