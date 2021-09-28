require "Core.Module.Common.UIComponent"
require "Core.Module.Sale.View.Item.SubSaleItem"
require "Core.Module.Sale.View.Item.SubSaleList"


SubSaleBuyPanel = class("SubSaleBuyPanel", UIComponent);
local _sortfunc = table.sort

function SubSaleBuyPanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubSaleBuyPanel});
	if(trs) then
		self:Init(trs)
	end
	return self
end


function SubSaleBuyPanel:_Init()
	self._isInit = false
	self._isDown = false
	self:_InitReference();
	self:_InitListener();
	self:_SetIconRotate()
end

function SubSaleBuyPanel:UpdatePanel()
	if(not self._isInit) then
		self._isInit = true
		local data = SaleManager.GetConfigData()
		self._clsList = {}
		for k, v in ipairs(data) do
			local itemGo = NGUITools.AddChild(self._trsTable.gameObject, self._goPrefab);
			itemGo.name = tostring(k)
			local item = SubSaleList:New()
			item:SetIndex(k)
			item:Init(itemGo.transform);
			item:UpdateItem(v)
			self._clsList[k] = item;
		end
		self._clsList[1]:_OnClickItem()
		self._goPrefab:SetActive(false)
	end
end


function SubSaleBuyPanel:_InitReference()
	self._trsTable = UIUtil.GetChildByName(self._transform, "clsView/Table")
	self._trsSort = UIUtil.GetChildByName(self._transform, "sort")
	self._uiTable = UIUtil.GetChildByName(self._transform, "UITable", "clsView/Table")
	self._scrollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollview")
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollview/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, SubSaleItem)
	self._goPrefab = UIUtil.GetChildByName(self._trsTable, "itemList").gameObject
end

function SubSaleBuyPanel:_InitListener()
	self._onClickSort = function(go) self:_OnClickSort() end
	UIUtil.GetComponent(self._trsSort, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSort);
end

function SubSaleBuyPanel:_OnClickSort()
	self._isDown = not self._isDown
	self:_SetIconRotate()
	self:_SortData()
	self._phalanx:Build(table.getCount(self.data), 1, self.data)
end

function SubSaleBuyPanel:_SetIconRotate()
	if(self._isDown) then
		self._trsSort.transform.localRotation = Quaternion.New(0, 0, 0);
	else
		self._trsSort.transform.localRotation = Quaternion.New(0, 0, 180);
	end
end

function SubSaleBuyPanel:_SortData()
	if(self.data and table.getCount(self.data) > 1) then
		if(self._isDown) then
			_sortfunc(self.data, SubSaleBuyPanel._SortFunDes)
		else
			_sortfunc(self.data, SubSaleBuyPanel._SortFunAsc)
		end
	end
end

-- 降序
function SubSaleBuyPanel._SortFunDes(a, b)
	local p =(a.configData.lev - b.configData.lev) * 100 + a.configData.quality - b.configData.quality
	return p < 0
	
end

-- 升序
function SubSaleBuyPanel._SortFunAsc(a, b)
	local p =(a.configData.lev - b.configData.lev) * 100 + a.configData.quality - b.configData.quality
	return p > 0
end

function SubSaleBuyPanel:_Dispose()
	self:_DisposeReference();
	self:_DisposeListener();
	if(self._clsList) then
		for k, v in ipairs(self._clsList) do
			v:Dispose()
		end
	end
	
	self._clsList = nil
	
	if(self._phalanx) then
		self._phalanx:Dispose()
		self._phalanx = nil
	end
end

function SubSaleBuyPanel:_DisposeReference()
	
end

function SubSaleBuyPanel:_DisposeListener()
	UIUtil.GetComponent(self._trsSort, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickSort = nil;
end

function SubSaleBuyPanel:ResetTable(data)
	if(data) then
		for k, v in ipairs(self._clsList) do
			if(k ~= data) then
				v:SetPhalanxActive(false)
			end
		end
	end
	
	self._uiTable:Reposition()
end

function SubSaleBuyPanel:UpdateSaleList()
	if(self._gameObject.activeSelf) then
		self.data = ConfigManager.Clone(SaleManager.GetCurSaleList())
		self:_SortData()
		self._phalanx:Build(table.getCount(self.data), 1, self.data)
	end
end

function SubSaleBuyPanel:ResetScrollview( )
    self._scrollview:ResetPosition()
    self._scrollview:UpdatePosition()
end