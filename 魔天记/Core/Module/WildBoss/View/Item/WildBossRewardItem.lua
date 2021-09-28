
require "Core.Module.Common.PropsItem"

WildBossRewardItem = class("WildBossRewardItem", PropsItem);

function WildBossRewardItem:Init(gameObject, data)
	self.gameObject = gameObject;
	self.transform = gameObject.transform;
	self.data = data;
	self:_Init();
end

function WildBossRewardItem:_Init()
	self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
	self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
	
	self._onClick = function(go) self:_OnClick(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
	
	self:_InitReference();
	self:UpdateItem(self.data);
end

function WildBossRewardItem:UpdateDisplay()
	if self.data ~= nil then		
		local quality = self.data.quality
		ProductManager.SetIconSprite(self._icon, self.data.icon_id);
		self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
	end
end

function WildBossRewardItem:_OnClick()
	if self.data then
		local productInfo = ProductInfo:New()
		productInfo:Init({spId = self.data.id, am = 1})
		ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, {info = productInfo, type = 3});
		SequenceManager.TriggerEvent(SequenceEventType.Guide.WILD_BOSS_ITEM_CLICK);
	end
end 