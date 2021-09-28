require "Core.Module.Common.UIComponent"

local ImmortalShopRankItem = class("ImmortalShopRankItem",UIItem);
function ImmortalShopRankItem:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopRankItem });
	return self
end


function ImmortalShopRankItem:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateItem(self.data)
end

function ImmortalShopRankItem:_InitReference()
	self._txtRank = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtRank");
	self._txtNum = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtNum");
	self._imgRank = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgRank");
end

function ImmortalShopRankItem:_InitListener()
    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function ImmortalShopRankItem:_OnClick()
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_SELECT, self.data.idx)
end

function ImmortalShopRankItem:UpdateItem(data)
    if not data then return end
	self.data = data
    self._txtNum.text = data.v
    local r = data.idx
    self._imgRank.spriteName = ImmortalShopProxy.GetRankSpriteName(r)
    self._txtRank.text = r > 0 and r or '无'
end

function ImmortalShopRankItem:_Dispose()
    self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalShopRankItem:_DisposeListener()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
end


function ImmortalShopRankItem:_DisposeReference()
	self._txtRank = nil;
	self._txtNum = nil;
	self._imgRank = nil;
end
return ImmortalShopRankItem