
---------------------------------------------------------------
--背包界面 道具列表部分


---------------------------------------------------------------

local CItemBagPropPart = class("CItemBagPropPart", CBox)

CItemBagPropPart.EnumSort = {
	Time = 1,
	Level = 2,
	Type = 3,
	Count = 4
}

local test_data = {
	[1] = 20,
	[2] = 120,
	[3] = 140,
	[4] = 200,
}

local PerColNumber = 5

CItemBagPropPart.Config = {
	GridItemMax = 500,
	GridRowMax =  500 / PerColNumber,
	GridRowMin =  20 / PerColNumber,
}

function CItemBagPropPart.ctor(self, obj, parentView)
	CBox.ctor(self, obj)
	self.m_SortType = CItemBagPropPart.EnumSort.Time
	self.m_TabIndex = -1
	self.m_ItemBtnList = {}
	self.m_ParentView = parentView
	self.m_SellSelectIndex = 0
	self.m_SellSelectItem = nil
	self.m_SellSelectBagBox = nil

	self.m_TabGird = self:NewUI(1, CTabGrid)
	self.m_ScrollViewBg = self:NewUI(2, CBox)
	self.m_NonePropWidget = self:NewUI(3, CBox)
	self.m_ItemScrollView = self:NewUI(5, CScrollView)
	self.m_BatSelectBtn = self:NewUI(8, CButton)
	self.m_WrapContent = self:NewUI(9, CWrapContent)
	self.m_ItemCloneHorGrid = self:NewUI(10, CGrid)

	self:InitContent()
end

function CItemBagPropPart.InitContent(self)
	self.m_ItemCloneHorGrid:SetActive(false)
	--默认标签
	--local defaultTab = define.Item.ItemType.Genernal
	local defaultTab = g_ItemCtrl:GetRedDotTab()

	self.m_TabGird.m_TabText = {}
	self.m_TabGird.m_TabList = {}
	self.m_TabGird:InitChild(function ( obj, idx )
		local tTab = CBox.New(obj)
		tTab:SetGroup(self.m_TabGird:GetInstanceID())
		tTab:AddUIEvent("click", callback(self, "OnSwitchTab", idx))
		self.m_TabGird.m_TabText[idx] = tTab:NewUI(1, CLabel)
		self.m_TabGird.m_TabList[idx] = tTab		
		if defaultTab == idx then
			tTab:SetSelected(true)
		end	
		return tTab	
		end)

	self:InitWarpContent()

	self.m_ParentView:SetValueChangeCallback(self:GetInstanceID(), callback(self, "ValueChangeCallback"))	
	self.m_ScrollViewBg:AddUIEvent("press", callback(self, "OnScrollViewBg"))

	self.m_BatSelectBtn:AddUIEvent("click", callback(self, "OnBatSelect"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrlEvent"))

	self:OnSwitchTab(defaultTab)
	self:RefreshTabRedDot()
end

function CItemBagPropPart.RefreshAll(self)
	self:RefreshData(true)
end

function CItemBagPropPart.OnSwitchTab(self, tabIdx , isInit)
	if  self.m_TabIndex == tabIdx then
		return
	end
	self.m_TabIndex = tabIdx
	g_ItemCtrl.m_RecordItemPageTab = self.m_TabIndex
	local sortIndex = g_ItemCtrl.m_RecordItembBagSortTypeCache[tabIdx]
	local sort = CItemBagSellInfoPart.EnumSort[tabIdx][sortIndex]	
	local isSell = (g_ItemCtrl.m_RecordItembBagViewState == 2)
	g_ItemCtrl.m_BagTabItemsCache = g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(tabIdx, sort, isSell)
	self.m_ParentView:OnValueChange("SwitchTab", self.m_TabIndex)	
	--清除当前选中的出售道具
	self.m_SellSelectIndex = 0
	self.m_SellSelectItem = nil
	self:SetCurSellSelectActive(false)
	self.m_SellSelectBagBox = nil
	self:UpdataTabText()
	if isInit ~= true then
		self:RefreshAll()
	end
	self:SetBatBtnVisible()
	g_ItemCtrl:RefeshItemGetTipsByType(tabIdx)
end

function CItemBagPropPart.ValueChangeCallback(self, obj, tType, ...)
	if obj:GetInstanceID() ~= self.m_ParentView:GetInstanceID() then
		return
	end
	local arg1 = select(1, ...)
	local arg2 = select(2, ...)
	local arg3 = select(3, ...)	
	local arg4 = select(4, ...)	
	local arg5 = select(5, ...)	
	if  tType == "ShowSellInfo" then
		local sortIndex = g_ItemCtrl.m_RecordItembBagSortTypeCache[self.m_TabIndex]
		local sort = CItemBagSellInfoPart.EnumSort[self.m_TabIndex][sortIndex]
		local isSell = (g_ItemCtrl.m_RecordItembBagViewState == 2)
		g_ItemCtrl.m_BagTabItemsCache = g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(self.m_TabIndex, sort, isSell)		
		--清除当前选中的出售道具
		self.m_SellSelectIndex = 0
		self.m_SellSelectItem = nil
		self:SetCurSellSelectActive(false)
		self.m_SellSelectBagBox = nil

		--出售时，默认选中某个道具，为0或者为空，不处理
		if isSell == true and arg2 and arg2 ~= 0 then
			local bagData = g_ItemCtrl.m_BagTabItemsCache			
			for i,v in ipairs(bagData) do
				if v:GetValue("id") == arg2 and v:IsEuqipLock() == false then
					g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex][i] = {v, 1, arg2}
					self.m_SellSelectIndex = i
					self.m_SellSelectItem = v
					self.m_SellSelectBagBox = arg5
					self:SetCurSellSelectActive(true)
					self.m_ParentView:OnValueChange("SelectSellItem", true, i, 1, v)
					break
				end
			end			
		end

		self:RefreshAll()			
		self:SetBatBtnVisible()		

	elseif tType == "SelectSellItem" then
		-- arg1 表示选中还是取消选中
		-- arg2 表示当前背包类型下，该道具的序号
		-- arg3 表示当前物品出售的个数(如果当前为取消状态下时，忽略)
		-- arg4 物品信息
		if arg1 == true then
			--缓存出售道具的数量

			--TODO 获取该标签下，该位置的道具信息
			g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex][arg2] = {arg4, arg3, arg4:GetValue("id")}
			-- printc("打印批量列表.....................................开始")
			-- for t, list in pairs (g_ItemCtrl.m_RecordSellItemCache) do
			-- 	for k , v in pairs (list) do
			-- 		local tData = v
			-- 		local tItem = tData[1]
			-- 		local count = tData[2]	
			-- 		printc("tItem ", type(tItem))		
			-- 		printc(string.format(" 标签 = %d,  序号 = %d, 数量 = %d", t, k, count))
			-- 	end 
			-- end
			-- printc("打印批量列表.....................................结束")

			--记录当前选中的出售道具
			self.m_SellSelectIndex = arg2
			self.m_SellSelectItem = arg4
			self:SetCurSellSelectActive(false)
			self.m_SellSelectBagBox = arg5
			self:SetCurSellSelectActive(true)
		else
			--从缓存中取出取消选中的道具的数量
			g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex][arg2] = nil

			--清除当前选中的出售道具
			self.m_SellSelectIndex = 0
			self.m_SellSelectItem = nil
			self:SetCurSellSelectActive(false)
			self.m_SellSelectBagBox = nil
		end	

	elseif tType == "ChangeSellCount" then
		local tData = g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex][arg1]
		tData[2] = arg2
		g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex][arg1] = tData
		--self.m_ItemBtnList[arg1]:SetSellCounttext(arg2)
		local oItemBox = self:GetTargetItemBox(arg1)
		if oItemBox then
			oItemBox:SetSellCounttext(arg2)
		end

	elseif tType == "OnSort" then
		local tab = g_ItemCtrl.m_RecordItemPageTab
		local sortIndex = g_ItemCtrl.m_RecordItembBagSortTypeCache[tab]
		local sort = CItemBagSellInfoPart.EnumSort[tab][sortIndex]
		local isSell = (g_ItemCtrl.m_RecordItembBagViewState == 2)
		g_ItemCtrl.m_BagTabItemsCache = g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(self.m_TabIndex, sort, isSell)
		self:RefreshAllItem()
	end
end

function CItemBagPropPart.OnCtrlItemlEvent( self, oCtrl)
	local tab  = g_ItemCtrl.m_RecordItemPageTab
	local sortIndex = g_ItemCtrl.m_RecordItembBagSortTypeCache[tab]
	local sort = CItemBagSellInfoPart.EnumSort[tab][sortIndex]
	local isSell = (g_ItemCtrl.m_RecordItembBagViewState == 2)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		g_ItemCtrl.m_BagTabItemsCache = g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(self.m_TabIndex, sort, isSell)
		self:SyncSellItemPosition(isSell)
		self:RefreshData(false)
		self.m_ParentView:OnValueChange("OnRefreshBagItem")
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then		
		g_ItemCtrl.m_BagTabItemsCache = g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(self.m_TabIndex, sort, isSell)
		self:RefreshAllItem()		
		self.m_ParentView:OnValueChange("OnRefreshBagItem")
	elseif oCtrl.m_EventID == define.Item.Event.RefreshItemGetRedDot then		
		self:RefreshTabRedDot()
	end
end

function CItemBagPropPart.OnCtrlAttrlEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then

	end
end

function CItemBagPropPart.SyncSellItemPosition( self, isSell)
	if isSell == true then
		local t = {}
		local sellCacheList = g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex]
		local itemList = g_ItemCtrl.m_BagTabItemsCache
		for oPos, oItem in pairs(sellCacheList) do
			local id = oItem[3]
			for tPos, tItem in ipairs(itemList) do
				if tItem:GetValue("id") == id then
					t[tPos] = oItem
					--刷新背包时，如果当前选中的道具位置改变了，则同步位置
					if self.m_SellSelectItem ~= nil then						
						if self.m_SellSelectItem:GetValue("id") == id and self.m_SellSelectIndex ~= tPos then
							self.m_ParentView:OnValueChange("SyncSelectSellItem", tPos, tItem)	
							self.m_SellSelectIndex = tPos
							self.m_SellSelectItem = tItem	
						end
					end							
					break
				end
			end
		end
		g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex] = t
	end
end

function CItemBagPropPart.UpdataTabText(self)
	-- for i = 1, #self.m_TabGird.m_TabText do		
	-- 	if self.m_TabIndex == i then
	-- 		self.m_TabGird.m_TabText[i]:SetActive(false)
	-- 	else
	-- 		self.m_TabGird.m_TabText[i]:SetActive(true)
	-- 	end
	-- end
end

function CItemBagPropPart.OnBatSelect(self )
	CItemBagBatSelectView:ShowView(function(oView)
		oView:SetOkCallBack(callback(self, "BatSelectCb"))
	end)
end

function CItemBagPropPart.BatSelectCb(self, selectTable)
	local bagData = g_ItemCtrl.m_BagTabItemsCache
	local sellCacheList = g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex]
	for i = 1, #bagData do 
		local oItem = bagData[i]
		if oItem and selectTable[oItem:GetValue("itemlevel")] == true then
			if not sellCacheList[i] or sellCacheList[i].count == 0 then
				sellCacheList[i] = {[1] = oItem, [2] = 1}
				self.m_ParentView:OnValueChange("SelectSellItem", true, i, 1, oItem)
			end
		end
	end
	self:RefreshAllItem()
end

function CItemBagPropPart.SetBatBtnVisible(self)
	if g_ItemCtrl.m_RecordItembBagViewState == 2 and g_ItemCtrl.m_RecordItemPageTab == 3 then 
		self.m_BatSelectBtn:SetActive(true)
	else
		self.m_BatSelectBtn:SetActive(false)
	end
end

function CItemBagPropPart.RefreshTabRedDot(self)
	for i = 1, #self.m_TabGird.m_TabList do
		if g_ItemCtrl.m_RedDotIdTable[i] == nil or
		next(g_ItemCtrl.m_RedDotIdTable[i]) == nil then
			self.m_TabGird.m_TabList[i]:DelEffect("RedDot")
		else
			self.m_TabGird.m_TabList[i]:AddEffect("RedDot")
		end
	end
end

function CItemBagPropPart.InitWarpContent(self)
	self.m_WrapContent:SetCloneChild(self.m_ItemCloneHorGrid, 
		function(oChild)
			oChild.m_ItemBoxTable = {}
			oChild:InitChild(function ( obj, idx )
				local oBox = CItemBagBox.New(obj)
				oBox:SetGroup(self.m_WrapContent:GetInstanceID())
				oChild.m_ItemBoxTable[idx] = oBox		
				oChild.m_isInit = false		
				return oBox
			end)	
			return oChild
		end)

	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData and dData.row then		
			oChild:SetActive(true)	
			if oChild.m_Row == dData.row then
				if oChild.m_isInit == true then
					return
				end
			end
	
			oChild.m_isInit = true
			oChild.m_Row = dData.row
			local bagData = g_ItemCtrl.m_BagTabItemsCache
			--出售缓存列表
			local sellCacheList = g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex]			
			for i = 1, PerColNumber do
				if oChild.m_ItemBoxTable[i] then
					local index = (dData.row - 1) * PerColNumber + i
					oChild.m_ItemBoxTable[i]:SetIndexAndParentview(index, self.m_ParentView)

					local oItem  = bagData[index]
					oChild.m_ItemBoxTable[i]:SetBagItem(nil)
					if oItem then
						oChild.m_ItemBoxTable[i]:SetBagItem(oItem)

						--背包状态在出售状态
						if g_ItemCtrl.m_RecordItembBagViewState == 2 then
							--价钱为0，显示不可出售
							local price = oItem:GetValue("sale_price") or 0
							oChild.m_ItemBoxTable[i]:SetItemStateCanSell(price ~= 0)				
							--当前处于出售状态下时，当出售缓存有内容，则显示出售的数量	
							oChild.m_ItemBoxTable[i]:SetSellWidgetActive(true)
							oChild.m_ItemBoxTable[i]:SetSellCounttext(0)			
							if sellCacheList ~= nil then
								for k, v in pairs(sellCacheList) do			
									if v[3] == oItem:GetValue("id") then
										local sellcount = v[2]
										oChild.m_ItemBoxTable[i]:SetSellCounttext(sellcount)			
										break
									end
								end
							end

						--背包状态在正常状态
						else
							--隐藏无法出售的状态				
							oChild.m_ItemBoxTable[i]:SetItemStateCanSell(true)
							oChild.m_ItemBoxTable[i]:SetSellWidgetActive(false)
						end
					end

					if self.m_SellSelectIndex == index then
						oChild.m_ItemBoxTable[i]:SetSelected(true)
					else
						oChild.m_ItemBoxTable[i]:SetSelected(false)
					end

				end				
			end	
		else
			oChild:SetActive(false)
		end
	end)
end

function CItemBagPropPart.RefreshData(self , isReposition)
	local itemCount = #g_ItemCtrl.m_BagTabItemsCache
	--local itemRow = math.ceil( itemCount / PerColNumber) + 1
	--暂时显示的行数，和道具当前的行数一样
	local itemRow = math.ceil( itemCount / PerColNumber)
	itemRow = math.max(itemRow, CItemBagPropPart.Config.GridRowMin) 
	itemRow = math.min(itemRow, CItemBagPropPart.Config.GridRowMax) 
	
	local d = {}
	for i = 1, itemRow do
		local t = {row = i}
		table.insert(d, t)
	end

	local list = self.m_WrapContent:GetChildList()
	for i = 1, #list do
		local oChild = list[i]
		if oChild then
			oChild.m_isInit = false
		end
	end

	self.m_WrapContent:SetData(d, true)

	if isReposition ~= false then
		--重置ScrollView位置		
		self.m_ItemScrollView:ResetPosition()
		-- UITools.MoveToTarget(self.m_ItemScrollView, self.m_BagItemGrid:GetChild(1))
	end	
	self.m_NonePropWidget:SetActive(itemCount == 0)
end

function CItemBagPropPart.RefreshAllItem(self)
	local list = self.m_WrapContent:GetChildList()
	local bagData = g_ItemCtrl.m_BagTabItemsCache
	for i = 1, #list do 
		local oBox = list[i]
		if oBox then
			for k = 1, PerColNumber do 
				local index = (oBox.m_Row - 1) * PerColNumber + k
				--printc(" index = ", oBox.m_Row, index, bagData[index])
				if oBox.m_ItemBoxTable[k] then					
					self:SetItemData(bagData[index], oBox.m_ItemBoxTable[k], index)
				end
			end			
		end
	end
end

--返回指定ItemBox，如果不显示，则返回nil
function CItemBagPropPart.GetTargetItemBox(self, index)
	local list = self.m_WrapContent:GetChildList()
	local row 
	local col = index % PerColNumber
	if col == 0 then
		row = math.floor(index / PerColNumber)
		col = PerColNumber
	else
		row = math.floor(index / PerColNumber) + 1 
	end
	local oBox = nil
	for i = 1, #list do 
		local oChild = list[i]
		if oChild and oChild.m_Row == row then
			oBox = oChild.m_ItemBoxTable[col]
			break	
		end
	end
	return oBox 
end

function CItemBagPropPart.SetItemData(self, oItem, oBox, index)
	if not oBox and not index then
		return
	end
	oBox:SetBagItem(nil)
	if oItem then
		--出售缓存列表
		local sellCacheList = g_ItemCtrl.m_RecordSellItemCache[self.m_TabIndex]
		oBox:SetBagItem(oItem)
		--背包状态在出售状态
		if g_ItemCtrl.m_RecordItembBagViewState == 2 then
			--价钱为0，显示不可出售
			local price = oItem:GetValue("sale_price") or 0
			oBox:SetItemStateCanSell(price ~= 0)				
			--当前处于出售状态下时，当出售缓存有内容，则显示出售的数量	
			oBox:SetSellWidgetActive(true)
			oBox:SetSellCounttext(0)			
			if sellCacheList ~= nil then
				for k, v in pairs(sellCacheList) do			
					if v[3] == oItem:GetValue("id") then
						local sellcount = v[2]
							oBox:SetSellCounttext(sellcount)			
						break
					end
				end
			end
		--背包状态在正常状态
		else
			--隐藏无法出售的状态				
			oBox:SetItemStateCanSell(true)
			oBox:SetSellWidgetActive(false)
		end
	end

	if self.m_SellSelectIndex == index then
		oBox:SetSelected(true)
	else
		oBox:SetSelected(false)
	end
end

function CItemBagPropPart.OnScrollViewBg(self)
	local oView = CItemTipsBaseInfoView:GetView()
	if oView then
		oView:CloseView()
	end
	oView = CItemTipsEquipChangeView:GetView()
	if oView then
		oView:CloseView()
	end
	oView = CItemTipsAttrEquipChangeView:GetView()
	if oView then
		oView:CloseView()
	end
end

function CItemBagPropPart.SetCurSellSelectActive(self, b)
	if self.m_SellSelectBagBox then
		self.m_SellSelectBagBox:SetSellSelectActive(b)
	end
end

return CItemBagPropPart