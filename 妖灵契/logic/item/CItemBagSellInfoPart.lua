---------------------------------------------------------------
--背包界面 批量出售部分


---------------------------------------------------------------

local CItemBagSellInfoPart = class("CItemBagSellInfoPart", CBox)

--每个标签下面的排序方式单独显示
CItemBagSellInfoPart.EnumSort = 
{	--普通
	[1] = 
	{
		[1] = define.Item.SortType.Sid,
		[2] = define.Item.SortType.Time,
		[3] = define.Item.SortType.Itemlevel,
		[4] = define.Item.SortType.Type,
		[5] = define.Item.SortType.Amount,
	},
	--材料
	[2] = 
	{
		[1] = define.Item.SortType.Sid,
		[2] = define.Item.SortType.Time,
		[3] = define.Item.SortType.Level,
		[4] = define.Item.SortType.Type,
		[5] = define.Item.SortType.Amount,
	},
	-- --宝石
	-- [3] = 
	-- {
	-- 	[1] = define.Item.SortType.Sid,
	-- 	[2] = define.Item.SortType.Time,
	-- 	[3] = define.Item.SortType.Level,
	-- 	[4] = define.Item.SortType.Type,
	-- 	[5] = define.Item.SortType.Amount,
	-- },
	--装备
	[3] = 
	{
		[1] = define.Item.SortType.Equip,
		[2] = define.Item.SortType.Time,
		[3] = define.Item.SortType.Level,
		[4] = define.Item.SortType.Pos,
		[5] = define.Item.SortType.Itemlevel,
	},
	--伙伴	
	[4] = 
	{
		[1] = define.Item.SortType.Partner,
	},
	--碎片	
	[5] = 
	{
		[1] = define.Item.SortType.Chip,
	},			
}

CItemBagSellInfoPart.EnumSortImage = 
{
	[1] = "btn_shijian_paixu_3",
	[2] = "btn_dengji_paixu_1",
	[3] = "btn_leixing_paixu_2",
	[4] = "btn_shuliang_paixu_4",
	[5] = "btn_pinzhi_paixu_5",
	[6] = "btn_leixing_paixu_2",
}


function CItemBagSellInfoPart.ctor(self, obj, parentView)
	CBox.ctor(self, obj)

	self.m_ParentView = parentView
	self.m_SelectItemIndex = nil 
	self.m_SelectItemInfo = nil
	self.m_SelectCount = 0
	self.m_SelectCountMax = 0
	self.m_AllCanSellItems = {}				--缓存批量出售前的道具
	self.m_ItemAmountReduceWhenSell = {} 	--缓存在出售中，数量变小的道具id
	
	self.m_SellBtn = self:NewUI(1, CButton)
	self.m_SellConfirmBtn = self:NewUI(2, CButton)
	self.m_SellInfoWidget = self:NewUI(3, CWidget)
	self.m_NormalInfoWidget = self:NewUI(4, CWidget)
	self.m_CloseSellBtn = self:NewUI(5, CButton)
	self.m_SellTotalCountLabel = self:NewUI(6, CLabel)
	self.m_RedeceBtn = self:NewUI(7, CButton)
	self.m_IncreaseBtn = self:NewUI(8, CButton)
	self.m_SellCountLabel = self:NewUI(9 , CLabel)
	self.m_SellCountBtn = self:NewUI(10, CBox)
	self.m_MaxBtn = self:NewUI(11, CButton)
	self.m_SellPriceIcon = self:NewUI(12, CSprite)
	self.m_SellPriceLabel = self:NewUI(13, CLabel)

	--第一次重登打开背包会加载缓存的排序方式
	g_ItemCtrl:InitBagSortType()

	local tab = g_ItemCtrl.m_RecordItemPageTab
	local sortIndex = g_ItemCtrl.m_RecordItembBagSortTypeCache[tab]
	local sort = CItemBagSellInfoPart.EnumSort[tab][sortIndex]
	self.m_SortPopupBox = self:NewUI(14, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, sortIndex, true)	

	self.m_SortMainLabel = self:NewUI(15, CLabel)
	self.m_ClearBtn = self:NewUI(16, CButton)
	self.m_PartnerChipExchangeBtn = self:NewUI(17, CButton)
	self.m_partnerChipExchangeTipsLabel = self:NewUI(18, CLabel)

	self:InitContent()
	self:InitSortPopup()
	self.m_SellBtn:SetActive(tab ~= 5)
	self.m_partnerChipExchangeTipsLabel:SetActive(tab == 5)
	self.m_PartnerChipExchangeBtn:SetActive(tab == 5)	
end

function CItemBagSellInfoPart.InitContent(self)
	self.m_SellBtn:AddUIEvent("click", callback(self, "ShowSellInfoWidget"))
	self.m_CloseSellBtn:AddUIEvent("click", callback(self, "ShowNormalWidget"))
	self.m_SellConfirmBtn:AddUIEvent("click", callback(self, "OnBtnClick", "SellConfirm"))
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnBtnClick", "Sort"))
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnBtnClick", "Max"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnBtnClick", "ClearUp"))
	self.m_SellCountBtn:AddUIEvent("click", callback(self, "OnBtnClick", "SellCount"))
	self.m_RedeceBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Reduce"))
	self.m_IncreaseBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Increase"))
	self.m_PartnerChipExchangeBtn:AddUIEvent("click", callback(self, "OnChipExchange"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))

	self.m_ParentView:SetValueChangeCallback(self:GetInstanceID(), callback(self, "ValueChangeCallback"))

	self:ShowNormalWidget(true)
end

function CItemBagSellInfoPart.ShowSellInfoWidget( self , itemid)
	g_ItemCtrl.m_RecordItembBagViewState = 2
	self.m_SellInfoWidget:SetActive(true)
	self.m_NormalInfoWidget:SetActive(false)
	--self.m_SellBtn:SetActive(false)
	self.m_SellConfirmBtn:SetActive(true)
	self.m_AllCanSellItems = self:CopyItemsInfo(g_ItemCtrl:GetAllCanSellItems())
	self.m_ItemAmountReduceWhenSell = {}
	itemid = itemid or 0	
	self.m_ParentView:OnValueChange("ShowSellInfo", true, itemid)
end

function CItemBagSellInfoPart.ShowNormalWidget( self , isInit)
	g_ItemCtrl.m_RecordItembBagViewState = 1
	self.m_SellInfoWidget:SetActive(false)
	self.m_NormalInfoWidget:SetActive(true)
	--self.m_SellBtn:SetActive(true)
	self.m_SellConfirmBtn:SetActive(false)
	self.m_ItemAmountReduceWhenSell = {}
	self.m_AllCanSellItems = {}

	--限时正常预览状态下时，清空出售道具队列缓存
	g_ItemCtrl.m_RecordSellItemCache  = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
	}

	self:ResetItemInfo()
	if isInit ~= true then
		self.m_ParentView:OnValueChange("ShowSellInfo", false)
	end
end

function CItemBagSellInfoPart.InitSortPopup(self)
	local tab = g_ItemCtrl.m_RecordItemPageTab
	local tSort = CItemBagSellInfoPart.EnumSort[tab]
	for i = 1, #tSort  do
		self.m_SortPopupBox:AddSubMenu(define.Item.SortTypeString[tSort[i]], nil, CItemBagSellInfoPart.EnumSortImage[tSort[i]])
	end
	self.m_SortPopupBox:SetOffsetHeight(30)
	self.m_SortPopupBox:SetCallback(callback(self, "OnSortChange"))
end

function CItemBagSellInfoPart.OnSortChange(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()

	local iTab = g_ItemCtrl.m_RecordItemPageTab
	local index = self.m_SortPopupBox:GetSelectedIndex()
	local sort = CItemBagSellInfoPart.EnumSort[iTab][index]
	if index ~= g_ItemCtrl.m_RecordItembBagSortTypeCache[iTab] then
		g_ItemCtrl.m_RecordItembBagSortTypeCache[iTab] = index
		oBox:SetMainMenu(subMenu.m_Label:GetText())
		self.m_ParentView:OnValueChange("OnSort")
		--保存排序方式
		g_ItemCtrl:SaveBagSortType(iTab)
	end
end

function CItemBagSellInfoPart.OnBtnClick(self, tKey)
	if tKey == "SellConfirm" then
		self:SellAction()
		self:ShowNormalWidget()

	elseif tKey == "Sort" then

	elseif tKey == "Reduce" then
		if self.m_SelectItemInfo ~= nil then
			local count = self.m_SelectCount - 1
			if count < 1 then
				count = 1
			end
			if count ~= self.m_SelectCount then
				self.m_SelectCount = count
				self.m_ParentView:OnValueChange("ChangeSellCount", self.m_SelectItemIndex, self.m_SelectCount)
			end
		end		

	elseif tKey == "Increase" then				
		if self.m_SelectItemInfo ~= nil then
			local count = self.m_SelectCount + 1
			if count > self.m_SelectCountMax then
				count = self.m_SelectCountMax
			end
			if count ~= self.m_SelectCount then
				self.m_SelectCount = count


				self.m_ParentView:OnValueChange("ChangeSellCount", self.m_SelectItemIndex, self.m_SelectCount)
			end			
		end	

	elseif tKey == "Max" then
		if self.m_SelectItemInfo ~= nil then
			self.m_SelectCount = self.m_SelectCountMax
			self.m_ParentView:OnValueChange("ChangeSellCount", self.m_SelectItemIndex, self.m_SelectCount)
		end	

	elseif tKey == "SellCount" then
		if self.m_SelectItemInfo ~= nil then
			local function syncCallback(self, count)
				self.m_SelectCount = count
				self.m_ParentView:OnValueChange("ChangeSellCount", self.m_SelectItemIndex, self.m_SelectCount)
			end
			g_WindowTipCtrl:SetWindowNumberKeyBorad(
			{num = self.m_SelectCount, min = 1, max = self.m_SelectCountMax, syncfunc = syncCallback , obj = self},
			{widget=  self.m_SellCountBtn, side = enum.UIAnchor.Side.Top ,offset = Vector2.New(0, 10)})
		end	

	elseif tKey == "ClearUp" then
		if g_ItemCtrl:CanArrangeItem(nil, true) then
			g_ItemCtrl:C2GSArrangeItem()
		end
		
	end

end

function CItemBagSellInfoPart.SetItemInfo(self, index, count, tItem )
	if tItem ~= nil then
		self.m_SelectItemIndex = index
		self.m_SelectItemInfo = tItem
		self.m_SelectCount = count	
		self.m_SelectCountMax = tItem:GetValue("amount") 
		self:UpdateText()		
	else 
		self:ResetItemInfo()
	end
end

function CItemBagSellInfoPart.ResetItemInfo(self )
	self.m_SelectItemIndex = nil 
	self.m_SelectItemInfo = nil
	self.m_SelectCount = 0
	self.m_SelectCountMax = 0
	self:UpdateText()
end

function CItemBagSellInfoPart.UpdateText(self )
	if self.m_SelectCount == 0 then
		self.m_SellCountLabel:SetText("--")
	else
		self.m_SellCountLabel:SetText(tostring(self.m_SelectCount))
	end 
	local totalSellCount = 0
	local totalSellPrice = 0
	for _, list in pairs(g_ItemCtrl.m_RecordSellItemCache) do
		for k , v in pairs (list) do
			local tData = v
			local tItem = tData[1]
			local count = tData[2]
			totalSellCount = totalSellCount + count
			local unitPrice = tItem:GetValue("sale_price")
			totalSellPrice = totalSellPrice + count * unitPrice
			--printc("UpdateText  count and price =", count, unitPrice)
		end 
	end
	self.m_SellTotalCountLabel:SetText(string.format("物品数: %d", totalSellCount))
	self.m_SellPriceLabel:SetText(string.format("%d", totalSellPrice))
end

function CItemBagSellInfoPart.OnRePeatPress( self, tKey, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 
	self:OnBtnClick(tKey)
end

function CItemBagSellInfoPart.SellAction( self )
	
	local tSell = {}
	printc("打印批量列表.....................................开始")
	for t, list in pairs(g_ItemCtrl.m_RecordSellItemCache) do
		for k , v in pairs (list) do
			local tData = v
			local oItem = tData[1]
			local count = tData[2]
			local id = oItem:GetValue("id")	
			local tInfo = {itemid = id, amount = count }
			table.insert(tSell, tInfo)	
			printc(string.format(" 标签 = %d,  序号 = %d, 数量 = %d", t, k, count))
		end 
	end
	printc("打印批量列表.....................................结束")
	if #tSell > 0 then
		--出售过程中，背包中的道具数量没有减少，则可以出售，否则提示数量变化
		if next(self.m_ItemAmountReduceWhenSell) == nil then
			netitem.C2GSRecycleItemList(tSell)
		else
			for k, v in pairs(self.m_ItemAmountReduceWhenSell) do
				g_NotifyCtrl:FloatMsg(string.format("%s数量发生变化，请重新确定数量", v.name))
			end
		end
	end
end

function CItemBagSellInfoPart.ValueChangeCallback(self, obj, tType, ...)
	if obj:GetInstanceID() ~= self.m_ParentView:GetInstanceID() then
		return
	end
	local arg1 = select(1, ...)
	local arg2 = select(2, ...)
	local arg3 = select(3, ...)
	local arg4 = select(4, ...)
	if tType == "SelectSellItem" then
		self:SetItemInfo(arg2, arg3, arg4)

	elseif tType == "ChangeSellCount" then
		self:UpdateText()

	elseif tType == "SwitchTab" then
		local tab = g_ItemCtrl.m_RecordItemPageTab
		local sort = g_ItemCtrl.m_RecordItembBagSortTypeCache[tab]		
		self:ResetItemInfo()		
		self.m_SortPopupBox:Clear(sort)
		self:InitSortPopup()
		self.m_SellBtn:SetActive(tab ~= 5)
		self.m_partnerChipExchangeTipsLabel:SetActive(tab == 5)
		self.m_PartnerChipExchangeBtn:SetActive(tab == 5)
	elseif tType == "SyncSelectSellItem" then
		printc(" SyncSelectSellItem ", arg1)
		self.m_SelectItemIndex = arg1
	end
end

function CItemBagSellInfoPart.OnCtrlItemlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		if g_ItemCtrl.m_RecordItembBagViewState == 2 then
			--在出售状态下，道具数量更新了，如果是某些道具没有了，则不能出售
			local t = self.m_AllCanSellItems				
			for i = 1, #t do
				local tCount = g_ItemCtrl:GetTargetItemCountById(t[i].id)
				if t[i].amount > tCount then
					local d = {id = t[i].sid, name = t[i].name}
					self.m_ItemAmountReduceWhenSell[d.id] = d					
				end
			end			
		end

	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then		
		if oCtrl.m_EventData ~= nil then
			if g_ItemCtrl.m_RecordItembBagViewState == 2 then
				--在出售状态下，道具数量更新了，如果是当前选中的道具，并且数量比之前多，则同步数量
				local id = oCtrl.m_EventData:GetValue("id")
				local tCount = oCtrl.m_EventData:GetValue("amount")					
				if self.m_SelectItemInfo ~= nil then			
					if id == self.m_SelectItemInfo:GetValue("id") and 
						tCount > self.m_SelectCountMax then
						self.m_SelectItemInfo = oCtrl.m_EventData
						self.m_SelectCountMax = tCount
					end
				end
				--判断变化的道具，数量是否比原来的数量小
				local t = self.m_AllCanSellItems				
				for i = 1, #t do
					if t[i].id == id and tCount < t[i].amount then						
						local tSid = t[i].sid
						local tName = t[i].name
						local d = {id = tSid, name = tName}
						self.m_ItemAmountReduceWhenSell[tSid] = d
					end
				end
			end
		end
	end
end

function CItemBagSellInfoPart.CopyItemsInfo(self, t)
	local d = {}
	for i = 1, #t do
		local oItem = t[i]
		local tId = oItem:GetValue("id")
		local tSid = oItem:GetValue("sid")
		local tName = oItem:GetValue("name")
		local tAmount = oItem:GetValue("amount")
		local data = {id = tId, sid = tSid, name = tName, amount = tAmount}
		table.insert(d, data)
	end
	return d
end

function CItemBagSellInfoPart.OnChipExchange(self)
	if g_PartnerCtrl:IsHaveMaxStarPartner() then
		CItemPartnerChipExchangeView:ShowView(function (oView)
			oView:DefaultSelect()
		end)
	else
		g_NotifyCtrl:FloatMsg("当前未拥有满星的伙伴")
	end
	
end

return CItemBagSellInfoPart