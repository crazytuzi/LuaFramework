require "Core.Module.Common.UIComponent"

local StarSubExChange = class("StarSubExChange",UIComponent);
function StarSubExChange:New(trs)
	self = { };
	setmetatable(self, { __index =StarSubExChange });
    if trs then self:Init(trs) end
	return self
end


function StarSubExChange:_Init()
	self:_InitReference();
	self:_InitListener();
end

function StarSubExChange:_InitReference()
	self._txtDebris = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtDebris");
    self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollView/phalanx");
	self._phalanx = Phalanx:New();
    local Item = require "Core.Module.Star.View.StarExChangeItem"
	self._phalanx:Init(self._phalanxInfo, Item)
end

function StarSubExChange:_InitListener()
    MessageManager.AddListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubExChange.UpdatePanel, self);
end

function StarSubExChange:UpdatePanel()
	self._txtDebris.text = StarManager.GetDebris()
    local d = ShopDataManager.GetProductsByShopType(TShopNotes.Shop_type_star)
	self._phalanx:Build(100, 2, d)
end

function StarSubExChange:_Dispose()
	self:_DisposeReference();
    self._phalanx:Dispose()
	self._phalanx = nil
end

function StarSubExChange:_DisposeReference()
    MessageManager.RemoveListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubExChange.UpdatePanel, self);
	self._txtDebris = nil;
end
return StarSubExChange