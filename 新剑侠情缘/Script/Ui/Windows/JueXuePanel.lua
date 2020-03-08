local tbUi        = Ui:CreateClass("JueXuePanel")
local tbDef       = JueXue.Def
local JUEXUE      = 1
local MIBEN       = 2
local DUANPIAN    = 3
local tbClassName = {[JUEXUE] = "JuexueBook", [MIBEN] = "MibenBook", [DUANPIAN] = "DuanpianBook"}

local tbAreaTip   = {"未开放", "未激活", "未装备"}
function JueXue:SetPanelCurPos(nType, nPos)
	self.nPanelCurType = nType
	self.nPanelCurPos  = nPos
end

function JueXue:GetPanelCurPos()
	return self.nPanelCurType, self.nPanelCurPos
end

function tbUi:GetAreaTipEx(nAreaId)
	local tbInfo = tbDef.tbAreaInfo[nAreaId]
	if not Lib:IsEmptyStr(tbInfo.szTimeFrame) then
		if GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
			return 1
		end
		if not JueXue:IsAreaActivate(me, nAreaId) then
			return 2
		end
		return 3
	end

	local nTip = 3
	for _, nChildArea in pairs(tbInfo.tbChildArea or {}) do
		local nPreTip = self:GetAreaTipEx(nChildArea)
		nTip = math.min(nTip, nPreTip)
	end
	return nTip
end


function tbUi:OnOpen(nSelectPos)
	for nAreaId = 1, #tbDef.tbAreaInfo do
		local bActivate = JueXue:IsAreaActivate(me, nAreaId)
		local nBeginPos = (nAreaId - 1) * tbDef.nAreaEquipPos + Item.EQUIPPOS_JUEXUE_BEGIN - 1
		local szJxName, nDpSkill

		self.pPanel:SetActive("LostKnowledgeFrame" .. nAreaId, bActivate)
		self.pPanel:SetActive("Label_Node" .. nAreaId, bActivate)
		for nAreaPos = 1, tbDef.nAreaEquipPos do
			local nTruePos = nBeginPos + nAreaPos
			local nDpPosSub = nAreaPos - tbDef.nDuanPianEquipStartPos
			local szItemName = "Item" .. nAreaId .. nAreaPos
			if not self[szItemName] then
				break
			end
			self.pPanel:SetActive(szItemName, bActivate)
			local szMibenAddItem = "Num" ..nAreaId .. nAreaPos
			local szMibenAdd = ""
			if not bActivate then
				self.pPanel:SetActive("Select" .. nAreaId .. nAreaPos, false)
				if nDpPosSub > 0 and tbDef.tbAreaInfo[nAreaId].bSuit then
					self.pPanel:SetActive("line" .. nAreaId .. nDpPosSub, false)
				end
			else
				local pEquip = me.GetEquipByPos(nTruePos)
				if pEquip then
					self[szItemName]:SetItem(pEquip.dwId)
					self[szItemName].szItemOpt = "JuexueEquip"
					pEquip.nCurEquipAreaId = nAreaId
					if nAreaPos == 1 then
						local nXL = JueXue:GetXiuLianLv(me, nAreaId)
						self[szItemName].pPanel:SetActive("LabelSuffix", nXL > 0)
						if nXL > 0 then
							local szXiulian = "[FFFFFF]+" .. nXL .."[-]" --FFF596
							self[szItemName].pPanel:Label_SetText("LabelSuffix", szXiulian)
						end
					end
					if pEquip.szClass == tbClassName[DUANPIAN] then
						local nMibenAdd = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nMibenAdd)
						if nMibenAdd > 0 then
							szMibenAdd = "[67FF6EFF]+" .. nMibenAdd .. "%"
						elseif nMibenAdd < 0 then
							szMibenAdd = "[FF5D5DFF]" .. nMibenAdd .. "%"
						end
						local nSuitId = pEquip.GetIntValue(JueXue.Def.tbDuanpianItemData.nSuitSkillId)
						JueXue:SetDuanpianIcon(self[szItemName].pPanel, nSuitId)
					end
				else
					self[szItemName]:Clear()
					self[szItemName].pPanel:SetActive("ItemLayer", true)
					self[szItemName].pPanel:Sprite_SetSprite("ItemLayer", "itemframeCDL", "UI/Atlas/NewAtlas/Panel/NewPanel.prefab");
				end
				self[szItemName].fnClick = function (itemObj)
					local nTab = self:ChooseItem(nAreaId, nAreaPos)
					self:ChangeMijiTab(nTab, true)
					if itemObj.nItemId then
						Item:ShowItemDetail(itemObj)
					end
				end
				if nAreaPos == 1 and pEquip then
					szJxName = pEquip.szName
				end

				if tbDef.tbAreaInfo[nAreaId].bSuit and nDpPosSub >= 0 then
					local nCurSkill = 0
					if pEquip then
						nCurSkill = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nSuitSkillId)
					end
					if nDpPosSub > 0 then
						self.pPanel:SetActive("line" .. nAreaId .. nDpPosSub, nCurSkill > 0 and nCurSkill == nDpSkill)
					end
					nDpSkill = nCurSkill
				end
				local bSelected = nAreaId == self.nCurClickAreaId and nAreaPos == self.nCurClickAreaPos
				self.pPanel:SetActive("Select" .. nAreaId .. nAreaPos, bSelected)
			end
			if self.pPanel:CheckHasChildren(szMibenAddItem) then
				self.pPanel:Label_SetText(szMibenAddItem, szMibenAdd)
			end
		end

		local bQuickExchange = bActivate and not szJxName
		if not szJxName then
			local nTip = self:GetAreaTipEx(nAreaId)
			szJxName = tbAreaTip[nTip] or ""
			if bQuickExchange then
				local tb4Choose = self:GetExchangeList()
				for nTemplate, _ in pairs(tb4Choose) do
					local tbItem = me.FindItemInBag(nTemplate)
					if tbItem and next(tbItem) then
						bQuickExchange = false
						break
					end
				end
			end
		end
		self.pPanel:Label_SetText("LostKnowledgeName" .. nAreaId, szJxName)
		self.pPanel:SetActive("BtnQuickexchange" .. nAreaId, bQuickExchange)
	end

	if nSelectPos then
		nSelectPos = nSelectPos - Item.EQUIPPOS_JUEXUE_BEGIN + 1
		local nAreaId  = math.ceil(nSelectPos/tbDef.nAreaEquipPos)
		local nAreaPos = nSelectPos - (nAreaId - 1) * tbDef.nAreaEquipPos
		local nTab     = self:ChooseItem(nAreaId, nAreaPos)
		self:ChangeMijiTab(nTab)
		return
	end
	local nCurTab = self.nTab or DUANPIAN
	self.nTab = nil
	self:ChangeMijiTab(nCurTab)
end

function tbUi:UpdateClickItem(nTab, nAreaId, nAreaPos)
	local nTruePos = (nAreaId - 1) * tbDef.nAreaEquipPos + Item.EQUIPPOS_JUEXUE_BEGIN - 1 + nAreaPos
	JueXue:SetPanelCurPos(nTab, nTruePos)

	if self.nCurClickAreaId and self.nCurClickAreaPos then
		if nAreaId == self.nCurClickAreaId and nAreaPos == self.nCurClickAreaPos then
			return
		end

		local szItemName = "Select" .. self.nCurClickAreaId .. self.nCurClickAreaPos
		self.pPanel:SetActive(szItemName, false)
	end
	self.nCurClickType    = nTab
	self.nCurClickAreaId  = nAreaId
	self.nCurClickAreaPos = nAreaPos
	local szItemName = "Select" .. self.nCurClickAreaId .. self.nCurClickAreaPos
	self.pPanel:SetActive(szItemName, true)
end

function tbUi:ChooseItem(nAreaId, nAreaPos)
	local nTab = math.min(nAreaPos, 3)
	if (tbDef.tbAreaInfo[nAreaId] or {}).bNotMiben and nTab == 2 then
		nTab = 3
	end
	self:UpdateClickItem(nTab, nAreaId, nAreaPos)
	return nTab
end

function tbUi:ChangeMijiTab(nTab, bNoUpdateSelectItem)
	if self.nTab == nTab then
		return
	end
	self.nTab = nTab
	for i = JUEXUE, DUANPIAN do
		self.pPanel:Toggle_SetChecked("Btn" .. i, self.nTab == i)
	end

	local tbItem = me.FindItemInBag(tbClassName[nTab])
	if nTab == JUEXUE then
		--绝学的排序是优先本门派，其次先按品质（从高到低），再按门派（从低到高）
		local nMyFaction = me.nFaction
		table.sort(tbItem, function (p1, p2)
			if p1 and p2 then
				local nFaction1 = JueXue.tbJuexue[p1.dwTemplateId].Faction
				local nFaction2 = JueXue.tbJuexue[p2.dwTemplateId].Faction
				if (nFaction1 ~= nFaction2) and (nFaction1 == nMyFaction or nFaction2 == nMyFaction) then
					return nFaction1 == nMyFaction
				end
				return (p1.nLevel == p2.nLevel) and (nFaction1 < nFaction2) or (p1.nLevel > p2.nLevel)
			end
		end)
	else
		table.sort(tbItem, function (p1, p2)
			if p1 and p2 then
				return p1.nLevel > p2.nLevel
			end
		end)
	end
	local fnSetItem = function (itemObj, nIdx)
		local nBeginIdx = (nIdx - 1) * 3
		for i = 1, 3 do
			local pItem = tbItem[nBeginIdx + i]
			local szItem = "item" .. i
			itemObj.pPanel:SetActive(szItem, pItem and true or false)
			if pItem then
				itemObj[szItem]:SetItem(pItem.dwId)
				if pItem.szClass == tbClassName[DUANPIAN] then
					local nSuitId = pItem.GetIntValue(JueXue.Def.tbDuanpianItemData.nSuitSkillId)
					JueXue:SetDuanpianIcon(itemObj[szItem].pPanel, nSuitId)
				end
				itemObj[szItem].szItemOpt = "ItemBox"
				itemObj[szItem].fnClick = function (itemObj2)
					self:OnClickMiji(itemObj2)
				end
				pItem.nCurEquipAreaId = nil
			end
		end
	end
	local nGridCount = math.ceil(#tbItem/3)
	self.pPanel:SetActive("ScrollViewItemGroup", nGridCount > 0)
	if nGridCount > 0 then
		self.ScrollViewItemGroup:Update(nGridCount, fnSetItem)
	end
	if not bNoUpdateSelectItem and self.nTab ~= self.nCurClickType then
		local nAreaId, nAreaPos
		if self.nTab == 2 then
			nAreaPos = JueXue:FindEmptyMibenPos(me)
		elseif self.nTab == 3 then
			nAreaPos = JueXue:FindEmptyDuanpianPos(me)
		else
			nAreaPos = JueXue:FindEmptyJuexuePos(me)
		end
		if nAreaPos then
			nAreaPos = nAreaPos - Item.EQUIPPOS_JUEXUE_BEGIN + 1
			nAreaId  = math.ceil(nAreaPos/tbDef.nAreaEquipPos)
			nAreaPos = nAreaPos - (nAreaId - 1) * tbDef.nAreaEquipPos
			self:UpdateClickItem(self.nTab, nAreaId, nAreaPos)
		end
	end
end

function tbUi:OnClickMiji(itemObj)
	local nCurType = self.nCurClickType
	if self.nTab == nCurType and self.nCurClickAreaId and self.nCurClickAreaPos then
		local nEquipPos = (self.nCurClickAreaId - 1) * tbDef.nAreaEquipPos + Item.EQUIPPOS_JUEXUE_BEGIN - 1 + self.nCurClickAreaPos
		local pEquip    = me.GetEquipByPos(nEquipPos)
		if pEquip then
			if nCurType == 1 then
				Ui:OpenWindowAtPos("EquipTips", 133, 234, itemObj.nItemId, nil, nil, itemObj.szItemOpt)
				Ui:OpenWindowAtPos("CompareTips", -315, 234, pEquip.dwId, nil, nil)
			elseif nCurType == 2 then
				Ui:OpenWindowAtPos("MibenBookTips", 224, 0, nil, itemObj.nItemId, nil, itemObj.szItemOpt, nEquipPos)
				Ui:OpenWindowAtPos("MibenBookCompareTips", -224, 0, nil, pEquip.dwId)
			elseif nCurType == 3 then
				Ui:OpenWindowAtPos("DuanpianBookTips", 224, 0, nil, itemObj.nItemId, nil, itemObj.szItemOpt, nEquipPos)
				Ui:OpenWindowAtPos("DuanpianBookCompareTips", -224, 0, nil, pEquip.dwId)
			end
			return
		end
		itemObj.nEquipPos = nEquipPos
	end
	Item:ShowItemDetail(itemObj)
end

tbUi.tbOnClick = {}
for i = 1, 3 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		self:ChangeMijiTab(i)
	end
end
for i = 1, 5 do
	tbUi.tbOnClick["BtnQuickexchange" .. i] = function (self)
		self:QuickExchange(i)
	end
end

tbUi.nQuickExchangeItem = 2424
function tbUi:QuickExchange(nArea)
	local nItemCount, tbGetItem = me.GetItemCountInBags(self.nQuickExchangeItem)
	if nItemCount <= 0 or not next(tbGetItem) then
		me.CenterMsg("没有门派信物")
		return
	end
	local tb4Choose = self:GetExchangeList()
	if not next(tb4Choose) then
		me.CenterMsg("没有可兑换的绝学")
		return
	end
	local _, tbInfo = next(tb4Choose)
	if nItemCount < tbInfo.nThisNeedCount then
		me.CenterMsg(string.format("您的门派信物不足%d个", tbInfo.nThisNeedCount))
		return
	end
	self.nWaitExchangeArea = nArea
	Ui:OpenWindow("ItemSelectPanel", self.nQuickExchangeItem, tbGetItem[1].dwId, tb4Choose)
end

function tbUi:GetExchangeList()
	local tbAllCanChoose = Item:GetClass("NeedChooseItem"):Get4ChooseList(self.nQuickExchangeItem)
	local tb4Choose = {}
	for nTemplate, tbInfo in pairs(tbAllCanChoose) do
		if JueXue.tbJuexue[nTemplate] then
			tb4Choose[nTemplate] = tbInfo
		end
	end
	for nPos, nAreaId in pairs(tbDef.tbJuexuePos) do
		local pEquip = me.GetEquipByPos(Item.EQUIPPOS_JUEXUE_BEGIN + nPos - 1)
		if pEquip then
			tb4Choose[pEquip.dwTemplateId] = nil
		end
	end
	return tb4Choose
end

function tbUi:OnSyncItem(nItemId, bNew, nCount)
	if not self.nWaitExchangeArea or
		not JueXue:IsAreaActivate(me, self.nWaitExchangeArea) or
		not bNew then
		return
	end
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem or pItem.szClass ~= "JuexueBook" then
		return
	end
	local nPos   = Item.EQUIPPOS_JUEXUE_BEGIN + (self.nWaitExchangeArea - 1) * tbDef.nAreaEquipPos
	local pEquip = me.GetEquipByPos(nPos)
	if pEquip then
		return
	end
	if not Item:GetClass("JuexueBook"):CheckUseEquip(me, pItem, nPos) then
		return
	end
	RemoteServer.UseEquip(nItemId, nPos)
	self.nWaitExchangeArea = nil
end

function tbUi:OpenAllAttribPanel()
	local tbEquips = {}
	for nPos = Item.EQUIPPOS_JUEXUE_BEGIN, Item.EQUIPPOS_JUEXUE_END do
		local pEquip = me.GetEquipByPos(nPos)
		if pEquip then
			tbEquips[nPos] = pEquip.dwId
		end
	end
	Ui:OpenWindow("ViewRoleJueXueTip", tbEquips)
end