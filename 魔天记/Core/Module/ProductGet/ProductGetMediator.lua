require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ProductGet.ProductGetNotes"
require "Core.Module.ProductGet.View.ProductGetPanel"

local ProductGetMediator = Mediator:New();
function ProductGetMediator:OnRegister()
	
end

local notification = {
	ProductGetNotes.SHOW_EQUIP_GET_PANEL,
	ProductGetNotes.CLOSE_EQUIP_GET_PANEL,
};

function ProductGetMediator:_ListNotificationInterests()
	return notification
end

--[[    显示道具获取面板, id 道具id(number), msg 关闭来源模块的消息号,用于关闭来源模块
        ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
            {id = 310013, msg= ChatNotes.CLOSE_CHAT_SET_PANEL })
]]
function ProductGetMediator:_HandleNotification(notification)
	local t = notification:GetName()
	if t == ProductGetNotes.SHOW_EQUIP_GET_PANEL then
		 
		if self._panel then return end
		local body = notification:GetBody()
		local id = body.id
		local getInfo = ProductGetProxy.GetItemInfo(id)
		local updateNote = body.updateNote
		
		if not getInfo then
			return
		end
		if(self._panel == nil) then
			self._panel = PanelManager.BuildPanel(ResID.UI_PRODUCT_GET_PANEL, ProductGetPanel)
		end
		
		local proInfo = ProductManager.GetProductInfoById(id)
		self._panel:SetData(proInfo, getInfo, updateNote)
	elseif t == ProductGetNotes.CLOSE_EQUIP_GET_PANEL then
		if(self._panel ~= nil) then
			PanelManager.RecyclePanel(self._panel)
			self._panel = nil
		end
		
		
	end
end

function ProductGetMediator:OnRemove()
	
end

return ProductGetMediator