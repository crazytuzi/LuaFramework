require "Core.Module.Common.UIComponent"

local ImmortalShopBuyItem = class("ImmortalShopBuyItem", UIItem);
function ImmortalShopBuyItem:New()
    self = { };
    setmetatable(self, { __index = ImmortalShopBuyItem });
    return self
end


function ImmortalShopBuyItem:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data);
end

function ImmortalShopBuyItem:_InitReference()
    self._txtlimit = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtlimit");
    self._txtDiscount = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtDiscount");
    self._txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtName");
    self._txtPrice = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtPrice");
    self["product"] = UIUtil.GetChildByName(self.gameObject, "Transform", "product");
    self["productCtr"] = ProductCtrl:New();
    self["productCtr"]:Init(self["product"], { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self["productCtr"]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    self._btnBuy = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnBuy");
end

function ImmortalShopBuyItem:_InitListener()
    self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
    UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
end

function ImmortalShopBuyItem:_OnClickBtnBuy()
    ImmortalShopProxy.SendImmortalShopBuy(self.id, self.cost, self.name)
end

function ImmortalShopBuyItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        local c = ImmortalShopProxy.GetProductConfig(self.data.id)
        local pi = ProductInfo:New()
        pi:Init( { spId = c.item_id, am = self.data.t })
        self._txtDiscount.text = c.discount
        self._txtName.text = pi:GetName()
        self._txtPrice.text = c.price
        self._txtlimit.text = c.one_buynum - self.data.n
        self["productCtr"]:SetData(pi)
        self.id = self.data.id
        self.cost = c.price
        self.name = pi:GetName()
    end
end

function ImmortalShopBuyItem:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ImmortalShopBuyItem:_DisposeListener()
    UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnBuy = nil;
end

function ImmortalShopBuyItem:_DisposeReference()
    self._btnBuy = nil;
    self._txtNum = nil;
    self._txtDiscount = nil;
    self._txtName = nil;
    self._txtPrice = nil;
    if self["productCtr"] then
        self["product"] = nil
        self["productCtr"]:Dispose()
        self["productCtr"] = nil
    end
end
return ImmortalShopBuyItem