require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.CashGift.CashGiftNotes"
local CashGiftsPanel = require "Core.Module.CashGift.View.CashGiftsPanel"

local CashGiftMediator = Mediator:New();
local notes = {
	CashGiftNotes.OPEN_CASHGIFTSPANEL,
	CashGiftNotes.CLOSE_CASHGIFTSPANEL,
	CashGiftNotes.UPDATE_CASHGIFTSPANEL,
}
function CashGiftMediator:OnRegister()
	
end

function CashGiftMediator:_ListNotificationInterests()
	return notes
end

function CashGiftMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if(notificationName == CashGiftNotes.OPEN_CASHGIFTSPANEL) then
		if(self._cashGiftsPanel == nil) then
			self._cashGiftsPanel = PanelManager.BuildPanel(ResID.UI_CASHGIFTSPANEL, CashGiftsPanel, false);			
		end
	elseif notificationName == CashGiftNotes.CLOSE_CASHGIFTSPANEL then
		if(self._cashGiftsPanel) then
			PanelManager.RecyclePanel(self._cashGiftsPanel, ResID.UI_CASHGIFTSPANEL)
			self._cashGiftsPanel = nil;		 
		end
	elseif notificationName == CashGiftNotes.UPDATE_CASHGIFTSPANEL then
		if(self._cashGiftsPanel) then
			self._cashGiftsPanel:UpdatePanel()	
		end
	end
end

function CashGiftMediator:OnRemove()
	
end

return CashGiftMediator 