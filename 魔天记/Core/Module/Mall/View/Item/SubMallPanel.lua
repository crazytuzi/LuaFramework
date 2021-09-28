require "Core.Module.Common.UIComponent"
require "Core.Module.Mall.View.Item.SubMallTypeItem"
require "Core.Module.Mall.View.Item.SubMallListItem"
require "Core.Module.Common.CommonPageItem"

SubMallPanel = class("SubMallPanel", UIComponent);
function SubMallPanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubMallPanel});
	if(trs) then
		self:Init(trs)
	end
	return self
end


function SubMallPanel:_Init()
	self._isInit = false
	self:_InitReference();
	self:_InitListener();
	local data = MallManager.GetMallLabelConfig()
	self._typePhalanx:Build(1, table.getCount(data), data)
end

function SubMallPanel:_InitReference()
	self._typePhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "typePhalanx")
	self._typePhalanx = Phalanx:New()
	self._typePhalanx:Init(self._typePhalanxInfo, SubMallTypeItem)
	self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")
	self._itemPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/itemPhalanx")
	self._currentGo = nil
	self._itemPhalanx = Phalanx:New()
	self._itemPhalanx:Init(self._itemPhalanxInfo, SubMallListItem)
	
	self._centerOnChild = UIUtil.GetChildByName(self._transform, "UICenterOnChild", "scrollView/itemPhalanx")
	self._delegate = function(go) self:_OnCenterCallBack(go) end
	self._centerOnChild.onCenter = self._delegate
	self._pagePhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "pagePhalanx");
	self._pagePhalanx = Phalanx:New();
	self._pagePhalanx:Init(self._pagePhalanxInfo, CommonPageItem, true)
end

function SubMallPanel:_OnCenterCallBack(go)
	if(go) then
		if(self._currentGo == go) then
			return
		end
		
		self._currentGo = go
		
		local index = self._itemPhalanx:GetItemIndex(go)
		local item = self._pagePhalanx:GetItem(index)
		if(item) then
			item.itemLogic:SetToggle(true)
			self._itemPhalanx:GetItem(index).itemLogic:SetItemToggle(1, true)
		end
	end
end

function SubMallPanel:_InitListener()
	
end

function SubMallPanel:_Dispose()
	self:_DisposeReference();
end

function SubMallPanel:_DisposeReference()
	self._typePhalanx:Dispose()
	self._typePhalanx = nil
	
	self._itemPhalanx:Dispose()
	self._itemPhalanx = nil
	self._scrollView = nil
	
	if self._centerOnChild and self._centerOnChild.onCenter then
		self._centerOnChild.onCenter:Destroy();
	end
	self._delegate = nil
	self._pagePhalanx:Dispose()
	self._pagePhalanx = nil
	
	self._currentGo = nil
end

function SubMallPanel:UpdatePanel(other)	
	if(other) then	 
		self._other = other
		MallProxy.SetMallKind(self._other.kind)
	end
	
	local curKind = MallProxy.GetMallKind()
	local data = MallManager.GetItemDatas(1, curKind)
	if(data and table.getCount(data) > 0) then
		local tempdata = {}
		local index = 1
		local count = 1
		local itemIndex = 1
		local productIndex = 1
		for k, v in ipairs(data) do
			if(count > 8) then
				index = index + 1
				count = 1
			end
			
			if(tempdata[index] == nil) then
				tempdata[index] = {}
			end
			if(self._other and v.configData.id == self._other.product_id) then	
				itemIndex = index
				productIndex = count
			end
			tempdata[index] [count] = v
			count = count + 1
		end
		
		
		self._itemPhalanx:Build(1, table.getCount(tempdata), tempdata)
		self._pagePhalanx:BuildSpe(table.getCount(tempdata), {})
		local cur = MallManager.GetCurrentSelectItemInfo()
		if((not table.contains(data, cur)) or(cur == nil)) then	
			local item = self._itemPhalanx:GetItem(itemIndex)
			if(not self._isInit) then			 
				local typeItem = self._typePhalanx:GetItem(curKind)
				typeItem.itemLogic:SetToggleActive(true)
				self._isInit = true
			end
			if(item) then				 
				self._scrollView:MoveRelative(Vector3.left *(itemIndex - 1)*720)
				self._scrollView:UpdatePosition()
				self._currentGo = item.gameObject			
				item.itemLogic:SetItemToggle(productIndex, true)				
				self._pagePhalanx:GetItem(itemIndex).itemLogic:SetToggle(true)				
			end
		end
		self._other = nil
	else
		self._itemPhalanx:Build(0, 0, {})
		MallProxy.SendGetMallItem(1, curKind)
	end
end

function SubMallPanel:ResetScrollView()
	self._scrollView:ResetPosition()
end 