local tbUi = Ui:CreateClass("MarketStallPanel")

local nTotalPage = 0
local COUNT_PER_PAGE = 8

tbUi.types = {
	all = 1,	--所有摊位
	mine = 2,	--我的摊位
}

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnCareerPage = function(self)
		self:Refresh(self.types.all)
	end,

	BtnTitlePage = function(self)
		self:Refresh(self.types.mine)
	end,

	BtnLeft = function(self)
		if self.nCurPage<=1 then
			return
		end
		self.nCurPage = self.nCurPage-1
		self:RefreshGroup()
	end,

	BtnRight = function(self)
		if self.nCurPage>=nTotalPage then
			return
		end
		self.nCurPage = self.nCurPage+1
		self:RefreshGroup()
	end,

	BtnRefresh1 = function(self)
		self:ManualRefresh()
	end,

	BtnRefresh2 = function(self)
		self:ManualRefresh()
	end,
}

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_MS_ITEM_LIST_CHANGE, self.OnRefreshItemList, self},
		{UiNotify.emNOTIFY_MS_MY_ITEM_LIST_CHANGE, self.RefreshMyMarket, self},
		{UiNotify.emNOTIFY_CHANGE_MONEY, self.RefreshMoney, self},
		{UiNotify.emNOTIFY_MS_ITEM_SOLD, self.RefreshGroup, self},
		{UiNotify.emNOTIFY_MARKET_STALL_REFRESH_ALL, self.RefreshAllMarket, self},
		{UiNotify.emNOTIFY_MS_HAS_LOWER_PRICE, self.OnHasLowerPrice, self},
	}
	return tbRegEvent
end

function tbUi:OnHasLowerPrice(szMainType, nSubType, nCount, nPrice)
	me.MsgBox("[FFFE0D]小提示：当前摊位中有更低价的商品哦。[-]",
	{
		{"前往查看", function ()
			Ui:OpenWindow("MarketStallBuyPanel", {szMainType = szMainType, nSubType = nSubType, nCount = nCount, nPrice = nPrice});
		end},
		{"关闭"},
	});
end

function tbUi:RefreshMoney()
	self.pPanel:Label_SetText("CoinPrice", me.GetMoney("Gold"))
end

function tbUi:StartTimer()
    if self.nTimer then
        return
    end

    self.nTimer = Timer:Register(Env.GAME_FPS, self.UpdateNextRefreshTime, self)
end

function tbUi:StopTimer()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
end

local szSaveKey = "MarketStallShowAllGrps"
function tbUi:InitLogic()
	self.nType = self.all
	self.nCurPage = 1
	self.bShowAllGrps = Client:GetFlag(szSaveKey)

	self:StartTimer()
end

function tbUi:InitUi()
	local goodsGrp = self.GoodsGroup.pPanel
	for i=1,8 do
		goodsGrp:SetActive("item"..i, false)
	end

	self.pPanel:Label_SetText("RefreshPrice", MarketStall.nManualRefreshCost)
	self:InitItemTypeList()

	self.Toggle.pPanel.OnTouchEvent = function()
		self.bShowAllGrps = not self.bShowAllGrps
		Client:SetFlag(szSaveKey, self.bShowAllGrps)
		self:RefreshAllMarket()
	end
end

local tbEquipSubMenu = {
	{Item.EQUIP_HORSE, Item.EQUIP_REIN, Item.EQUIP_SADDLE, Item.EQUIP_PEDAL},
	{szName="铭刻石", Item.ITEM_SCRIPT},
	{Item.EQUIP_WEAPON},
	{Item.EQUIP_HELM},
	{Item.EQUIP_NECKLACE},
	{Item.EQUIP_CUFF},
	{Item.EQUIP_RING},
	{Item.EQUIP_ARMOR},
	{Item.EQUIP_PENDANT},
	{Item.EQUIP_BELT},
	{Item.EQUIP_AMULET},
	{Item.EQUIP_BOOTS},
}

local tbStoneSubMenu = {
	{Item.EQUIP_WEAPON},
	{Item.EQUIP_HELM},
	{Item.EQUIP_NECKLACE},
	{Item.EQUIP_CUFF},
	{Item.EQUIP_RING},
	{Item.EQUIP_ARMOR},
	{Item.EQUIP_PENDANT},
	{Item.EQUIP_BELT},
	{Item.EQUIP_AMULET},
	{Item.EQUIP_BOOTS},
}

local tbTypeSubmenus = {
	[4] = tbEquipSubMenu,	--装备
	[5] = tbStoneSubMenu,	--魂石
}

local tbSubMenuStatus = {
	Hide = 1,
	Show = 2,
}

function tbUi:_UpdateMenuData()
	self.nCurTypeId = self.nCurTypeId or MarketStall.nMyFavTypeId
	local tbMenuItems = {
		-- 我的关注
		{
			nTypeId = MarketStall.nMyFavTypeId,
			szTypeName = "我的关注",
		},
	}
	local tbAllType = Lib:CopyTB(MarketStall.tbAllType)
	table.sort(tbAllType, function(tbA, tbB)
		return tbA.nIndex<tbB.nIndex or (tbA.nIndex==tbB.nIndex and tbA.nTypeId<tbB.nTypeId)
	end)
	for _,tb in ipairs(tbAllType) do
		if MarketStall:IsTypeOpened(tb.nTypeId) then
			table.insert(tbMenuItems, tb)
			local tbSubMenu = tbTypeSubmenus[tb.nTypeId]
			if tbSubMenu then
				if self.nExpandedSubmenu==tb.nTypeId then
					tb.nSubMenuStatus = tbSubMenuStatus.Show
					for _,tbPos in ipairs(tbSubMenu) do
						if MarketStall:IsTypesOpened(tb.nTypeId, tbPos) then
							local szPos = tbPos.szName or Item.EQUIPTYPE_NAME[tbPos[1]]
							table.insert(tbMenuItems, {
								bSubmenu = true,
								nTypeId = tb.nTypeId,
								tbSubTypes = tbPos,
								szTypeName = szPos,
							})
						end
					end
				else
					tb.nSubMenuStatus = tbSubMenuStatus.Hide
				end
			end
		end
	end
	self.tbMenuItems = tbMenuItems
end

function tbUi:UpdateItemTypeList()
	self:_UpdateMenuData()
	local nRows = #self.tbMenuItems
	local fnSetItem = function(pGrid, nIdx)
		local tbData = self.tbMenuItems[nIdx]

		local bSubmenuItem = not not tbData.bSubmenu
		local nSubMenuStatus = tbData.nSubMenuStatus
		pGrid.BaseClass.pPanel:SetActive("BtnStatus", not not nSubMenuStatus)
		if nSubMenuStatus then
			local nY = nSubMenuStatus==tbSubMenuStatus.Hide and 1 or -1
			pGrid.BaseClass.pPanel:ChangeScale("BtnStatus", 1, nY, 1)
		end
		pGrid.BaseClass.pPanel:SetActive("Main", not bSubmenuItem)
		pGrid.SubClass.pPanel:SetActive("Main", bSubmenuItem)
		if bSubmenuItem then
			local szIcon = (tbData.nTypeId==self.nCurTypeId and tbData.tbSubTypes==self.tbCurSubType) and "BtnListSecondPress" or "BtnListSecondNormal"
			pGrid.SubClass.pPanel:Button_SetSprite("Main", szIcon)

			pGrid.SubClass.pPanel:Label_SetText("Label", tbData.szTypeName or "??")
			pGrid.SubClass.pPanel.OnTouchEvent = function()
				self:SelectMarketType(tbData.nTypeId, tbData.tbSubTypes)
			end
		else
			local bFocus = tbData.nTypeId==self.nCurTypeId
			local szIcon = bFocus and "BtnListMainPress" or "BtnListMainNormal"
			pGrid.BaseClass.pPanel:Button_SetSprite("Main", szIcon)
			pGrid.BaseClass.pPanel:Label_SetText("LabelLight", tbData.szTypeName)
			pGrid.BaseClass.pPanel:Label_SetText("LabelDark", tbData.szTypeName)
			pGrid.BaseClass.pPanel:SetActive("LabelDark", not bFocus)
			pGrid.BaseClass.pPanel:SetActive("LabelLight", bFocus)
			pGrid.BaseClass.pPanel.OnTouchEvent = function()
				self:SelectMarketType(tbData.nTypeId)
			end
		end
	end
	self.ScrollViewBtn:Update(nRows, fnSetItem)
end

function tbUi:InitItemTypeList()
	self.nExpandedSubmenu = nil
	self:UpdateItemTypeList()
end

function tbUi:CheckMarketOpen()
	local bRet, szMsg = MarketStall:IsMarketOpen(me)
	if not bRet then
		return false, szMsg
	end
	return true
end

function tbUi:OnOpen(nType)
	local bMarketOpen,err = self:CheckMarketOpen()
	if not bMarketOpen then
		me.CenterMsg(err)
		return 0;
	end
end

function tbUi:OnOpenEnd(nType, nCurTypeId, szMainType, nSelectItemSubType)
	local bMarketOpen,err = self:CheckMarketOpen()
	if nType then
		if not bMarketOpen then
			me.CenterMsg(err)
			return
		end
	end

	self.nCurTypeId = nCurTypeId
	if szMainType and nSelectItemSubType then
		self.szForceMainType = szMainType
		self.nForceSelectSubType = nSelectItemSubType
		local nType = MarketStall:GetItemType(self.szForceMainType, self.nForceSelectSubType)
		if nType then
			self.nCurTypeId = nType
		end
	end
	MarketStall:RefreshAttentionList()
	self:InitLogic()
	self:InitUi()
	self:Refresh(nType)

	self:CheckPopWarningDlg()
end

function tbUi:CheckPopWarningDlg()
	local szKey = "LastPopMarketWarning"
	local nLast = tonumber(Client:GetFlag(szKey)) or 0
	local nNow = GetTime()
	if not Lib:IsDiffMonth(nLast, nNow) then
		return
	end
	Client:SetFlag(szKey, nNow)

	-- KO版本不弹打击倒卖元宝提示
	if version_kor then
		return;
	end

	local szMsg = "官方始终严厉打击倒卖及定向转移元宝等非正常游戏行为，请少侠自觉维护正常交易环境，以免官方进行扣除元宝、封号等处罚措施。"
	me.MsgBox(szMsg, {{"确定"}})
end

function tbUi:OnClose()
	self:StopTimer()
end

function tbUi:UpdateNextRefreshTime()
	local nSec = MarketStall:GetNextRefreshInterval()
	local str = nSec>0 and Lib:TimeDesc(nSec) or "免费"
	self.pPanel:Label_SetText("TxtStallRefresh", str)
	self.pPanel:SetActive("BtnRefresh1", nSec<=0)
	self.pPanel:SetActive("BtnRefresh2", nSec>0)
	return true
end

function tbUi:Refresh(nType)
	self.nType = nType or self.types.all
	self:ResetPanels()

	MarketStall.tbData.nCurStallType = self.nType

	local bOpened,err = self:CheckMarketOpen()
	if not bOpened then
		me.CenterMsg(err)
		return
	end
	self:ResetMarketPanels()
	if self.nType==self.types.mine then
		MarketStall:RefreshMine()
	else
		self:RefreshAllMarket()
	end
end

function tbUi:ResetPanels()
	self.pPanel:SetActive("StallPanel", false)
end

function tbUi:ResetMarketPanels()
	self.pPanel:SetActive("StallPanel", true)

	local bMyMarket = self.nType==self.types.mine
	self.pPanel:Toggle_SetChecked("BtnCareerPage", not bMyMarket)
	self.pPanel:Toggle_SetChecked("BtnTitlePage", bMyMarket)

	self.pPanel:SetActive("AllStall", not bMyMarket)
	self.pPanel:SetActive("MyStall", bMyMarket)

	self:RefreshMoney()
end

function tbUi:RefreshBag()
	local tbAvaliableItems = MarketStall:GetAvaliableItems()
	local nBagRows = math.ceil(#tbAvaliableItems/4)
	self.pPanel:SetActive("Tip2", nBagRows<=0)
	local fnSetItem = function(tbItemGrid, index)
		for i=1,4 do
			local nIdx = 4*(index-1)+i
			local tbData = tbAvaliableItems[nIdx]
			local tbItem = tbItemGrid["item"..i]
			tbItem.pPanel:SetActive("Main", not not tbData)
			if tbData then
				local tb = MarketStall:GetStallAward(tbData.szMainType, tbData.nSubType, tbData.nCount)
				tbItem:SetGenericItem(tb)

				local bLimit, nLastTime = MarketStall:CheckSellLimit(me, tbData.szMainType, tbData.nSubType);
				if not bLimit then
					tbItem.pPanel:SetActive("TagTip", true);
					tbItem.pPanel:Sprite_SetSprite("TagTip", "itemtag_baitanlengque");
					tbItem.pPanel:SetActive("CDLayer", true);
					tbItem.pPanel:Sprite_SetCDControl("CDLayer", nLastTime, MarketStall.nSellLimitTime);
				end

				tbItem.fnClick = function()
					local bLimit, nLastTime = MarketStall:CheckSellLimit(me, tbData.szMainType, tbData.nSubType);
					if not bLimit then
						me.CenterMsg(string.format("%s后才可以上架此物品", Lib:TimeDesc6(nLastTime)));
						return;
					end

					Ui:OpenWindow("MarketStallSellPanel", nIdx, true)
				end
			end
		end
    end
	self.ScrollViewItem:Update(nBagRows, fnSetItem)
end

tbUi.fnClickGrid = function (tbGrid)
	Item:ShowItemCompareTips(tbGrid)
end

function tbUi:RefreshMySellList()
	local tbItems = MarketStall.tbData.tbMyItems
	local nItemCount = #tbItems
	self.pPanel:Label_SetText("TxtMyStall", string.format("%d / 20", nItemCount))

	local nCached = MarketStall:GetTotalCachedMoney()
	self.pPanel:Label_SetText("LoantPrice", nCached)

	local nSellRows = math.ceil(nItemCount/2)
	self.pPanel:SetActive("Tip1", nSellRows<=0)
	local fnSetItem = function(tbItemGrid, index)
		tbItemGrid.pPanel:ChangeScale("Main", 0.85, 0.85, 0.85)
		for i=1,2 do
			local itemIdx = 2*(index-1)+i
			local tbData = tbItems[itemIdx]
			local it = tbItemGrid["item"..i]
			it.pPanel:SetActive("Main", not not tbData)
			if tbData then
				local name = MarketStall:GetItemName(tbData.szMainType, tbData.nSubType)
				it.pPanel:Label_SetText("TxtItemName", name)
				it.pPanel:Label_SetText("TxtPrice", tbData.nPrice)

				local szTagSprice = self:GetMyItemTag(tbData)
				it.pPanel:SetActive("TagDT", not not szTagSprice)
				if szTagSprice then
					it.pPanel:Sprite_SetSprite("TagDT", szTagSprice)
				end

				local tb = MarketStall:GetStallAward(tbData.szMainType, tbData.nSubType, tbData.nCount)
				it.Item:SetGenericItem(tb)
				it.Item.fnClick = self.fnClickGrid
				it.pPanel.OnTouchEvent = function()
					self:ClickMyStoreItem(itemIdx)
				end
			end
		end
	end
	self.ScrollViewGoods:Update(nSellRows, fnSetItem)
end

function tbUi:RefreshMyMarket()
	MarketStall:ClearNotifyStates()

	self:RefreshBag()
	self:RefreshMySellList()
end

function tbUi:ClickMyStoreItem(itemIdx)
	local tbData = MarketStall.tbData.tbMyItems[itemIdx]
	Ui:OpenWindow("MarketStallSellPanel", itemIdx, false)
end

local tbStateTags = {
	[MarketStall.tbItemStates.TimeOut] = "TimeOut",
}
function tbUi:GetMyItemTag(tbData)
	local state = MarketStall:GetItemState(tbData)
	return tbStateTags[state]
end

function tbUi:RefreshAllMarket()
	self.Toggle.pPanel:Toggle_SetChecked("Main", not self.bShowAllGrps)
	self:SelectMarketType(self.nCurTypeId, self.tbCurSubType)
end

function tbUi:RefreshGroup(bNeedRefresh)
	if bNeedRefresh then
		self:SelectMarketType(self.nCurTypeId, self.tbCurSubType);
		return;
	end

	local tbGroup = self.tbCurGroup
	local tbItems = tbGroup.tbItems
	self.pPanel:SetActive("CommodityType", false)

	nTotalPage = math.max(1, math.ceil(#tbItems/COUNT_PER_PAGE))
	if self.nCurPage>nTotalPage then
		self.nCurPage = nTotalPage
	end
	self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nCurPage, nTotalPage))
	self.pPanel:SetActive("Flip", true)
	self.Toggle.pPanel:SetActive("Main", false)

	local goodsGrp = self.GoodsGroup.pPanel
	for i=1,8 do
		local nRealIdx = i+8*(self.nCurPage-1)
		local tbData = tbItems[nRealIdx]
		if tbData then
			local itemGrid = self.GoodsGroup["item"..i]
			local szMainType = tbData.szMainType
			local nSubType = tbData.nSubType

			local name = MarketStall:GetItemName(szMainType, nSubType)
			itemGrid.pPanel:Label_SetText("TxtItemName", name)
			local tb = MarketStall:GetStallAward(szMainType, nSubType, tbData.nCount)
			itemGrid.Item:SetGenericItem(tb)
			itemGrid.Item.fnClick = self.fnClickGrid
			itemGrid.pPanel:SetActive("SoldOut", tbData.nCount<=0)

			itemGrid.pPanel:Label_SetText("TxtPrice", tbData.nPrice)
			itemGrid.pPanel.OnTouchEvent = function()
				if tbData.nCount<=0 then
					me.CenterMsg("此商品已售罄")
				elseif tbData.bCanceled then
					me.CenterMsg("此商品已下架")
				else
					Ui:OpenWindow("MarketStallBuyPanel", tbData)
				end
			end
			itemGrid.pPanel:Toggle_SetChecked("Main", false)
		end
		goodsGrp:SetActive("item"..i, not not tbData)
	end
	self.pPanel:SetActive("GoodsGroup", true)
end

function tbUi:OnRefreshItemList()
	self:_RefreshItemList()
end

function tbUi:_RefreshItemList()
	self.pPanel:SetActive("GoodsGroup", false)
	self.pPanel:SetActive("Flip", false)
	self.Toggle.pPanel:SetActive("Main", true)

	local bHideEmpty = not self.bShowAllGrps
	local tbItems = MarketStall:GetShowStallItems(self.nCurTypeId, self.tbCurSubType, bHideEmpty)
	local szAdditional = ""
	if self.nCurTypeId==MarketStall.nMyFavTypeId then
		local nCount = MarketStall:GetAttentionItemCount()
		szAdditional = string.format("[FFFE0D]（已关注：%d/%d）[-]", nCount, MarketStall.nMaxAttentionCount)
	end
	self.pPanel:Label_SetText("TypeTxt", "选择商品分类"..szAdditional)
	local nRows = math.ceil(#tbItems/2)
	local function fnEnterGrp(tbItem)
		if tbItem.nCount<=0 then
			me.CenterMsg("该分类暂无上架商品")
			return
		end
		self.tbCurGroup = tbItem
		self:RefreshGroup()
	end
	self.ScrollViewType:Update(nRows, function(pGrid, nIdx)
		for i=1,2 do
			local pItem = pGrid[string.format("item%d", i)]
			local nRealIdx = (nIdx-1)*2+i
			local tbItem = tbItems[nRealIdx]
			pItem.pPanel:SetActive("Main", not not tbItem)
			if tbItem then
				local szMainType, nSubType = tbItem.szMainType, tbItem.nSubType
				pItem.pPanel:Label_SetText("ItemType", tbItem.szName)
				pItem.pPanel:Label_SetText("Number", tbItem.nCount)

				if tbItem.szIcon and tbItem.szAtlas then
					pItem.Item.pPanel:Sprite_SetSprite("ItemLayer", tbItem.szIcon, tbItem.szAtlas)
					pItem.Item.pPanel:SetActive("ItemLayer", true)
					pItem.Item.pPanel:Sprite_SetSprite("Color", "itemframe")
					pItem.Item.pPanel:SetActive("LightAnimation", false)
					pItem.Item.pPanel:SetActive("Fragment", false)
				else
					local tb = MarketStall:GetStallAward(szMainType, nSubType, 0)
					pItem.Item:SetGenericItem(tb)
				end

				pItem.Item.fnClick = self.fnClickGrid
				pItem.pPanel.OnTouchEvent = function()
					fnEnterGrp(tbItem)
				end

				local bAttention = MarketStall:IsAttention(szMainType, nSubType)
				pItem.Heart.pPanel:Sprite_SetSprite("Main", bAttention and "heart" or "heartblank")
				pItem.Heart.pPanel.OnTouchEvent = function()
					if not MarketStall:IsAttention(szMainType, nSubType) then
						MarketStall:SetAttention(szMainType, nSubType)
					else
						MarketStall:CancelAttention(szMainType, nSubType)
					end
				end
			end
		end
	end)
	self.pPanel:SetActive("CommodityType", true)
	self.pPanel:SetActive("Tip3", nRows<=0)

	if self.szForceMainType and self.nForceSelectSubType then
		local tbFoundItem = { nCount=0, }
		for i,v in ipairs(tbItems) do
			if v.szMainType==self.szForceMainType and v.nSubType==self.nForceSelectSubType then
				tbFoundItem = v
				break
			end
		end
		fnEnterGrp(tbFoundItem)
		self.nForceSelectSubType = nil
	end
end

function tbUi:SelectMarketType(nTypeId, tbSubType)
	self.nCurTypeId = nTypeId
	self.tbCurSubType = tbSubType
	self.nCurPage = 1

	if tbSubType and #tbSubType>0 then
	else
		if nTypeId==self.nExpandedSubmenu then
			self.nExpandedSubmenu = nil
		else
			self.nExpandedSubmenu = nTypeId
		end
	end
	self:UpdateItemTypeList()

	MarketStall:AutoRefresh()
	MarketStall:RefreshType(nTypeId)
end

function tbUi:ManualRefresh()
	local fnConfirm = function()
		if MarketStall:ManualRefresh() then
			self:SelectMarketType(self.nCurTypeId)
		end
	end
	local cost = MarketStall:GetManualRefreshCost()
	if cost>0 then
		if me.GetVipLevel()<MarketStall.nManualRefreshVipMin then
			me.CenterMsg(string.format("需要达到剑侠尊享%d级，才可刷新", MarketStall.nManualRefreshVipMin))
			return
		end
		me.MsgBox(string.format("确定要花费 [FFFE0D]%d元宝[-] 进行刷新吗？", cost),
				{{"确定", fnConfirm}, {"取消"}}, "MarketStallRefresh");
	else
		fnConfirm()
	end
end
