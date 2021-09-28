require "Core.Module.Common.UIComponent"
require "Core.Module.Sale.View.Item.SubSaleMySellPanel"
require "Core.Module.Sale.View.Item.SubSaleMyGroundingPanel"


SubSaleSellPanel = class("SubSaleSellPanel", UIComponent);
function SubSaleSellPanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubSaleSellPanel});
	if(trs) then
		self:Init(trs)
	end
	return self
end


function SubSaleSellPanel:_Init()
	SaleProxy.SendGetMySaleData()
	self:_InitReference();
	self:_InitListener();
	self._panelIndex = 1
	self._panels = {}
	self._panels[1] = SubSaleMySellPanel:New(self._trsMySell)
	self._panels[2] = SubSaleMyGroundingPanel:New(self._trsMyGrounding)
end

function SubSaleSellPanel:_InitReference()
	self._trsMySell = UIUtil.GetChildByName(self._gameObject, "Transform", "trsMySell");
	self._trsMyGrounding = UIUtil.GetChildByName(self._gameObject, "Transform", "trsMyGrounding");
end

function SubSaleSellPanel:_InitListener()
	
end

function SubSaleSellPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	for k, v in ipairs(self._panels) do
		v:Dispose()
	end
	self._panels = nil
end

function SubSaleSellPanel:_DisposeListener()
	
end

function SubSaleSellPanel:_DisposeReference()
	self._trsMySell = nil;
	self._trsMyGrounding = nil;
end

function SubSaleSellPanel:UpdatePanel(to)
	if(to) then
		self._panelIndex = to
	end
	
	for i = 1, table.getCount(self._panels) do
		if i == self._panelIndex then
			self._panels[i]:SetEnable(true)
		else
			self._panels[i]:SetEnable(false)
		end
	end
	
	if(self._panels[self._panelIndex]) then
		self._panels[self._panelIndex]:UpdatePanel()
	end
end

function SubSaleSellPanel:UpdateSelectItem()
	self._panels[2]:UpdateSelectItem()
end

function SubSaleSellPanel:UpdateRecentPrice(data)
	self._panels[2]:UpdateRecentPrice(data)
end

function SubSaleSellPanel:UpdateSaleListCount()
	self._panels[2]:UpdateMySellListCount()
end

function SubSaleSellPanel:UpdateTipState()
	self._panels[1]:UpdateTipState()
end