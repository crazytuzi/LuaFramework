require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Sale.SaleNotes"
require "Core.Module.Sale.View.SalePanel"
require "Core.Module.Sale.View.SaleBuyItemPanel"
require "Core.Module.Sale.View.SaleRecordPanel"

SaleMediator = Mediator:New();
function SaleMediator:OnRegister()
	
end
local notification = {
	SaleNotes.OPEN_SALEPANEL,
	SaleNotes.CLOSE_SALEPANEL,
	SaleNotes.UPDATE_SALEPANEL,
	SaleNotes.RESET_TABLE,
	SaleNotes.UPDATE_SALELIST,
	SaleNotes.OPEN_SALEBUYITEMPANEL,
	SaleNotes.CLOSE_SALEBUYITEMPANEL,
	SaleNotes.OPEN_GETXIANYUPANEL,
	SaleNotes.CLOSE_GETXIANYUPANEL,
	SaleNotes.UPDATE_GETXIANYUPANEL,
	SaleNotes.CHANGE_SELLPANEL,
	SaleNotes.UPDATE_SELECT_ITEM,
	SaleNotes.UPDATE_RECENTPRICE,
	SaleNotes.UPDATE_SALELISTCOUNT,
	SaleNotes.UPDATE_SALEPANEL_SALEMONEYSTATE,
	SaleNotes.UPDATE_SCROLLVIEW,
	
}
function SaleMediator:_ListNotificationInterests()
	return notification
end

function SaleMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if(notificationName == SaleNotes.OPEN_SALEPANEL) then
		if(self._salePanel == nil) then
			self._salePanel = PanelManager.BuildPanel(ResID.UI_SALEPANEL, SalePanel, true)
			local body = notification:GetBody()
			self._salePanel:ChangePanel(body or 1)
		end
	elseif(notificationName == SaleNotes.CLOSE_SALEPANEL) then
		if(self._salePanel ~= nil) then
			PanelManager.RecyclePanel(self._salePanel, ResID.UI_SALEPANEL)
			self._salePanel = nil
			MessageManager.Dispatch(SaleManager, SaleManager.SALEMONEYCHANGE)
		end
	elseif(notificationName == SaleNotes.UPDATE_SALEPANEL) then
		if(self._salePanel ~= nil) then
			self._salePanel:UpdatePanel()
		end
	elseif(notificationName == SaleNotes.RESET_TABLE) then
		if(self._salePanel ~= nil) then
			self._salePanel:ResetTable(notification:GetBody())
		end
	elseif(notificationName == SaleNotes.UPDATE_SALELIST) then
		if(self._salePanel ~= nil) then
			self._salePanel:UpdateSaleList()
		end
	elseif(notificationName == SaleNotes.OPEN_SALEBUYITEMPANEL) then
		if(self._saleBuyItemPanel == nil) then
			self._saleBuyItemPanel = PanelManager.BuildPanel(ResID.UI_SALEBUYITEMPANEL, SaleBuyItemPanel)
			self._saleBuyItemPanel:UpdatePanel(notification:GetBody())
		end
	elseif(notificationName == SaleNotes.CLOSE_SALEBUYITEMPANEL) then
		if(self._saleBuyItemPanel ~= nil) then
			PanelManager.RecyclePanel(self._saleBuyItemPanel, ResID.UI_SALEBUYITEMPANEL)
			self._saleBuyItemPanel = nil
		end
	elseif(notificationName == SaleNotes.CHANGE_SELLPANEL) then
		if(self._salePanel ~= nil) then
			self._salePanel:ChangeSalePanel(notification:GetBody())
		end
	elseif(notificationName == SaleNotes.OPEN_GETXIANYUPANEL) then
		if(self._saleRecordPanel == nil) then
			self._saleRecordPanel = PanelManager.BuildPanel(ResID.UI_SALERECORDPANEL, SaleRecordPanel)
			
		end
	elseif(notificationName == SaleNotes.CLOSE_GETXIANYUPANEL) then
		if(self._saleRecordPanel ~= nil) then
			PanelManager.RecyclePanel(self._saleRecordPanel, ResID.UI_SALERECORDPANEL)
			self._saleRecordPanel = nil
		end
	elseif(notificationName == SaleNotes.UPDATE_GETXIANYUPANEL) then
		if(self._saleRecordPanel ~= nil) then
			self._saleRecordPanel:UpdatePanel()
		end
	elseif(notificationName == SaleNotes.UPDATE_SELECT_ITEM) then
		if(self._salePanel ~= nil) then
			self._salePanel:UpdateSelectItem()
		end
	elseif(notificationName == SaleNotes.UPDATE_RECENTPRICE) then
		if(self._salePanel ~= nil) then
			self._salePanel:UpdateRecentPrice(notification:GetBody())
		end
	elseif(notificationName == SaleNotes.UPDATE_SALELISTCOUNT) then
		if(self._salePanel ~= nil) then
			self._salePanel:UpdateSaleListCount()
		end
	elseif(notificationName == SaleNotes.UPDATE_SALEPANEL_SALEMONEYSTATE) then
		if(self._salePanel ~= nil) then
			self._salePanel:UpdateTipState()
		end
	elseif notificationName == SaleNotes.UPDATE_SCROLLVIEW then
		if(self._salePanel ~= nil) then
			self._salePanel:ResetScrollview()
		end
	end
end

function SaleMediator:OnRemove()
	
end

