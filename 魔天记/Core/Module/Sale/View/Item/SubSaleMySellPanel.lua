require "Core.Module.Common.UIComponent"
require "Core.Module.Sale.View.Item.SubMySaleItem"

SubSaleMySellPanel = class("SubSaleMySellPanel", UIComponent);
function SubSaleMySellPanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubSaleMySellPanel});
	if(trs) then
		self:Init(trs)
	end
	return self
end


function SubSaleMySellPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SubSaleMySellPanel:_InitReference()
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UIButton");
	self._btnGetXianYu = UIUtil.GetChildInComponents(btns, "btnGetXianYu");
	self._goTip = UIUtil.GetChildByName(self._btnGetXianYu, "tip").gameObject
	self._btnGrounding = UIUtil.GetChildInComponents(btns, "btnGrounding");
	self._txtGroundingCount = UIUtil.GetChildByName(self._gameObject, "UILabel", "groundingCount")
	self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollview/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, SubMySaleItem)
end

function SubSaleMySellPanel:_InitListener()
	self._onClickBtnGetXianYu = function(go) self:_OnClickBtnGetXianYu(self) end
	UIUtil.GetComponent(self._btnGetXianYu, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGetXianYu);
	self._onClickBtnGrounding = function(go) self:_OnClickBtnGrounding(self) end
	UIUtil.GetComponent(self._btnGrounding, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGrounding);
end

function SubSaleMySellPanel:_OnClickBtnGetXianYu()
	SaleProxy.SendGetSaleRecord()
end

function SubSaleMySellPanel:_OnClickBtnGrounding()
	ModuleManager.SendNotification(SaleNotes.CHANGE_SELLPANEL, 2)
end

function SubSaleMySellPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function SubSaleMySellPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnGetXianYu, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGetXianYu = nil;
	UIUtil.GetComponent(self._btnGrounding, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGrounding = nil;
end

function SubSaleMySellPanel:_DisposeReference()
	self._btnGetXianYu = nil;
	self._btnGrounding = nil;
end

function SubSaleMySellPanel:UpdatePanel()
	self:UpdateTipState()
	self._txtGroundingCount.text = SaleManager.GetMySaleCountText()
	local data = SaleManager.GetMySaleData()
	self._phalanx:Build(table.getCount(data), 1, data)
end

function SubSaleMySellPanel:UpdateTipState()
	self._goTip:SetActive(SaleManager.GetCanGetSaleMoney())
end