local tbUi = Ui:CreateClass("ItemRecoveryPanel");
local tbItemRecovery 	= Item.tbItemRecovery;
local ITEM_PER_LINE = 4;
local MIN_LINE_Right = 4;
local MIN_LINE_Left = 3;


function tbUi:OnOpen()
	if not tbItemRecovery:IsShowUi(me) then
		me.CenterMsg("您没有要回收系统的道具")
		return 0 
	end
	Client:SetFlag("SeeItemRecoveryDay", Lib:GetLocalDay())
	Item.tbItemRecovery:CheckRedPoint()
end

function tbUi:OnOpenEnd(  )
	self:AutoSelect()
	self:Reset()
end

function tbUi:GetRecoveryItemList(  )
	local tbItemList = {}
	for i, v in ipairs(tbItemRecovery.SAVE_KEY) do
		local nItemId = me.GetUserValue(tbItemRecovery.SAVE_GROUP, v[1])
		if nItemId ~= 0 then
			table.insert(tbItemList, {nItemId = nItemId, index = i})
		end
	end
	return tbItemList
end

function tbUi:AutoSelect(  )
	local tbItemList = self:GetRecoveryItemList()
	for i=1,2 do
		local tbItemInfo = tbItemList[i]
		if tbItemInfo then
			local tbItemBase = KItem.GetItemBaseProp(tbItemInfo.nItemId)
			self.pPanel:Label_SetText("ToggleTxt" .. i, tbItemBase.szName)
			self.pPanel:SetActive("Toggle" .. i, true)
		else
			self.pPanel:SetActive("Toggle" .. i, false)
		end
	end
	self.pPanel:Toggle_SetChecked("Toggle1", true)
	self.pPanel:Toggle_SetChecked("Toggle2", false)
	self.tbCurRecoveryItemId = tbItemList[1];
end

function tbUi:UpdateTxt()
	local tbTxts = {}
	local nItemId = self.tbCurRecoveryItemId.nItemId
	local tbItemBase = KItem.GetItemBaseProp(nItemId)
	table.insert(tbTxts, string.format("当前选中礼包含以下道具：", tbItemBase.szName))
	local tbSubItemList = tbItemRecovery.tbCurRevoryRandItemList[nItemId]
	local tbCurPutIn = {} --[subItemId] = nCount
	for i,tbData in ipairs(self.tbLeftItemList) do
		local nSubItem = tbItemRecovery:GetTarItemIdFromData( tbData, me)
		tbCurPutIn[nSubItem] = (tbCurPutIn[nSubItem] or 0) + tbData.nCount;
	end
	local tbNeedRecoveryIndex = tbItemRecovery:GetCurItemLeftSubList(me, self.tbCurRecoveryItemId.index)
	local tbStateColor = {
		[1]	= "ffffff";
		[2] = "848484";
		[3] = "ff8f06";
	}
	for i2,v2 in ipairs(tbSubItemList) do
		--区分默认状态，已经回收， 当前放入，
		local nState = 1
		local szExt2 = ""
		if tbNeedRecoveryIndex[i2] == 0 then
			nState = 2;
			szExt2 = "—已回收"
		else
			local nPutCount = tbCurPutIn[v2.Item] 
			if nPutCount and nPutCount > 0 then
				tbCurPutIn[v2.Item] = nPutCount - 1;
				nState = 3;	
			end
		end
		local tbItemBase = KItem.GetItemBaseProp(v2.Item)
		local szExtDesc = ""
		if 6533 == v2.Item then
			szExtDesc = "(若货币不足，则扣到负)"
		end
		table.insert(tbTxts, string.format("[%s](%d)%s(%d黎饰)%s%s[-]", tbStateColor[nState], i2,tbItemBase.szName, v2.nPrice,szExtDesc, szExt2) )
	end
	local szDesc = table.concat( tbTxts, "\n")
	self.Content:SetLinkText(szDesc)
	local tbTextSize = self.pPanel:Label_GetPrintSize("Content");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");

	local nDebtSilverBoard = self:GetCurLeftDebt()
	self.pPanel:Label_SetText("TextTxt", string.format("该礼包剩余扣除[ffff00]%d[-]黎饰", nDebtSilverBoard))
end

function tbUi:Reset()
	local tbRightItemList = {};

	local _, tbOrgSubItemList = tbItemRecovery:GetCurItemLeftSubList( me, self.tbCurRecoveryItemId.index)

	for k,_ in pairs(tbOrgSubItemList) do
		local tbFindItems = me.FindItemInPlayer(k)
		for i2,v2 in ipairs(tbFindItems) do
			table.insert(tbRightItemList, { type  = "itemId",nTemplateId = v2.dwTemplateId,  nItemId = v2.dwId, nCount = v2.nCount})
		end
		if k == 10912 then
			local tbInsetInfo = me.GetInsetInfo(Item.EQUIPPOS_BELT)
			for i2, nStoneId in ipairs(tbInsetInfo) do
				if nStoneId == k then
					table.insert(tbRightItemList, {type = "InsetStoneId", nTemplateId = nStoneId, nCount = 1, nEquipPos = Item.EQUIPPOS_BELT, nInsetPos = i2 })
					break;
				end
			end
		elseif k == 10941 or k == 10590 or k == 7420 or k == 9313 then 
			local tbSame = tbItemRecovery.tbEqualItemList[k]
			for k2,v2 in pairs(tbSame) do
				local tbFindItems = me.FindItemInPlayer(k2)
				for i3,v3 in ipairs(tbFindItems) do
					table.insert(tbRightItemList, {type = "sameItemId", nTemplateId = v3.dwTemplateId, nItemId = v3.dwId, nCount = v3.nCount, org = k})
				end
			end
		elseif k == 7670 then
			--身上所有的5级初级魂石都有可能，在那个表里的
			--身上的，已镶嵌的
			local tbSame = tbItemRecovery.tbEqualItemList[k]
			local tbAllStoneInBags = me.FindItemInBag("Stone")
			for i2,v2 in ipairs(tbAllStoneInBags) do
				if tbSame[v2.dwTemplateId] then
					table.insert(tbRightItemList, {type = "sameItemId", nTemplateId = v2.dwTemplateId, nItemId = v2.dwId, nCount = v2.nCount,org = k})
				end
			end
			for nEquipPos = 0,9 do
				local tbInsetInfo = me.GetInsetInfo(nEquipPos)
				for i2, nStoneId in ipairs(tbInsetInfo) do
					if tbSame[nStoneId] then
						table.insert(tbRightItemList, {type = "sameInsetStoneId", nTemplateId = nStoneId, nCount = 1, nEquipPos = nEquipPos, nInsetPos = i2, org = k})	
					end
				end
			end
		elseif k == 6533 then
			local tbSame = tbItemRecovery.tbEqualItemList[k]
			for k2,v2 in pairs(tbSame) do
				local tbFindItems = me.FindItemInPlayer(k2)
				local _,v3 = next(tbFindItems)
				if v3 then
					table.insert(tbRightItemList, {type = "sameItemId", nTemplateId = v3.dwTemplateId, nItemId = v3.dwId, nCount = v3.nCount, org = k})
				else
					--假的货币道具
					table.insert(tbRightItemList, {type = "FakeMoneyItem", nTemplateId = k2, nCount = 1, org = k})
				end
			end
		end
	end
	
	self.tbRightItemList = tbRightItemList; --由于都是不可叠加的，就直接诶按道具id来了

	self.tbLeftItemList = {};

	self:UpdateLeftAndRight()
end

function tbUi:UpdateLeftAndRight()
	self:UpdateRigtItemList()
	self:UpdateLeftItemList()
	self:UpdateTxt()
end

function tbUi:CheckCanAdd( tbData )
	local tbNewData = Lib:CopyTB(tbData)
	tbNewData.nCount = 1;
	local tbNew = Lib:CopyTB(self.tbLeftItemList)
	table.insert(tbNew, tbNewData)
	local bRet ,szMsg = tbItemRecovery:CheckRecovery(me, tbNew, self.tbCurRecoveryItemId.index) 
	if not bRet then
		return false
	end
	return true
end

function tbUi:UpdateRigtItemList()
	local fnClick = function (itemObj)
		local nItemIndex = itemObj.nItemIndex
		local tbData = self.tbRightItemList[nItemIndex];
		if not self:CheckCanAdd(tbData) then
			me.CenterMsg("不可以加入更多了")
			return
		end
		self:OnSelItem(self.tbRightItemList, self.tbLeftItemList, nItemIndex)
	end

	local fnSetItem = function(tbItemGrid, index)
		local nStart = (index - 1) * ITEM_PER_LINE
		for i = 1, ITEM_PER_LINE do
			local tbData = self.tbRightItemList[nStart + i];
			local tbGrid = tbItemGrid:GetGrid(i)
			if tbData then
				local bEquip = false
				if tbData.nItemId  then
					local pItem = me.GetItemInBag(tbData.nItemId)					
					if pItem and pItem.IsEquip() == 1 then
						bEquip = true;
					end
				end
				if bEquip then
					tbGrid:SetItem(tbData.nItemId)
				else
					tbGrid:SetItemByTemplate(tbData.nTemplateId, tbData.nCount)
				end
				
				tbGrid.nItemIndex = nStart + i;
				tbGrid.fnClick = fnClick;
				tbGrid.fnLongPress = tbGrid.DefaultClick;
				tbGrid.pPanel:SetActive("Main", true)

			else
				tbGrid.nItemIndex = nil;
				tbGrid:Clear();
				tbGrid.pPanel:SetActive("Main", false)
			end
		end
	end

	self.ScrollView2:Update( math.max(math.ceil(#self.tbRightItemList / ITEM_PER_LINE), MIN_LINE_Right), fnSetItem);    -- 至少显示5行
end

function tbUi:OnSelItem(tbScrItems, tbTarItems, nItemIndex)
	local tbMoveData = tbScrItems[nItemIndex]
	if not tbMoveData then
		return
	end
	if  tbMoveData.nCount > 1 then
		tbMoveData.nCount = tbMoveData.nCount - 1
		local tbFindSameItem;
		if tbMoveData.nItemId then
			for i,v in ipairs(tbTarItems) do
				if v.nItemId == tbMoveData.nItemId then
					tbFindSameItem = v
					break;
				end
			end
		end
		if tbFindSameItem then
			tbFindSameItem.nCount = (tbFindSameItem.nCount or 0) + 1;
		else
			local tbNewData = Lib:CopyTB(tbMoveData)
			tbNewData.nCount = 1;
			table.insert(tbTarItems, tbNewData)	
		end
	else

		table.remove(tbScrItems, nItemIndex)	
		table.insert(tbTarItems, tbMoveData)
	end

	self:UpdateLeftAndRight();
end

function tbUi:UpdateLeftItemList()
	local fnClick = function (itemObj)
		self:OnSelItem(self.tbLeftItemList, self.tbRightItemList, itemObj.nItemIndex)
	end

    local fnSetItem = function(tbItemGrid, index)
	    local nStart = (index - 1) * ITEM_PER_LINE
	    for i = 1, ITEM_PER_LINE do
	    	local nItemIndex = nStart + i
	        local tbData = self.tbLeftItemList[nItemIndex];
        	local tbGrid = tbItemGrid:GetGrid(i)
	        if tbData then
				tbGrid:SetItemByTemplate(tbData.nTemplateId, tbData.nCount );
	        	tbGrid.nItemIndex = nItemIndex;
	        	tbGrid.fnClick = fnClick;
	        	tbGrid.fnLongPress = tbGrid.DefaultClick;
			else
				tbGrid.nItemIndex = nil;
				tbGrid:Clear();
	        end
	    end
	end

    self.ScrollView1:Update( math.max(math.ceil(#self.tbLeftItemList / ITEM_PER_LINE), MIN_LINE_Left), fnSetItem);    -- 至少显示5行
end

function tbUi:OnSyncItem()
	self:Reset();
end

function tbUi:OnSyncData( szType )
	if szType == "UpdateTopButton" then
		local tbItemList = self:GetRecoveryItemList( )
		if not next(tbItemList) then
			Ui:CloseWindow(self.UI_NAME)
		else
			local bFind = false
			for i,v in ipairs(tbItemList) do
				if v.index == self.tbCurRecoveryItemId.index then
					bFind = true;
					break;
				end
			end
			if not bFind then
				self:AutoSelect()
			end
			self:Reset()	
		end
	end
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:Toggle1(  )
	local tbItemList = self:GetRecoveryItemList()
	self.tbCurRecoveryItemId = tbItemList[1];
	self:Reset()
end

function tbUi.tbOnClick:Toggle2(  )
	local tbItemList = self:GetRecoveryItemList()
	self.tbCurRecoveryItemId = tbItemList[2];	
	self:Reset()
end

function tbUi:GetCurLeftDebt(  )
	local tbSubItemList = tbItemRecovery.tbCurRevoryRandItemList[self.tbCurRecoveryItemId.nItemId]
	local tbNeedRecoveryIndex = tbItemRecovery:GetCurItemLeftSubList(me, self.tbCurRecoveryItemId.index)
	
	for i,v in ipairs(self.tbLeftItemList) do
		local dwTemplateId = tbItemRecovery:GetTarItemIdFromData(v, me)
		for i2=1,v.nCount do
			local nIndex = tbItemRecovery:GetRecoveryBitIndex(tbNeedRecoveryIndex,tbSubItemList,dwTemplateId)
			tbNeedRecoveryIndex[nIndex] = 0;
		end
	end
	local nDebtSilverBoard = 0;
	for i,v in ipairs(tbSubItemList) do
		if tbNeedRecoveryIndex[i] == 1 then
			nDebtSilverBoard = nDebtSilverBoard + v.nPrice
		end
	end
	nDebtSilverBoard = math.min(tbItemRecovery.nMaxDebtSilverBoard, nDebtSilverBoard)
	return nDebtSilverBoard;
end

function tbUi.tbOnClick:BtnRecovery()
	if not next(self.tbLeftItemList) then
		me.CenterMsg("您并未放入任何回收道具!")
		return
	end

	local bRet, szMsg = tbItemRecovery:CheckRecovery(me, self.tbLeftItemList, self.tbCurRecoveryItemId.index)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	local fnYes = function ( )
		RemoteServer.RequestItemRecovery(self.tbLeftItemList, self.tbCurRecoveryItemId.index);
	end

	local tbItemNameList = {}
	for i,v in ipairs(self.tbLeftItemList) do
		local tbItemBase = KItem.GetItemBaseProp(v.nTemplateId)
		table.insert(tbItemNameList, string.format("[ffff00]%s%s[-]",tbItemBase.szName, v.nCount > 1 and "*" .. v.nCount  or ""))
	end

	local nDebtSilverBoard = self:GetCurLeftDebt()
	local szMsg = string.format("您确认提交道具：%s 吗？提交后剩余扣除[ffff00]黎饰%d[-]%s", table.concat( tbItemNameList, "、"), nDebtSilverBoard, nDebtSilverBoard > 0 and "，之后仍可继续提交" or "");
	me.MsgBox(szMsg, {{"同意", fnYes}, {"取消"}})
	
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_SYNC_DATA,          self.OnSyncData},
    };

    return tbRegEvent;
end
