local tbDef = JueXue.Def
function JueXue:GetPosType(nPos)
	local nTruePos = nPos - Item.EQUIPPOS_JUEXUE_BEGIN + 1
	local nAreaId  = math.ceil(nTruePos / tbDef.nAreaEquipPos)
	local nAreaPos = nTruePos - (nAreaId - 1) * tbDef.nAreaEquipPos
	local nType    = Item.EQUIP_DUANPIAN_BOOK
	if nAreaPos == 1 then
		nType = Item.EQUIP_JUEXUE_BOOK
	elseif nAreaPos == 2 then
		if tbDef.tbAreaInfo[nAreaId] and not tbDef.tbAreaInfo[nAreaId].bNotMiben then
			nType = Item.EQUIP_MIBEN_BOOK
		end
	end
	return nType
end

function JueXue:RegisterItemType2Pos()
	for nPos = Item.EQUIPPOS_JUEXUE_BEGIN, Item.EQUIPPOS_JUEXUE_END do
		local nType = self:GetPosType(nPos)
		KItem.RegisterItemType2Pos(nType, nPos)
	end
end

function JueXue:GetAreaDataBegin(nAreaId)
	return (nAreaId - 1) * tbDef.nAreaInterval
end

function JueXue:IsAreaActivate(pPlayer, nAreaId)
	local nSaveKey = self:GetAreaDataBegin(nAreaId) + tbDef.nActivateFlag
	return pPlayer.GetUserValue(tbDef.nDataGroup, nSaveKey) > 0
end

function JueXue:GetItemActivateAreaId(nType)
	if not self.tbItemActivateAreaId then
		self.tbItemActivateAreaId = {}
		for nAreaId, tbInfo in pairs(tbDef.tbAreaInfo) do
			if tbInfo.nBookType then
				self.tbItemActivateAreaId[tbInfo.nBookType] = nAreaId
			end
		end
	end
	return self.tbItemActivateAreaId[nType]
end

function JueXue:GetBookActivateArea(nBookTemplateId)
	local nType = Item:GetClass("SkillBook"):GetBookType(nBookTemplateId)
	if not nType then
		return false, "此秘籍无法激活任何区域"
	end

	local nAreaId = self:GetItemActivateAreaId(nType)
	if not nAreaId then
		return false, "此秘籍无法激活该区域"
	end
	return true, "", nAreaId
end

function JueXue:CheckCanActivateArea(pPlayer, item)
	local pEquip = item
	if type(item) == "number" then
		pEquip = pPlayer.GetItemInBag(item)
	end
	if not pEquip then
		return false, "没找到该道具"
	end

	local bRet, szMsg, nAreaId = self:GetBookActivateArea(pEquip.dwTemplateId)
	if not bRet then
		return false, szMsg
	end

	if self:IsAreaActivate(pPlayer, nAreaId) then
		return false, "区域已激活"
	end

	local tbInfo = tbDef.tbAreaInfo[nAreaId] or {}
	if not Lib:IsEmptyStr(tbInfo.szTimeFrame) and GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
		return false, "时间轴未到"
	end

	for _, nPreArea in pairs(tbDef.tbAreaInfo.tbChildArea or {}) do
		if not self:IsAreaActivate(pPlayer, nPreArea) then
			return false, "有前置区域尚未激活"
		end
	end

	if not Item:GetClass("SkillBook"):IsFactionBookMaxLevel(pEquip, pPlayer.nFaction) then
		return false, "秘籍尚未达到最大等级"
	end

	local nCount = pPlayer.GetItemCountInAllPos(tbDef.nActivateTemplateId)
	if nCount < tbDef.nActivateConsume then
		return false, "门派信物数量不足"..tbDef.nActivateConsume
	end

	return true, "", nAreaId
end

function JueXue:GetCurXiuLianLv(pPlayer, nAreaId)
	local nSaveKey = self:GetAreaDataBegin(nAreaId) + tbDef.nXiuLianLv
	local nLevel   = pPlayer.GetUserValue(tbDef.nDataGroup, nSaveKey)
	return nLevel
end

function JueXue:GetXiulianConsume(nLevel)
	local tbInfo = self.tbXiuLianExp[nLevel] or {}
	return tbInfo[1] > 0 and tbInfo[1]
end

function JueXue:GetXiulianFightPower(nLevel)
	local tbInfo = self.tbXiuLianExp[nLevel] or {}
	return tbInfo[2] or 0
end

function JueXue:CheckCanXiuLian(pPlayer, nAreaId, bCheckNoConsume)
	if not self:IsAreaActivate(pPlayer, nAreaId) then
		return false, "未激活"
	end

	local nLevel     = self:GetCurXiuLianLv(pPlayer, nAreaId)
	local nNeedMoney = self:GetXiulianConsume(nLevel)
	if not nNeedMoney then
		return false, "当前绝学位已满级"
	end
	if MODULE_GAMESERVER or bCheckNoConsume then
		local nBookExp = pPlayer.GetMoney(tbDef.szMoneyType)
		if nBookExp < nNeedMoney then
			local szMsg = "当前没有足够的修为以及修为书！"
			if bCheckXiuWei then
				return szMsg
			end
			local bAutoRet, szConsumeMsg = Item:GetClass("SkillBook"):AutCostXiuWeiBook(pPlayer)
			return false, szMsg .. szConsumeMsg
		end
	end
	return true, "", nNeedMoney
end

function JueXue:GetPosAroundSuitLen(pPlayer, nAreaId, nPos, nSuitId)
	local nLen = 1
	local nPosInArea = nPos - (nAreaId - 1) * tbDef.nAreaEquipPos
	for i = nPosInArea + 1, tbDef.nAreaEquipPos do
		local nPosSuit = pPlayer.tbDuanpianEquipPos[nPos + i - nPosInArea]
		if not nPosSuit or nPosSuit ~= nSuitId then
			break
		end
		nLen = nLen + 1
	end
	for i = nPosInArea - 1, tbDef.nDuanPianEquipStartPos, -1 do
		local nPosSuit = pPlayer.tbDuanpianEquipPos[nPos + i - nPosInArea]
		if not nPosSuit or nPosSuit ~= nSuitId then
			break
		end
		nLen = nLen + 1
	end
	return nLen
end

function JueXue:TransforEquipPos(nEquipPos)
	local nPos = nEquipPos - Item.EQUIPPOS_JUEXUE_BEGIN + 1
	local nPosCount = Item.EQUIPPOS_JUEXUE_END - Item.EQUIPPOS_JUEXUE_BEGIN + 1
	if nPos <= 0 or nPos > nPosCount then
		return
	end
	return nPos
end

function JueXue:OnLogin(pPlayer)
	if MODULE_GAMESERVER then
		local nArea1BeginPos = Item.EQUIPPOS_JUEXUE_BEGIN - 1
		for _, nPos in pairs({nArea1BeginPos + tbDef.nDuanPianEquipStartPos, nArea1BeginPos + tbDef.nAreaEquipPos}) do
			local pDp = pPlayer.GetEquipByPos(nPos)
			if pDp then
				JueXue:RefreshDainpianAttrib(pPlayer, pDp, nPos)
			end
		end
	end

	pPlayer.tbDuanpianEquipPos   = {}
	pPlayer.tbDuanpianCurSkillLv = {}
	local nCurSuitId   = 0
	local nCurSuitLen  = 0
	local tbSuitMaxLen = {}
	local function fnBreakSuit(nSuitId)
		if nCurSuitId > 0 and nCurSuitLen > 0 then
			if not tbSuitMaxLen[nCurSuitId] or nCurSuitLen > tbSuitMaxLen[nCurSuitId] then
				tbSuitMaxLen[nCurSuitId] = nCurSuitLen
			end
		end
		nCurSuitId = nSuitId
		nCurSuitLen = 0
	end
	for nAreaId, tbInfo in pairs(tbDef.tbAreaInfo) do
		if tbInfo.bSuit and self:IsAreaActivate(pPlayer, nAreaId) then
			local nBeginPos = (nAreaId - 1) * tbDef.nAreaEquipPos + Item.EQUIPPOS_JUEXUE_BEGIN - 1
			for i = tbDef.nDuanPianEquipStartPos, tbDef.nAreaEquipPos do
				local pEquip = pPlayer.GetEquipByPos(nBeginPos + i)
				if pEquip then
					local nSuitId = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nSuitSkillId)
					if nSuitId > 0 then
						pPlayer.tbDuanpianEquipPos[(nAreaId - 1) * tbDef.nAreaEquipPos + i] = nSuitId
						if nCurSuitId == nSuitId then
							nCurSuitLen = nCurSuitLen + 1
						else
							fnBreakSuit(nSuitId)
							nCurSuitLen = 1
						end
					else
						fnBreakSuit(0)
					end
				else
					fnBreakSuit(0)
				end
			end
			fnBreakSuit(0)
		end
	end
	for nSuitId, nLen in pairs(tbSuitMaxLen) do
		local nLevel, nExternGroup = self:GetDuanpianSkillLv(nSuitId, nLen)
		if nLevel > 0 then
			pPlayer.tbDuanpianCurSkillLv[nSuitId] = nLevel
			pPlayer.ApplyExternAttrib(nExternGroup, nLevel)
			local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
			if pAsyncData then
				pAsyncData.SetJuexueSuit(nSuitId, nLevel)
			end
		end
	end
end

function JueXue:GetAttribValueIdx()
	if not self.nAttribTotalRate then
		self.nAttribTotalRate = 0
		for _, tbInfo in pairs(tbDef.tbDpAttribPercent) do
			self.nAttribTotalRate = self.nAttribTotalRate + tbInfo.nRate
		end
	end
	local nRan = MathRandom(self.nAttribTotalRate)
	for nIdx, tbInfo in pairs(tbDef.tbDpAttribPercent) do
		if tbInfo.nRate >= nRan then
			return nIdx
		end
		nRan = nRan - tbInfo.nRate
	end
	return 1
end

function JueXue:GetDuanpianSkillLv(nSuitId, nLen)
	local tbInfo = self.tbSuitAttrib[nSuitId]
	if not tbInfo then
		return 0
	end
	local nLevel = 0
	for nLv, nCount in ipairs(tbInfo.tbCount2SkillLv) do
		if nLen >= nCount then
			nLevel = nLv
		else
			break
		end
	end
	return nLevel, tbInfo.nExternGroup
end

function JueXue:GetAreaId(nEquipPos)
	nEquipPos = nEquipPos - Item.EQUIPPOS_JUEXUE_BEGIN + 1
	return math.ceil(nEquipPos/self.Def.nAreaEquipPos)
end

function JueXue:UseEquipComCheck(pPlayer, pEquip, nEquipPos)
	local nAreaId = JueXue:GetAreaId(nEquipPos)
	if not nAreaId then
		return false, "不能装备到该位置"
	end

	if not JueXue:IsAreaActivate(pPlayer, nAreaId) then
		return false, "该区域尚未激活"
	end

	if JueXue:GetPosType(nEquipPos) ~= pEquip.nItemType then
		return false, "不能装备到该位置"
	end
	return true
end

function JueXue:UpdateAsyncPlayerSuit(pPlayerAsync, pNpc)
	for nSuitId, tbInfo in pairs(self.tbSuitAttrib) do
		local nLevel = pPlayerAsync.GetJuexueSuit(nSuitId)
		if nLevel and nLevel > 0 then
			Log("JueXue UpdateAsyncPlayerSuit", pPlayerAsync.dwID, tbInfo.nExternGroup, nLevel)
			pNpc.ApplyExternAttrib(tbInfo.nExternGroup, nLevel)
		end
	end
end

function JueXue:GetJueXueCount(pPlayer)
    local tbItemList = pPlayer.GetItemListInBag()
    local nCurCount = 0
    for _, pItem in ipairs(tbItemList) do
        if pItem.szClass == "MibenBook" or pItem.szClass == "JuexueBook" or pItem.szClass == "DuanpianBook" then
            nCurCount = nCurCount + pItem.nCount
        end
    end
    return nCurCount
end

function JueXue:GetFreeBagCount(pPlayer)
    local nCurCount = self:GetJueXueCount(pPlayer)
    return GameSetting.MAX_COUNT_JUEXUE - nCurCount, "绝学空间不足！"
end
