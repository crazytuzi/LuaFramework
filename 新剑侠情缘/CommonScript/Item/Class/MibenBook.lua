local tbItem = Item:GetClass("MibenBook")

function tbItem:OnCreate(pEquip)
	JueXue:OnMibenItemCreate(pEquip)
end

function tbItem:OnInit(pEquip)
	JueXue:OnInitMiben(pEquip)
end

function tbItem:CheckUseEquip(pPlayer, pEquip, nEquipPos)
	return JueXue:UseEquipComCheck(pPlayer, pEquip, nEquipPos)
end

function tbItem:BeforeUseEquip(pPlayer, pEquip, nEquipPos)
	local pCurEquip = pPlayer.GetEquipByPos(nEquipPos)
	if pCurEquip then
		Item:UnuseEquip(nEquipPos)
	end
end



local tbDef = JueXue.Def
local function fnMathRandom(nMin, nMax)
	local nRand = MathRandom(0, nMax - nMin)
	return nRand + nMin
end

function JueXue:GetRandomAttribIdx(nGroup, tbExclude)
	local tbInfo = self.tbAttribRate[nGroup]
	if not tbInfo then
		return 0
	end
	tbExclude.nRate = tbExclude.nRate or 0
	tbExclude.tbIdx = tbExclude.tbIdx or {}
	local nRand = MathRandom(tbInfo.nTotalRate - tbExclude.nRate)
	for nIdx, nRate in pairs(tbInfo.tbAttrib) do
		if not tbExclude.tbIdx[nIdx] then
			if nRand <= nRate then
				tbExclude.nRate = tbExclude.nRate + nRate
				tbExclude.tbIdx[nIdx] = true
				return nIdx
			end
			nRand = nRand - nRate
		end
	end
	return 0
end

function JueXue:OnMibenItemCreate(pEquip)
	local tbInfo  = self.tbMibenAdd[pEquip.nLevel] or {SumLvMin = 0, SumLvMax = 0, SingleLvMin = 0, SingleLvMax = 0}
	local nAdd    = tbDef.tbMibenItemData.nDuanpianAddEnd - tbDef.tbMibenItemData.nDuanpianAddBegin + 1
	local nTotal  = fnMathRandom(tbInfo.SumLvMin, tbInfo.SumLvMax)
	local tbValue = {}
	for i = 1, nAdd do
		local nMin  = math.max(tbInfo.SingleLvMin, nTotal - tbInfo.SingleLvMax * (nAdd - i))
		local nMax  = math.min(tbInfo.SingleLvMax, nTotal - tbInfo.SingleLvMin * (nAdd - i))
		local nRand = nMax >= nMin and fnMathRandom(nMin, nMax) or 0
		table.insert(tbValue, nRand)
		nTotal = nTotal - nRand
	end
	Lib:SmashTable(tbValue)
	for i = 1, nAdd do
		pEquip.SetIntValue(tbDef.tbMibenItemData.nDuanpianAddBegin + i - 1, tbValue[i] * tbDef.nMibenAddScale)
	end

	local nGroup = KItem.GetItemExtParam(pEquip.dwTemplateId, 1)
	local tbExclude = {}
	for i = 1, tbDef.nMibenAttNum do
		local nIdx      = self:GetRandomAttribIdx(nGroup, tbExclude) or 0
		local nValueIdx = self:GetAttribValueIdx()
		pEquip.SetIntValue(tbDef.tbMibenItemData.nAttribIdxBegin + (i - 1) * 2, nIdx)
		pEquip.SetIntValue(tbDef.tbMibenItemData.nAttribValvePBegin + (i - 1) * 2, nValueIdx)
	end
end

function JueXue:OnInitMiben(pEquip)
	local nLevel = pEquip.nLevel
	for i = 1, tbDef.nMibenAttNum do
		local nIdx      = pEquip.GetIntValue(tbDef.tbMibenItemData.nAttribIdxBegin + (i - 1) * 2)
		local nValueIdx = pEquip.GetIntValue(tbDef.tbMibenItemData.nAttribValvePBegin + (i - 1) * 2)
		local tbInfo    = (self.tbAttrib[nIdx] or {})[nLevel]
		if tbInfo then
			local tbValue = {i, tbInfo.AttribType}
			for i = 1, 3 do
				local nValueMin   = tbInfo.tbValue[i][1]
				local nValueRange = tbInfo.tbValue[i][2]
				local nPercent    = (tbDef.tbDpAttribPercent[nValueIdx] or {}).nPercent or 0
				local nValue      = nValueMin + (nPercent / 100) * nValueRange
				table.insert(tbValue, nValue)
			end
			pEquip.SetRandAttrib(unpack(tbValue))
		end
	end
end

function JueXue:FindEmptyMibenPos(pPlayer)
	for nAreaId, tbInfo in ipairs(tbDef.tbAreaInfo) do
		if self:IsAreaActivate(pPlayer, nAreaId) and not tbInfo.bNotMiben then
			local nMibenPos = Item.EQUIPPOS_JUEXUE_BEGIN + (nAreaId - 1) * tbDef.nAreaEquipPos + tbDef.nMibenEquipPos - 1
			if not pPlayer.GetEquipByPos(nMibenPos) then
				return nMibenPos
			end
		end
	end
end