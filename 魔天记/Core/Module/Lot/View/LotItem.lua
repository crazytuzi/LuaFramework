require "Core.Module.Common.Panel"

local LotItem = class("LotItem", UIComponent);
function LotItem:New(trs, t)
	self = { };
	setmetatable(self, { __index =LotItem });
    self._type = t
    if trs then self:Init(trs) end
	return self
end


function LotItem:_Init()
	self:_InitReference();
	self:_InitListener();
end

function LotItem:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
	self._txtExp = UIUtil.GetChildInComponents(txts, "txtExp");
	self._txtCost = UIUtil.GetChildInComponents(txts, "txtCost");
	self._txtNum = UIUtil.GetChildInComponents(txts, "txtNum");
	self._btnBuy = UIUtil.GetChildByName(self._transform, "UIButton", "btnBuy");
	local imgs = UIUtil.GetComponentsInChildren(self._transform, "UISprite");
	self._imgMsg = UIUtil.GetChildInComponents(imgs, "imgMsg");
    self.trsQiuyuan = UIUtil.GetChildByName(self._transform, "Transform", "trsQiuyuan").gameObject;
end

function LotItem:_InitListener()
	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
	MessageManager.AddListener(LotNotes, LotNotes.CHANGE_LOT_INFO, LotItem._GetLotInfo, self)
	MessageManager.AddListener(LotNotes, LotNotes.CHANGE_LOT_CHANGE, LotItem._ChangeLot, self)
end

function LotItem:_OnClickBtnBuy()
	LotProxy.TryBuy(self._type)
    self._buyed = true
end
function LotItem:_GetLotInfo(t)
    self:_ChangeLotInfoing(t, false)
end
function LotItem:_ChangeLot(t)
    self:_ChangeLotInfoing(t, true)
end
function LotItem:_ChangeLotInfoing(tp, change)
    local t = self._type
    if t ~= tp then return end
    local exp = LotProxy.GetSelfExp(t)
    local lt = LotProxy.GetSelfCost(t)
	self._txtExp.text = exp
	self._txtCost.text = lt == 0 and LanguageMgr.Get("Lottery/LotteryPanel/buyFree") or lt
	self._txtNum.text = LotProxy.GetSelfLimitNum(t)
    self._imgMsg.enabled = LotProxy.HasMsg(t) and not self._buyed
    if change then
        self.trsQiuyuan:SetActive(false)
        self.trsQiuyuan:SetActive(true)
    end
end

function LotItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function LotItem:_DisposeListener()
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnBuy = nil;
	MessageManager.RemoveListener(LotNotes, LotNotes.CHANGE_LOT_INFO, LotItem._GetLotInfo)
	MessageManager.RemoveListener(LotNotes, LotNotes.CHANGE_LOT_CHANGE, LotItem._ChangeLot)
end

function LotItem:_DisposeReference()
	self._btnClose = nil;
	self._btnBuy = nil;
	self._txtExp = nil;
	self._txtCost = nil;
	self._txtNum = nil;
    self._imgMsg = nil;
end
return LotItem