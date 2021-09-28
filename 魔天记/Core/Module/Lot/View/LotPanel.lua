require "Core.Module.Common.Panel"

local LotPanel = class("LotPanel",Panel);
function LotPanel:New()
	self = { };
	setmetatable(self, { __index =LotPanel });
	return self
end


function LotPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    LotProxy.GetLotInfo()
end

function LotPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._coinBar = UIUtil.GetChildByName(self._trsContent, "CoinBar");
    self._coinBarCtrl = CoinBar:New(self._coinBar);
    local LotItem = require "Core.Module.Lot.View.LotItem"
	self._trs1 = UIUtil.GetChildByName(self._trsContent, "Transform", "trs1");
    self._item1 = LotItem:New(self._trs1, 1)
	self._trs2 = UIUtil.GetChildByName(self._trsContent, "Transform", "trs2");
    self._item2 = LotItem:New(self._trs2, 2)
end

function LotPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function LotPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(LotNotes.CLOSE_LOT_PANEL)
    LotProxy.SetMsg()
end

function LotPanel:_Dispose()
    self._coinBarCtrl:Dispose();
    self._coinBar = nil;
    self._coinBarCtrl = nil;
	self:_DisposeListener();
	self:_DisposeReference();
end

function LotPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
end

function LotPanel:_DisposeReference()
    self._item1:Dispose()
    self._item1 = nil
    self._item2:Dispose()
    self._item2 = nil
end
return LotPanel