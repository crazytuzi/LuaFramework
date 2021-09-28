require "Core.Module.Common.Panel"
require "Core.Module.Common.CoinBar"
require "Core.Module.Sale.View.Item.SubSaleBuyPanel"
require "Core.Module.Sale.View.Item.SubSaleSellPanel"


SalePanel = class("SalePanel", Panel);
function SalePanel:New()
	self = {};
	setmetatable(self, {__index = SalePanel});
	return self
end


function SalePanel:_Init()	
	self:_InitReference();
	self:_InitListener();
	self._panenIndex = 1
	self._coinBar = CoinBar:New(self._trsCoinBar)
	self._panels = {}
	self._panels[1] = SubSaleBuyPanel:New(self._trsBuy)
	self._panels[2] = SubSaleSellPanel:New(self._trsSell)
	self._toggles = {self._toggleBuy, self._toggleSell, self._toggleAuction}
end

function SalePanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	
	self._txtXianyu = UIUtil.GetChildInComponents(txts, "txtXianyu");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._btnBuy = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnBuy");
	self._btnSell = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSell");
	self._btnAuction = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAuction");
	self._toggleBuy = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnBuy")
	self._toggleSell = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnSell")
	self._toggleAuction = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnAuction")
	self._goTip = UIUtil.GetChildByName(self._trsContent, "btnSell/tip").gameObject
	self._trsBuy = UIUtil.GetChildByName(self._trsContent, "Transform", "trsBuy");
	self._trsSell = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSell");
	self._trsAuction = UIUtil.GetChildByName(self._trsContent, "Transform", "trsAuction");
	self._trsCoinBar = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCoinBar");
end

function SalePanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
	self._onClickBtnSell = function(go) self:_OnClickBtnSell(self) end
	UIUtil.GetComponent(self._btnSell, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSell);
	self._onClickBtnAuction = function(go) self:_OnClickBtnAuction(self) end
	UIUtil.GetComponent(self._btnAuction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAuction);
end

function SalePanel:_OnClickBtn_close()
	ModuleManager.SendNotification(SaleNotes.CLOSE_SALEPANEL)
end

function SalePanel:_OnClickBtnBuy()
	self:ChangePanel(1)
end

function SalePanel:_OnClickBtnSell()
	self:ChangePanel(2)
end

function SalePanel:_OnClickBtnAuction()
	self:ChangePanel(3)
end

function SalePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	self._coinBar:Dispose();
	self._coinBar = nil
	for k, v in ipairs(self._panels) do
		v:Dispose()
	end
	self._panels = nil
end

function SalePanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnBuy = nil;
	UIUtil.GetComponent(self._btnSell, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSell = nil;
	UIUtil.GetComponent(self._btnAuction, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAuction = nil;
end

function SalePanel:_DisposeReference()
	self._btn_close = nil;
	self._btnBuy = nil;
	self._btnSell = nil;
	self._btnAuction = nil;
	self._trsBuy = nil
	self._trsSell = nil
	self._trsAuction = nil
	self._toggleBuy = nil
	self._toggleSell = nil
	self._toggleAuction = nil
	self._toggles = nil
end


function SalePanel:UpdatePanel()
	self._goTip:SetActive(SaleManager.GetRedPoint())
	if(self._panels[self._panenIndex]) then
		self._panels[self._panenIndex]:UpdatePanel()
	end
end

function SalePanel:ChangePanel(to)
	for i = 1, table.getCount(self._panels) do
		if i == to then
			self._panels[i]:SetEnable(true)
		else
			self._panels[i]:SetEnable(false)
		end
	end
	self._panenIndex = to
	if(self._toggles[self._panenIndex]) then
		self._toggles[self._panenIndex].value = true
	end
	self:UpdatePanel()
end

function SalePanel:ResetTable(index)
	self._panels[1]:ResetTable(index)
end

function SalePanel:UpdateSaleList()
	self._panels[1]:UpdateSaleList()
end

function SalePanel:ChangeSalePanel(to)
	self._panels[2]:UpdatePanel(to)
end

function SalePanel:UpdateSelectItem()
	self._panels[2]:UpdateSelectItem()
end

function SalePanel:UpdateRecentPrice(data)
	self._panels[2]:UpdateRecentPrice(data)
end

function SalePanel:UpdateSaleListCount()
	self._panels[2]:UpdateSaleListCount()
end

function SalePanel:UpdateTipState()
	self._goTip:SetActive(SaleManager.GetCanGetSaleMoney())
	self._panels[2]:UpdateTipState()
end

function SalePanel:ResetScrollview()
	self._panels[1]:ResetScrollview()
end 