require "Core.Module.Common.UIComponent"

local ImmortalShopRevelryItem = class("ImmortalShopRevelryItem", UIItem);
function ImmortalShopRevelryItem:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopRevelryItem });
	return self
end


function ImmortalShopRevelryItem:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateItem(self.data)
end

function ImmortalShopRevelryItem:_InitReference()
	self._txtDes = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtDes");
	self._txtPress = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtPress");
	self._btnGet = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnGet");
	self._txtGeted = UIUtil.GetChildByName(self.gameObject, "UILabel", "trsGeted");
 	self._slider = UIUtil.GetChildByName(self.gameObject, "UISlider", "slider_load");
    self.maxAwardNum = 3
    for i = 1, self.maxAwardNum do
        self["product" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end
end

function ImmortalShopRevelryItem:_InitListener()
	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
end

function ImmortalShopRevelryItem:_OnClickBtnBuy()
	ImmortalShopProxy.SendImmortalRevelryGet(self.id)
end

function ImmortalShopRevelryItem:UpdateItem(d)
    self.data = d
    local c = d.c
    self.id = c.id
    local p = d.p
    local np = c.need_point
    local ok = np <= p
    self._txtDes.text = ok and LanguageMgr.Get("immortalShop/revelryItemDes2")
        or LanguageMgr.Get("immortalShop/revelryItemDes",{n = np - p})
    self._btnGet.gameObject:SetActive(ok and not d.geted)
    self._txtGeted.gameObject:SetActive(d.geted)
    if p > np then p = np end
    self._slider.value = p / np
    self._txtPress.text = p .. '/' .. np
    local awards = ProductInfo.GetProductInfos(c.reward)
    for i = 1, self.maxAwardNum do
        self["productCtr" .. i]:SetData(awards[i]);
    end
end


function ImmortalShopRevelryItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalShopRevelryItem:_DisposeListener()
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnBuy = nil;
end

function ImmortalShopRevelryItem:_DisposeReference()
	self._btnGet = nil;
	self._txtDes = nil;
	self._txtPress = nil;
    for i = 1, self.maxAwardNum do
        self["product" .. i] = nil;
        self["productCtr" .. i]:Dispose()
        self["productCtr" .. i] = nil;
    end
end
return ImmortalShopRevelryItem