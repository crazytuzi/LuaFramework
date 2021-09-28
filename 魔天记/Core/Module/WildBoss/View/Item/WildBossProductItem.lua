require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"

WildBossProductItem = class("WildBossProductItem", UIComponent);

function WildBossProductItem:New(transform)
	self = { };
	setmetatable(self, { __index = WildBossProductItem });
	if (transform) then
		self:Init(transform);
	end
	return self
end

function WildBossProductItem:SetProductId(id)
	self._info = ProductManager.GetProductInfoById(id)
	self:_Refresh();
end

function WildBossProductItem:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WildBossProductItem:AddClickListener(owner, handler)
	self._owner = owner;
	self._handler = handler;
end


function WildBossProductItem:_InitReference()
	self._imgQuality = UIUtil.GetComponent(self._transform, "UISprite")
	self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
	self:_Refresh();
end

function WildBossProductItem:_Refresh()
	if (self._info) then
		-- self._imgIcon.spriteName = self._info.baseData.icon_id;
		--self._imgQuality.spriteName = "quality_rect" .. self._info.baseData.quality;
        self._imgQuality.color = ColorDataManager.GetColorByQuality(self._info.baseData.quality);
		ProductManager.SetIconSprite(self._imgIcon, self._info.baseData.icon_id)
		self._gameObject:SetActive(true)
	else
		self._gameObject:SetActive(false)
	end
end

function WildBossProductItem:_InitListener()
	self._onClickHandler = function(go) self:_OnClickHandler(self) end
	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);
end

function WildBossProductItem:_OnClickHandler()
	if (self._info) then
		-- ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self._info, type = ProductCtrl.TYPE_FROM_OTHER });		
		ProductCtrl.ShowProductTip(self._info.spId, ProductCtrl.TYPE_FROM_OTHER, 1);
	end
end
  
function WildBossProductItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossProductItem:_DisposeListener()
	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickHandler = nil
	self._owner = nil;
	self._handler = nil;
end

function WildBossProductItem:_DisposeReference()
    self._imgQuality = nil;
	self._imgIcon = nil;
end