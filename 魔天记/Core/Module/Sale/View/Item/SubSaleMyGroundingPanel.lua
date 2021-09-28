require "Core.Module.Common.UIComponent"
require "Core.Module.Sale.View.Item.SubSaleBagListItem"

SubSaleMyGroundingPanel = class("SubSaleMyGroundingPanel", UIComponent);
local maxGroundingCount = 10
local insert = table.insert

function SubSaleMyGroundingPanel:New(trs)
	self = {};
	setmetatable(self, {__index = SubSaleMyGroundingPanel});
	if(trs) then
		self:Init(trs)
	end
	return self
end


function SubSaleMyGroundingPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self._sellCount = 1
	self._sellPrice = 0
	self._curType = 1;
	self._tt = 1
	self._isInit = false
end

function SubSaleMyGroundingPanel:_InitReference()
	self._currentGo = nil
	self._btnSellList = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnSellList");
	self._btnGrounding = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnGrounding");
	
	self._goAddPrice = UIUtil.GetChildByName(self._gameObject, "priceAdd").gameObject
	self._goReducePrice = UIUtil.GetChildByName(self._gameObject, "priceReduce").gameObject
	self._goSellNumAdd = UIUtil.GetChildByName(self._gameObject, "sellNumAdd").gameObject
	self._goSellNumReduce = UIUtil.GetChildByName(self._gameObject, "sellNumReduce").gameObject
	self._imgIcon = UIUtil.GetChildByName(self._gameObject, "UISprite", "icon")
	self._imgQuality = UIUtil.GetChildByName(self._gameObject, "UISprite", "quality")
	self._txtName = UIUtil.GetChildByName(self._gameObject, "UILabel", "name")
	self._txtLevel = UIUtil.GetChildByName(self._gameObject, "UILabel", "level")
	self._txtKind = UIUtil.GetChildByName(self._gameObject, "UILabel", "kind")
	
	self._txtNum = UIUtil.GetChildByName(self._gameObject, "UILabel", "num")
	self._txtRecentPrice = UIUtil.GetChildByName(self._gameObject, "UILabel", "recentPrice")
	self._txtSellPrice = UIUtil.GetChildByName(self._gameObject, "UILabel", "sellPrice")
	self._txtSellNum = UIUtil.GetChildByName(self._gameObject, "UILabel", "sellNum")
	self._txtSellTotalPrice = UIUtil.GetChildByName(self._gameObject, "UILabel", "sellTotalPrice")
	self._txtSellCommission = UIUtil.GetChildByName(self._gameObject, "UILabel", "sellCommission")
	
	self._goSellNumBg = UIUtil.GetChildByName(self._gameObject, "sellNumBg").gameObject
	self._scrollView = UIUtil.GetChildByName(self._gameObject, "UIScrollView", "scrollView")
	self._sellTime = {}
	for i = 1, 3 do
		self._sellTime[i] = {}
		self._sellTime[i].txt = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTime" .. i)
		self._sellTime[i].go = UIUtil.GetChildByName(self._gameObject, "time" .. i).gameObject
	end
	self._txtMySellListCount = UIUtil.GetChildByName(self._gameObject, "UILabel", "mySellListCount")
	
	self._btnclassify_all = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnclassify_all");
	self._btnclassify_eq = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnclassify_eq");
	self._btnclassify_mat = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnclassify_mat");
	self._btnclassify_st = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnclassify_st");
	self._btnclassify_sue = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnclassify_sue");
	
	self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollView/phalanxList")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, SubSaleBagListItem, true)
	
	self._centerOnChild = UIUtil.GetChildByName(self._transform, "UICenterOnChild", "scrollView/phalanxList")
	self._delegate = function(go) self:_OnCenterCallBack(go) end
	self._centerOnChild.onCenter = self._delegate
	
	self._pagePhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "pagePhalanx");
	self._pagePhalanx = Phalanx:New();
	self._pagePhalanx:Init(self._pagePhalanxInfo, CommonPageItem, true)
	
	self._goNotice = UIUtil.GetChildByName(self._transform, "notice").gameObject
	self._goNoticeParent = UIUtil.GetChildByName(self._transform, "noticeParent").gameObject
	self._goNoticeMask = UIUtil.GetChildByName(self._goNoticeParent, "mask").gameObject
	self._txtNotice = UIUtil.GetChildByName(self._goNoticeParent, "UILabel", "Label")
	self._isShowNotice = false
	self._goNoticeParent:SetActive(self._isShowNotice)
end

function SubSaleMyGroundingPanel:_InitListener()
	self._onClickBtnSellList = function(go) self:_OnClickBtnSellList(self) end
	UIUtil.GetComponent(self._btnSellList, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSellList);
	self._onClickBtnGrounding = function(go) self:_OnClickBtnGrounding(self) end
	UIUtil.GetComponent(self._btnGrounding, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGrounding);
	self._onClickAddPrice = function(go) self:_OnClickAddPrice(self) end
	UIUtil.GetComponent(self._goAddPrice, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAddPrice);
	self._onClickReducePrice = function(go) self:_OnClickReducePrice(self) end
	UIUtil.GetComponent(self._goReducePrice, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickReducePrice);
	self._onClickAddNum = function(go) self:_OnClickAddNum(self) end
	UIUtil.GetComponent(self._goSellNumAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAddNum);
	self._onClickReduceNum = function(go) self:_OnClickReduceNum(self) end
	UIUtil.GetComponent(self._goSellNumReduce, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickReduceNum);
	self._onClickBtnclassify_all = function(go) self:_OnClickBtnclassify_all(self) end
	UIUtil.GetComponent(self._btnclassify_all, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnclassify_all);
	self._onClickBtnclassify_eq = function(go) self:_OnClickBtnclassify_eq(self) end
	UIUtil.GetComponent(self._btnclassify_eq, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnclassify_eq);
	self._onClickBtnclassify_mat = function(go) self:_OnClickBtnclassify_mat(self) end
	UIUtil.GetComponent(self._btnclassify_mat, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnclassify_mat);
	self._onClickBtnclassify_st = function(go) self:_OnClickBtnclassify_st(self) end
	UIUtil.GetComponent(self._btnclassify_st, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnclassify_st);
	self._onClickBtnclassify_sue = function(go) self:_OnClickBtnclassify_sue(self) end
	UIUtil.GetComponent(self._btnclassify_sue, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnclassify_sue);
	
	self._onClickSellNumBg = function(go) self:_OnClickSellNumBg(self) end
	UIUtil.GetComponent(self._goSellNumBg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSellNumBg);
	self._onClickNotice = function(go) self:_OnClickNotice(self) end
	UIUtil.GetComponent(self._goNotice, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickNotice);
	
	self._onClickNoticeMask = function(go) self:_OnClickNotice(self) end
	UIUtil.GetComponent(self._goNoticeMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickNoticeMask);
	
	
	self._onClickTime1 = function(go) self:_OnClickTime1(self) end
	UIUtil.GetComponent(self._sellTime[1].go, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTime1);
	self._onClickTime2 = function(go) self:_OnClickTime2(self) end
	UIUtil.GetComponent(self._sellTime[2].go, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTime2);
	self._onClickTime3 = function(go) self:_OnClickTime3(self) end
	UIUtil.GetComponent(self._sellTime[3].go, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTime3);
	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, SubSaleMyGroundingPanel.ProductsChange, self);
	
end

function SubSaleMyGroundingPanel:_OnClickNotice()
	self._isShowNotice = not self._isShowNotice
	if(not self._isInit) then
		self._isInit = true
		self._txtNotice.text = LanguageMgr.Get("Sale/SubSaleMyGroundingPanel/notice")
	end
	self._goNoticeParent:SetActive(self._isShowNotice)
end

function SubSaleMyGroundingPanel:ProductsChange()
	if(self._gameObject.activeSelf) then
		self._scrollView:ResetPosition()
		if(SaleManager.GetCurSelectItem()) then
			SaleManager.SetCurSelectItem(BackpackDataManager.GetProductById(SaleManager.GetCurSelectItem().id))
		else
			self:UpdateSelectItem()
			ModuleManager.SendNotification(NumInputNotes.CLOSE_NUMINPUT)
		end
		
		self:UpdateMySellListCount()
		self:_OnClickType(self._curType)
	end
end

function SubSaleMyGroundingPanel:_OnClickTime1()
	if(self.data) then
		self:_SetTimeType(1)
	end
end

function SubSaleMyGroundingPanel:_OnClickTime2()
	if(self.data) then
		self:_SetTimeType(2)
	end
end

function SubSaleMyGroundingPanel:_OnClickTime3()
	if(self.data) then
		self:_SetTimeType(3)
	end
end

function SubSaleMyGroundingPanel:_OnCenterCallBack(go)
	if(go) then
		if(self._currentGo == go) then
			return
		end
		self._currentGo = go
		
		local index = self._phalanx:GetItemIndex(go)
		local item = self._pagePhalanx:GetItem(index)
		if(item) then
			item.itemLogic:SetToggle(true)
		end
	end
end

function SubSaleMyGroundingPanel:_OnClickSellNumBg()
	local res = {};
	res.hd = SubSaleMyGroundingPanel._SellNumNumberKeyHandler;
	res.confirmHandler = SubSaleMyGroundingPanel._SellNumConfirmHandler;
	res.hd_target = self;
	res.x = 445;
	res.y = 55;
	res.label = self._txtSellNum
	
	ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function SubSaleMyGroundingPanel:_SellNumNumberKeyHandler(v)
	self._sellCount = tonumber(v)
	self:_SetSellCount()
end

function SubSaleMyGroundingPanel:_SellNumConfirmHandler(v)
	self._sellCount = tonumber(v)
	self:_CheckSellCount()
	self:_SetSellCount()
end

function SubSaleMyGroundingPanel:_CheckSellCount()
	if(self._sellCount < 1) then
		self._sellCount = 1
	end
	
	if(self._sellCount > self.data.am) then
		self._sellCount = self.data.am
	end
	
	if(self._sellCount > maxGroundingCount) then
		MsgUtils.ShowTips("Sale/SubSaleMyGroundingPanel/saleCountSetNotice")
		self._sellCount = maxGroundingCount
	end
end

function SubSaleMyGroundingPanel:_SetSellCount()
	self._txtSellNum.text = tostring(self._sellCount)
	self._txtSellTotalPrice.text = tostring(self._sellPrice * self._sellCount)
end

function SubSaleMyGroundingPanel:_CheckSellPrice()
	if(self._sellPrice > self.data.configData.gold_base + self.data.configData.max_float) then
		self._sellPrice = self.data.configData.gold_base + self.data.configData.max_float
	elseif(self._sellPrice < self.data.configData.gold_base - self.data.configData.max_float) then
		self._sellPrice = self.data.configData.gold_base - self.data.configData.max_float
	end
	
	if(self._sellPrice < 1) then
		self._sellPrice = 1
	end
end

function SubSaleMyGroundingPanel:_SetSellPrice()
	self._txtSellPrice.text = tostring(self._sellPrice)
	self._txtSellTotalPrice.text = tostring(self._sellPrice * self._sellCount)
end

function SubSaleMyGroundingPanel:_OnClickAddPrice()
	if(self.data) then
		self._sellPrice = self._sellPrice + self.data.configData.float_ratio
		self:_CheckSellPrice()
		self:_SetSellPrice()
	end
	
end

function SubSaleMyGroundingPanel:_OnClickReducePrice()
	if(self.data) then
		self._sellPrice = self._sellPrice - self.data.configData.float_ratio
		self:_CheckSellPrice()
		self:_SetSellPrice()
	end
end

function SubSaleMyGroundingPanel:_OnClickAddNum()
	if(self.data) then
		self._sellCount = self._sellCount + 1
		self:_CheckSellCount()
		self:_SetSellCount()
	end
end

function SubSaleMyGroundingPanel:_OnClickReduceNum()
	if(self.data) then
		self._sellCount = self._sellCount - 1
		self:_CheckSellCount()
		self:_SetSellCount()
	end
end


function SubSaleMyGroundingPanel:_OnClickBtnSellList()
	ModuleManager.SendNotification(SaleNotes.CHANGE_SELLPANEL, 1)
end

function SubSaleMyGroundingPanel:_OnClickBtnGrounding()
	if(self.data) then
		SaleProxy.SendSaleItem(self.data.id, self._sellCount, self._sellPrice, self._tt)
	end
end

function SubSaleMyGroundingPanel:_Dispose()
	if self._centerOnChild and self._centerOnChild.onCenter then
		self._centerOnChild.onCenter:Destroy();
	end
	self._delegate = nil
	self:_DisposeListener();
	self:_DisposeReference();
	if(self._phalanx) then
		self._phalanx:Dispose()
		self._phalanx = nil
	end
	
	
	if(self._pagePhalanx) then
		self._pagePhalanx:Dispose()
		self._pagePhalanx = nil
	end
end

function SubSaleMyGroundingPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnSellList, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSellList = nil;
	UIUtil.GetComponent(self._btnGrounding, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGrounding = nil;
	UIUtil.GetComponent(self._goAddPrice, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickAddPrice = nil;
	UIUtil.GetComponent(self._goReducePrice, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickReducePrice = nil;
	UIUtil.GetComponent(self._goSellNumAdd, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickAddNum = nil;
	UIUtil.GetComponent(self._goSellNumReduce, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickReduceNum = nil;
	UIUtil.GetComponent(self._btnclassify_all, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnclassify_all = nil;
	UIUtil.GetComponent(self._btnclassify_eq, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnclassify_eq = nil;
	UIUtil.GetComponent(self._btnclassify_mat, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnclassify_mat = nil;
	UIUtil.GetComponent(self._btnclassify_st, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnclassify_st = nil;
	UIUtil.GetComponent(self._btnclassify_sue, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnclassify_sue = nil;
	UIUtil.GetComponent(self._goSellNumBg, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickSellNumBg = nil;
	UIUtil.GetComponent(self._goNotice, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickNotice = nil;
	UIUtil.GetComponent(self._goNoticeMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickNoticeMask = nil;
	UIUtil.GetComponent(self._sellTime[1].go, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTime1 = nil;
	UIUtil.GetComponent(self._sellTime[2].go, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTime2 = nil;
	UIUtil.GetComponent(self._sellTime[3].go, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTime3 = nil;
	MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, SubSaleMyGroundingPanel.ProductsChange);
	
end

function SubSaleMyGroundingPanel:_DisposeReference()
	self._btnSellList = nil;
	self._btnGrounding = nil;
	self._btnclassify_all = nil;
	self._btnclassify_eq = nil;
	self._btnclassify_mat = nil;
	self._btnclassify_st = nil;
	self._btnclassify_sue = nil;
	self._txtTime1 = nil;
	self._txtTime2 = nil;
	self._txtTime3 = nil;
	self._imgIcon = nil
	self._imgQuality = nil
end

function SubSaleMyGroundingPanel:UpdatePanel()
	self._isShowNotice = false
	self._goNoticeParent:SetActive(self._isShowNotice)
	self:UpdateMySellListCount()
	self:_OnClickType(self._curType)
end

function SubSaleMyGroundingPanel:UpdateSelectItem()
	self.data = SaleManager.GetCurSelectItem()
	if(self.data) then
		ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
		self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		self._txtName.text = self.data.configData.name
		self._txtLevel.text = GetLvDes1(self.data.configData.req_lev)
		self._txtKind.text = ProductManager.GetProductKindName(self.data.configData["kind"], self.data.configData["type"])
		self._txtSellCommission.text = self.data.configData.money_fee
		self._sellPrice = self.data.configData.gold_base
		self._txtSellPrice.text = tostring(self._sellPrice)
		self._sellCount = 1
		self:_SetSellCount()
		self:_SetTimeType(1)
	else
		self._imgIcon.spriteName = ""
		self._imgQuality.color = ColorDataManager.Get_white()
		self._txtName.text = ""
		self._txtLevel.text = ""
		self._txtSellCommission.text = 0
		self._sellPrice = 0
		self._txtSellPrice.text = tostring(self._sellPrice)
		self._sellCount = 0
		self._txtKind.text = ""
		self:_SetSellCount()
		self:_SetTimeType(0)
	end
end

function SubSaleMyGroundingPanel:_SetTimeType(t)
	self._tt = t
	for k, v in ipairs(self._sellTime) do
		if(self._tt == k) then
			v.go:SetActive(false)
			v.txt.effectStyle = UILabel.Effect.IntToEnum(2)
		else
			v.go:SetActive(true)
			v.txt.effectStyle = UILabel.Effect.IntToEnum(0)
		end
	end
	if(self.data) then
		self._txtSellCommission.text = tostring(self.data.configData.money_fee * self._tt)
	else
		self._txtSellCommission.text = "0"
	end
end

function SubSaleMyGroundingPanel:UpdateMySellListCount()
	self._txtMySellListCount.text = SaleManager.GetMySaleCountText()
end

function SubSaleMyGroundingPanel:_OnClick(t)
	self._scrollView:ResetPosition()
	SaleManager.SetCurSelectItem(nil)
	self:UpdateSelectItem()
	self:_OnClickType(t)
end

function SubSaleMyGroundingPanel:_OnClickBtnclassify_all()
	self:_OnClick(1)
end

function SubSaleMyGroundingPanel:_OnClickBtnclassify_eq()
	self:_OnClick(2)
end

function SubSaleMyGroundingPanel:_OnClickBtnclassify_mat()
	self:_OnClick(3)
end

function SubSaleMyGroundingPanel:_OnClickBtnclassify_st()
	self:_OnClick(4)
end

function SubSaleMyGroundingPanel:_OnClickBtnclassify_sue()
	self:_OnClick(5)
end

function SubSaleMyGroundingPanel:_OnClickType(t)
	self._curType = t
	if self._curType == 1 then
		self:SetTypeData({0});
	elseif self._curType == 2 then
		self:SetTypeData({1});
	elseif self._curType == 3 then
		self:SetTypeData({3, 7});
	elseif self._curType == 4 then
		self:SetTypeData({2});
	elseif self._curType == 5 then
		self:SetTypeData({4, 5, 6});
	end
end

function SubSaleMyGroundingPanel:SetTypeData(ts)
	local temp = nil
	if(ts[1] == 0) then
		temp = BackpackDataManager.GetAllProducts(true);
	else
		temp = BackpackDataManager.GetProductsByTypes(ts);
	end
	
	self._bagDatas = {}
	self._bagDatas[1] = {}
	if(temp and table.getCount(temp) > 0) then
		local index = 1
		local count = 0
		for k, v in ipairs(temp) do
			if(not v:IsBind()) then
				count = count + 1
				if(count > 30) then
					count = count - 30
					index = index + 1
				end
				
				if(self._bagDatas[index] == nil) then
					self._bagDatas[index] = {}
				end
				insert(self._bagDatas[index], v)
			end
		end
	end
	
	local maxCount = math.max(1, table.getCount(self._bagDatas))
	self._phalanx:Build(1, maxCount, self._bagDatas)
	self._pagePhalanx:BuildSpe(maxCount, {})
	if(self._pagePhalanx:GetItem(1)) then
		self._pagePhalanx:GetItem(1).itemLogic:SetToggle(true)
	end
end

function SubSaleMyGroundingPanel:UpdateRecentPrice(data)
	if(self.data.spId == data.spId) then
		self._txtRecentPrice.text = tostring(data.price)
	end
end

