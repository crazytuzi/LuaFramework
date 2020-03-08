local tbItem = Item:GetClass("DuanpianBook")

function tbItem:OnCreate(pEquip)
	JueXue:OnDuanpianItemCreate(pEquip)
end

function tbItem:OnInit(pEquip)
	JueXue:OnInitDuanpian(pEquip)
end

function tbItem:CheckUseEquip(pPlayer, pEquip, nEquipPos)
	return JueXue:UseEquipComCheck(pPlayer, pEquip, nEquipPos)
end

function tbItem:BeforeUseEquip(pPlayer, pEquip, nEquipPos)
	JueXue:RefreshDainpianAttrib(pPlayer, pEquip, nEquipPos)
end




local tbDef = JueXue.Def
function JueXue:OnDuanpianItemCreate(pEquip)
	pEquip.SetIntValue(tbDef.tbDuanpianItemData.nMibenAdd, 0)
	local nSuitId = KItem.GetItemExtParam(pEquip.dwTemplateId, tbDef.nItemExtFixSuitId)
	if nSuitId == 0 and Item:GetQuality(pEquip.dwTemplateId) > 1 then
		for nSuit, tbInfo in pairs(self.tbSuitAttrib) do
			if tbInfo.nRate >= MathRandom(tbDef.nDpSkillRate) then
				nSuitId = nSuit
				break
			end
		end
	end
	pEquip.SetIntValue(tbDef.tbDuanpianItemData.nSuitSkillId, nSuitId)

	local nGroup = KItem.GetItemExtParam(pEquip.dwTemplateId, tbDef.nItemExtAttribGroup)
	local tbExclude = {}
	for i = 1, tbDef.nDuanpianAttNum do
		local nIdx      = self:GetRandomAttribIdx(nGroup, tbExclude) or 0
		local nValueIdx = self:GetAttribValueIdx()
		pEquip.SetIntValue(tbDef.tbDuanpianItemData.nAttribIdxBegin + (i - 1) * 2, nIdx)
		pEquip.SetIntValue(tbDef.tbDuanpianItemData.nAttribValvePBegin + (i - 1) * 2, nValueIdx)
	end
end

function JueXue:OnInitDuanpian(pEquip)
	local nLevel    = pEquip.nLevel
	local nMibenAdd = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nMibenAdd)
	for i = 1, tbDef.nDuanpianAttNum do
		local nIdx      = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nAttribIdxBegin + (i - 1) * 2)
		local nValueIdx = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nAttribValvePBegin + (i - 1) * 2)
		local tbInfo    = (self.tbAttrib[nIdx] or {})[nLevel]
		if tbInfo then
			local tbValue = {i, tbInfo.AttribType}
			for j = 1, 3 do
				local nValueMin   = tbInfo.tbValue[j][1]
				local nValueRange = tbInfo.tbValue[j][2]
				local nPercent    = (tbDef.tbDpAttribPercent[nValueIdx] or {}).nPercent or 0
				local nValue      = nValueMin + ((nPercent + nMibenAdd) / 100) * nValueRange
				table.insert(tbValue, nValue)
			end
			pEquip.SetRandAttrib(unpack(tbValue))
		end
	end
end

function JueXue:GetMibenAdd(nDuanpianPos)
	if not self.tbMibenAddPos then
		self.tbMibenAddPos = {}
		for nMibenPos, tbInfo in pairs(tbDef.tbDpAroundMiben) do
			for nIdx, nDpPos in ipairs(tbInfo) do
				self.tbMibenAddPos[nDpPos] = self.tbMibenAddPos[nDpPos] or {}
				table.insert(self.tbMibenAddPos[nDpPos], {nMibenPos, nIdx})
			end
		end
	end
	return self.tbMibenAddPos[nDuanpianPos] or {}
end

function JueXue:RefreshDainpianAttrib(pPlayer, pDuanpian, nEquipPos)
	local nPos = self:TransforEquipPos(nEquipPos)
	if not nPos then
		return
	end

	local tbMiben = self:GetMibenAdd(nPos)
	local nAdd = 0
	for _, tb in pairs(tbMiben) do
		local nMbPos = tb[1] + Item.EQUIPPOS_JUEXUE_BEGIN - 1
		local pMiben = pPlayer.GetEquipByPos(nMbPos)
		if pMiben then
			nAdd = nAdd + pMiben.GetIntValue(tbDef.tbMibenItemData.nDuanpianAddBegin + tb[2] - 1)
		end
	end

	if nAdd == pDuanpian.GetIntValue(tbDef.tbDuanpianItemData.nMibenAdd) then
		return
	end

	pDuanpian.SetIntValue(tbDef.tbDuanpianItemData.nMibenAdd, nAdd)
	pDuanpian.ReInit()
end

function JueXue:FindEmptyDuanpianPos(pPlayer)
	for nAreaId, tbInfo in ipairs(tbDef.tbAreaInfo) do
		if self:IsAreaActivate(pPlayer, nAreaId) then
			local nPosBegin = Item.EQUIPPOS_JUEXUE_BEGIN + (nAreaId - 1) * tbDef.nAreaEquipPos - 1
			local nDpBegin  = tbInfo.bNotMiben and tbDef.nMibenEquipPos or tbDef.nDuanPianEquipStartPos
			for i = nDpBegin, tbDef.nAreaEquipPos do
				local nPos = nPosBegin + i
				if nPos > Item.EQUIPPOS_JUEXUE_END then
					break
				end
				if not pPlayer.GetEquipByPos(nPos) then
					return nPos
				end
			end
		end
	end
end