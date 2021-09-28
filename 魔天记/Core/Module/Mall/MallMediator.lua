require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Mall.MallNotes"
require "Core.Module.Mall.View.MallPanel"
require "Core.Module.MainUI.View.TitlePanel"

MallMediator = Mediator:New();
function MallMediator:OnRegister()
	
end
local notification = {
	MallNotes.OPEN_MALLPANEL,
	MallNotes.CLOSE_MALLPANEL,
	MallNotes.UPDATE_MALLPANEL,
	MallNotes.UPDATE_MALLITEMINFO,
	MallNotes.RESETSCROLLVIEW,
	MallNotes.SHOW_MONEY_GET_PANEL,
	MallNotes.SHOW_BGOLD_GET_PANEL,
	MallNotes.SHOW_PRODUCT_PACK_PANEL,
	MallNotes.CLSOE_PRODUCT_PACK_PANEL
}

function MallMediator:_ListNotificationInterests()
	return notification
end

local moneyOpenInfo = {val = 1, other = MallManager.GetStoreById(1)}
local goldOpenInfo = {val = 1, other = MallManager.GetStoreById(102)}


function MallMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if(notificationName == MallNotes.OPEN_MALLPANEL) then
		local body = notification:GetBody()	
		
		if(body and body.val == 3) then		
			if(not SystemManager.IsOpen(SystemConst.Id.Charge)) then
				MsgUtils.ShowTips("MallMediator/ChargeClose")
				return
			end
		end
		
		if(self._mallPanel == nil) then
			self._mallPanel = PanelManager.BuildPanel(ResID.UI_MALLPANEL, MallPanel, true)
		end
		
		
		if body then
			self._mallPanel:ChangePanel(body.val, body.other, body.updateNote)			
		else
			self._mallPanel:ChangePanel(1)
		end
	elseif(notificationName == MallNotes.CLOSE_MALLPANEL) then
		if(self._mallPanel ~= nil) then
			if(self._mallPanel ~= nil) then
				PanelManager.RecyclePanel(self._mallPanel, ResID.UI_MALLPANEL)
				self._mallPanel = nil
			end
		end
	elseif(notificationName == MallNotes.UPDATE_MALLPANEL) then
		if(self._mallPanel ~= nil) then
			self._mallPanel:UpdatePanel()
		end
	elseif(notificationName == MallNotes.UPDATE_MALLITEMINFO) then
		if(self._mallPanel ~= nil) then
			self._mallPanel:UpdateSelectItemInfo()
		end
	elseif(notificationName == MallNotes.RESETSCROLLVIEW) then
		if(self._mallPanel ~= nil) then
			self._mallPanel:ResetsSrollview()
		end
	elseif(notificationName == MallNotes.SHOW_MONEY_GET_PANEL) then
		ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, moneyOpenInfo)
	elseif(notificationName == MallNotes.SHOW_BGOLD_GET_PANEL) then
		ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, goldOpenInfo)
	elseif(notificationName == MallNotes.SHOW_PRODUCT_PACK_PANEL) then
		if(self._buyPanel == nil) then
			local ProductPackPanel = require "Core.Module.Common.ProductPackPanel"
			self._buyPanel = PanelManager.BuildPanel(ResID.UI_PACK_PANEL, ProductPackPanel)
		end
		local body = notification:GetBody()--fun�ص�,ads����ProductInfo��
		self._buyPanel:SetData(body)
	elseif(notificationName == MallNotes.CLSOE_PRODUCT_PACK_PANEL) then
		if(self._buyPanel ~= nil) then
			PanelManager.RecyclePanel(self._buyPanel, ResID.UI_PACK_PANEL)
			self._buyPanel = nil
		end
	end
end

function MallMediator:OnRemove()
	
end

