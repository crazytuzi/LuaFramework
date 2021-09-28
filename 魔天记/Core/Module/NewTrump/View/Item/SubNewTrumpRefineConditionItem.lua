require "Core.Module.Common.UIItem"

SubNewTrumpRefineConditionItem = class("SubNewTrumpRefineConditionItem", UIItem);
function SubNewTrumpRefineConditionItem:New()
	self = {};
	setmetatable(self, {__index = SubNewTrumpRefineConditionItem});
	return self
end


function SubNewTrumpRefineConditionItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self._productInfo = ProductInfo:New()
	self:UpdateItem(self.data)
end

function SubNewTrumpRefineConditionItem:_InitReference()
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	self._txtCount = UIUtil.GetChildByName(self.transform, "UILabel", "count")
end

function SubNewTrumpRefineConditionItem:_InitListener()
	self._onClickItem = function(go) self:_OnClickItem(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function SubNewTrumpRefineConditionItem:_OnClickItem()
	if(self._productInfo) then		 
		ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,{id = self.data.itemId,updateNote = NewTrumpNotes.UPDATE_NEWTRUMPPANEL})
	end
end

function SubNewTrumpRefineConditionItem:_Dispose()
	self:_DisposeReference();
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function SubNewTrumpRefineConditionItem:_DisposeReference()
	self._imgIcon = nil
	self._imgQuality = nil
end

function SubNewTrumpRefineConditionItem:UpdateItem(data)
	self.data = data
	
	
	if(self.data) then
		local product = ProductManager.GetProductById(self.data.itemId)
		self._productInfo:Init({spId = self.data.itemId})
		if(product) then
			ProductManager.SetIconSprite(self._imgIcon, product.icon_id)
			self._imgQuality.color = ColorDataManager.GetColorByQuality(product.quality)
		end
		if(product.id == SpecialProductId.Money) then
			self._txtCount.text = self.data.itemCount
			if(MoneyDataManager.Get_money() >= self.data.itemCount) then
				self._txtCount.color = ColorDataManager.Get_green()
			else
				self._txtCount.color = ColorDataManager.Get_red()
				
			end
		else
			local num = BackpackDataManager.GetProductTotalNumBySpid(self.data.itemId)
			self._txtCount.text = num .. "/" .. self.data.itemCount
			if(product) then
				self._txtCount.color =(num >= self.data.itemCount) and ColorDataManager.Get_green() or ColorDataManager.Get_red()
			end
			
		end
	end
	
end 