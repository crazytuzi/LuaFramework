require "Core.Module.Common.Panel"

local ProductPackPanel = class("ProductPackPanel",Panel);
function ProductPackPanel:New()
	self = { };
	setmetatable(self, { __index =ProductPackPanel });
	return self
end


function ProductPackPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ProductPackPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtTitle = UIUtil.GetChildInComponents(txts, "txtTitle");
	self._txtBtn = UIUtil.GetChildInComponents(txts, "txtBtn");
	self._txtDes = UIUtil.GetChildInComponents(txts, "txtDes");
	self._btnOk = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOk");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._grid = UIUtil.GetChildByName(self._trsContent, "UIGrid", "content");
    self.maxAwardNum = 4
    for i = 1, self.maxAwardNum do
        local trs = UIUtil.GetChildByName(self._grid, "Transform", "Product" .. i)
        self["product" .. i] = trs
        local ctr = ProductCtrl:New()
        self["productCtr" .. i] = ctr
        ctr:Init(trs, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle })
        ctr:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end
end

function ProductPackPanel:_InitListener()
	self._onClickBtnOk = function(go) self:_OnClickBtnOk(self) end
	UIUtil.GetComponent(self._btnOk, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOk);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function ProductPackPanel:_OnClickBtnOk()
	if self.d and self.d.fun then self.d.fun(self.d) end
    self:_OnClickBtn_close()
end

function ProductPackPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(MallNotes.CLSOE_PRODUCT_PACK_PANEL)
end
--d:{ads道具信息={productInfo,,,},des文字说明,fun确定回调}
function ProductPackPanel:SetData(d)
	self.d = d
    local ads = d.ads
    for i = 1, self.maxAwardNum do
        local ad = ads[i]
        local ctr = self["productCtr" .. i]
        ctr:SetData(ad)
        ctr:SetActive(ad ~= nil)
    end
    self._txtDes.text = d.des
end

function ProductPackPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ProductPackPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnOk, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnOk = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function ProductPackPanel:_DisposeReference()
	self._btnOk = nil;
	self._btn_close = nil;
	self._txtTitle = nil;
	self._txtBtn = nil;
    for i = 1, self.maxAwardNum do
        self["product" .. i] = nil;
        self["productCtr" .. i]:Dispose()
        self["productCtr" .. i] = nil;
    end
end
return ProductPackPanel