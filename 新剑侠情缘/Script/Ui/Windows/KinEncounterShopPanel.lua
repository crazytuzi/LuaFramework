local tbUI = Ui:CreateClass("KinEncounterShopPanel")

tbUI.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnOperation = function(self)
		if not self.tbSelectItem then
			me.CenterMsg("你没有选中物品")
			return
		end
		if (self.tbSelectItem.nCount or 0) <= 0 then
			me.CenterMsg("数量不能为0")
			return
		end
		RemoteServer.KinEncounterReq("MakeTool", self.tbSelectItem.nId, self.tbSelectItem.nCount)
	end,

	BtnMinus = function(self)
		self:ReduceCount()
	end,

	BtnPlus = function(self)
		self:AddCount()
	end,

	InputNumber = function(self)
		if not self.tbSelectItem then
			return
		end

		local function fnUpdate(nInput)
			local nResult = self:UpdateNumberInput(nInput)
			return nResult
		end 
		Ui:OpenWindow("NumberKeyboard", fnUpdate)
	end,

	BtnCheckEquipment = function(self)
		if not self.tbSelectItem then
			me.CenterMsg("你没有选中物品")
			return
		end
		RemoteServer.KinEncounterReq("GetTool", self.tbSelectItem.nId)
	end,
}

function tbUI:OnOpen()
	self.tbSelectItem = nil
	self.pPanel:SetActive("BtnCheckEquipment", false)
	self:Refresh()
	RemoteServer.KinEncounterReq("UpdateToolInfo")
end

function tbUI:UpdateNumberInput(nNum)
	if not self.tbSelectItem then
		self.pPanel:Label_SetText("InputCountText", 0)
		return
	end

	if not self:SetCount(nNum) then
		self:SetCount(self.tbSelectItem.nCount, true)
		return self.tbSelectItem.nCount
	end

	return nNum
end

function tbUI:AddCount()
	if not self.tbSelectItem then
		return
	end
	self:SetCount(self.tbSelectItem.nCount + 1)
end

function tbUI:ReduceCount()
	if not self.tbSelectItem then
		return
	end
	self:SetCount(math.max(1, self.tbSelectItem.nCount - 1))
end

function tbUI:SetCount(nToCount, bAjustment)
	local nPrice = self.tbSelectItem.nPrice
	local nHave = KinEncounter:GetWood()

	if bAjustment then
		nToCount = math.max(1, math.floor(nHave / nPrice))
	end

	local nTotalCost = nPrice * nToCount
	if nTotalCost > nHave then
		me.CenterMsg("购买数量已达上限")
		return false
	end

	self.tbSelectItem.nCount = nToCount
	self.pPanel:Label_SetText("InputCountText", nToCount)
	self.pPanel:Label_SetText("TxtCostMoney", nTotalCost)
	self.pPanel:Label_SetColorByName("TxtCostMoney", "White")

	return true
end

function tbUI:UpdateRightPanel()
	self.pPanel:Label_SetText("TxtCostMoney", 0)
	local nHave = KinEncounter:GetWood()
	self.pPanel:Label_SetText("TxtHaveMoney", nHave)

	local szIcon, szIconAtlas = Shop:GetMoneyIcon("Found");
	self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
	self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);
	self.pPanel:SetActive("BtnCheckEquipment", not not self.tbSelectItem)
	self.pPanel:SetActive("GoodsTitle", not not self.tbSelectItem)
	self.pPanel:SetActive("TxtDesc", not not self.tbSelectItem)

	if self.tbSelectItem then
		local nPrice = self.tbSelectItem.nPrice
		local nCount = self.tbSelectItem.nCount
		local nCost = nPrice * nCount

		self.pPanel:Label_SetText("TxtCostMoney", nCost)
		self.pPanel:Label_SetColorByName("TxtCostMoney", nCost <= nHave and "White" or "Red")
		self.pPanel:Label_SetText("InputCountText", self.tbSelectItem.nCount or 1)

		local tbBaseInfo = KItem.GetItemBaseProp(self.tbSelectItem.nShowItemId)
		local szDetail = string.gsub(tbBaseInfo.szIntro, "\\n", "\n")
		self.pPanel:Label_SetText("TxtDetailTitle", tbBaseInfo.szName)
		self.pPanel:Label_SetText("TxtDetailContent", szDetail)

		local tbTextSize1 = self.pPanel:Label_GetPrintSize("TxtDetailTitle")
		local tbTextSize2 = self.pPanel:Label_GetPrintSize("TxtDetailContent")
		local tbSize = self.pPanel:Widget_GetSize("datagroup")
		self.pPanel:Widget_SetSize("datagroup", tbSize.x, 20 + tbTextSize1.y + tbTextSize2.y)
		self.pPanel:DragScrollViewGoTop("datagroup")
		self.pPanel:UpdateDragScrollView("datagroup")

		local nHave, nInUse = 0
		if KinEncounter.tbToolInfo and KinEncounter.tbToolInfo[self.tbSelectItem.nId] then
			nHave = KinEncounter.tbToolInfo[self.tbSelectItem.nId][1] or 0
			nInUse = KinEncounter.tbToolInfo[self.tbSelectItem.nId][2] or 0
		end
		self.pPanel:Label_SetText("TxtDesc", string.format("战场已有数量：%d 库存数量：%d", nInUse, nHave))
	else
		self.pPanel:Label_SetText("TxtDetailContent", "")
		self.pPanel:Label_SetText("InputCountText", 0)
		self.pPanel:UpdateDragScrollView("datagroup")
	end
end

function tbUI:Select(nIdx)
	local tbIds = self:GetItemIds()
	local nId = tbIds[nIdx]
	local tbCfg = KinEncounter.Def.tbToolCfgs[nId]
	if not tbCfg then
		return
	end
	self.tbSelectItem = {
		nIdx = nIdx,
		nId = nId,
		nPrice = tbCfg.nPrice,
		nShowItemId = tbCfg.nShowItemId,
		nCount = 1,
	}
	self:UpdateRightPanel()
end

function tbUI:GetItemIds()
	if not self.tbSortedIds then
		local tbRet = {}
		for nId in pairs(KinEncounter.Def.tbToolCfgs) do
			table.insert(tbRet, nId)
		end
		table.sort(tbRet, function(nId1, nId2)
			return nId1 < nId2
		end)
		self.tbSortedIds = tbRet
	end
	return self.tbSortedIds
end

function tbUI:Refresh()
	if self.tbSelectItem then
		self:Select(self.tbSelectItem.nIdx)
	else
		self:UpdateRightPanel()
	end

	local tbIds = self:GetItemIds()
	local nCount = #tbIds
	local nRows = math.ceil(nCount/2)
	self.ScrollViewGoods:Update(nRows, function(pGrid, nIdx)
		for i=1, 2 do
			local nRealIdx = 2*(nIdx-1)+i
			local nId = tbIds[nRealIdx]
			local tbCfg = KinEncounter.Def.tbToolCfgs[nId]

			local pItem = pGrid["item"..i]
			pItem.pPanel:SetActive("Main", not not tbCfg)
			if tbCfg then
				local tbBaseInfo = KItem.GetItemBaseProp(tbCfg.nShowItemId)
				pItem.pPanel:Label_SetText("TxtItemName", tbBaseInfo.szName)
				pItem.pPanel:SetActive("TipIcon", false)
				pItem.pPanel:SetActive("New", false)

				local szIcon, szIconAtlas = Shop:GetMoneyIcon("Found")
				pItem.pPanel:Sprite_SetSprite("MoneyIcon", szIcon, szIconAtlas)
				pItem.pPanel:Label_SetText("TxtPrice", tbCfg.nPrice)

				pItem.Item:SetItemByTemplate(tbCfg.nShowItemId, nil, me.nFaction, me.nSex, {bShowCDLayer = false})
				pItem.pPanel:SetActive("TagDT", false)

				pItem.pPanel.OnTouchEvent = function()
					self:Select(nRealIdx)
				end
				pItem.Item.fnClick = function()
					self:Select(nRealIdx)
				end 
			end
		end
	end)
end