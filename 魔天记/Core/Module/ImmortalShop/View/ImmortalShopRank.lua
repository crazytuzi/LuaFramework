require "Core.Module.Common.UIComponent"

local ImmortalShopRank = class("ImmortalShopRank",UIComponent);
local ImmortalShopRankItem = require "Core.Module.ImmortalShop.View.Item.ImmortalShopRankItem"

function ImmortalShopRank:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopRank });
	return self
end
function ImmortalShopRank:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ImmortalShopRank:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtFrist = UIUtil.GetChildInComponents(txts, "txtFrist");
    self.maxAwardNum = 7;
    for i = 1, self.maxAwardNum do
        self["product" .. i] = UIUtil.GetChildByName(self._gameObject, "Transform", "awards/product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end
	self._txtMinCost = UIUtil.GetChildInComponents(txts, "txtMinCost");
	self._texRank1 = UIUtil.GetChildByName(self._gameObject, "UITexture", "texRank1");
	self._texRank2 = UIUtil.GetChildByName(self._gameObject, "UITexture", "texRank2");
	self._texRank3 = UIUtil.GetChildByName(self._gameObject, "UITexture", "texRank3");
	self._trsMyItem = UIUtil.GetChildByName(self._gameObject, "Transform", "trsMyItem");
    self.myItem = ImmortalShopRankItem:New()
    self.myItem:Init(self._trsMyItem)
	self._trsList = UIUtil.GetChildByName(self._gameObject, "Transform", "trsList");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, ImmortalShopRankItem, true)
end

function ImmortalShopRank:SetActive(active)
    if (self._gameObject and self._isActive ~= active) then
        self._gameObject:SetActive(active);
        self._isActive = active;
    end
    if active then ImmortalShopProxy.SendImmortalShopRank() end
end

function ImmortalShopRank:_InitListener()
    MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_INFO, ImmortalShopRank._OnGetRankInfo, self)
    MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_SELECT, ImmortalShopRank._OnSelect, self)
end

function ImmortalShopRank:_OnGetRankInfo(d)
    PrintTable(d, '----' , Warning)
    if not d then return end
    self._txtFrist.text = d.f
    self._txtMinCost.text = ImmortalShopProxy.GetRankMinConsume()
    self.myItem:UpdateItem(d)
    local rs = d.l
	self._phalanx:Build(#rs, 1, rs)
    if #rs > 0 then self:_OnSelect(1) end
end
function ImmortalShopRank:_OnSelect(r)
    for i = 1, 3 do self['_texRank' .. i].gameObject:SetActive(i == r) end
    local awards = ImmortalShopProxy.GetRankAward(r)
    for i = 1, self.maxAwardNum do
        self["productCtr" .. i]:SetData(awards[i]);
    end
end

function ImmortalShopRank:_Dispose()
	self:_DisposeReference()
    MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_INFO, ImmortalShopRank._OnGetRankInfo)
    MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_SELECT, ImmortalShopRank._OnSelect)
end

function ImmortalShopRank:_DisposeReference()
	self._txtFrist = nil;
	self._txtMinCost = nil;
	self._phalanx:Dispose()
	self._phalanx = nil
    for i = 1, self.maxAwardNum do
        self["product" .. i] = nil;
        self["productCtr" .. i]:Dispose()
        self["productCtr" .. i] = nil;
    end
end
return ImmortalShopRank