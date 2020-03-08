Require("Script/JueXue/JueXueC.lua")
local tbUi      = Ui:CreateClass("DuanpianBookTips")
tbUi.szNormal   = "DuanpianBookTips"
tbUi.szCompare  = "DuanpianBookCompareTips"
tbUi.szTypeName = "断篇"
JueXue:InitTips(tbUi)

function tbUi:UpdateAttribs(pItem, tbIntValue, nTemplateId)
	local tbInfo     = KItem.GetItemBaseProp(self.nTemplateId)
	local nAdd       = KItem.GetItemExtParam(self.nTemplateId, JueXue.Def.nItemExtAddXiuwei)
	local szTxtColor = JueXue.Def.tbAttribColor[tbInfo.nQuality]

	local szAttrib   = string.format("[%s]绝学修为  +%d重\n", szTxtColor, nAdd)
	local tbMibenAdd = {}
	for i = 1, JueXue.Def.nDuanpianAttNum do
		local nIdx      = 0
		local nValueIdx = 1
		local nMibenAdd = 0
		if pItem then
			nIdx      = pItem.GetIntValue(JueXue.Def.tbDuanpianItemData.nAttribIdxBegin + (i - 1) * 2)
			nValueIdx = pItem.GetIntValue(JueXue.Def.tbDuanpianItemData.nAttribValvePBegin + (i - 1) * 2)
			nMibenAdd = pItem.GetIntValue(JueXue.Def.tbDuanpianItemData.nMibenAdd)
		else
			nIdx      = tbIntValue[JueXue.Def.tbDuanpianItemData.nAttribIdxBegin + (i - 1) * 2] or 0
			nValueIdx = tbIntValue[JueXue.Def.tbDuanpianItemData.nAttribValvePBegin + (i - 1) * 2] or 0
		end

		local szColor      = JueXue.Def.tbAttribColor[nValueIdx]
		local nPercent     = (JueXue.Def.tbDpAttribPercent[nValueIdx] or {}).nPercent or 0
		local tbAttribInfo = (JueXue.tbAttrib[nIdx] or {})[tbInfo.nLevel]
		nPercent = nPercent + nMibenAdd
		local szEx = ""
		if tbAttribInfo then
			local tbValue = {}
			local tbSubValue = {}
			for j = 1, 3 do
				local nValueMin   = tbAttribInfo.tbValue[j][1]
				tbValue[j] = nValueMin
				local nValueRange = tbAttribInfo.tbValue[j][2]
				local nValue      = (nPercent / 100) * nValueRange
				nValue = math.floor(nValue)
				tbSubValue[j] = nValue
			end
			local szDesc = FightSkill:GetMagicDesc(tbAttribInfo.AttribType, tbValue)
			local szEnd = i == JueXue.Def.nDuanpianAttNum and "" or "\n"
			szAttrib = string.format("%s[%s]%s%s", szAttrib, szTxtColor or "ffffff", szDesc, szEnd)
			
			if nPercent~=0 then
				local _, szValue = FightSkill:GetMagicDescSplit(tbAttribInfo.AttribType, tbSubValue)
				local szSymbol = nPercent >= 0 and "+" or "-"
				szEx = string.gsub(szValue, "%+%-", szSymbol)
				szEx = string.format("[%s](鉴定 %s%s)", szColor or "ffffff", nMibenAdd ~= 0 and "" or "", szEx)
			end
		end
		self.pPanel:Label_SetText("Text1" .. i, szEx)
	end
	self.pPanel:Label_SetText("Text1", szAttrib)

	local nSuitId
	if pItem then
		nSuitId = pItem.GetIntValue(JueXue.Def.tbDuanpianItemData.nSuitSkillId)
	else
		nSuitId = tbIntValue[JueXue.Def.tbDuanpianItemData.nSuitSkillId] or 0
	end
	JueXue:SetDuanpianIcon(self.pPanel, nSuitId)
	self.pPanel:SetActive("TxtClass", nSuitId > 0)
	local szAttribs = ""
	if nSuitId > 0 then
		local tbSuitInfo = JueXue.tbSuitAttrib[nSuitId]
		local nCurLen    = 1
		if pItem and pItem.nPos ~= Item.emITEMPOS_BAG then
			local nPos = JueXue:TransforEquipPos(pItem.nPos)
			if nPos then
				local nAreaId = math.ceil(nPos/JueXue.Def.nAreaEquipPos)
				nCurLen = JueXue:GetPosAroundSuitLen(me, nAreaId, nPos, nSuitId)
			end
		end
		local szText = string.format("套装：%s (%d/%d)", tbSuitInfo.szSuitName, nCurLen, tbSuitInfo.nMaxLen)
		self.pPanel:Label_SetText("TxtClass", szText)

		local tbAttribs = {}
		for nLv, nLen in ipairs(tbSuitInfo.tbCount2SkillLv) do
			--这里只支持每个等级多一个属性
			local tbExtAttrib = KItem.GetExternAttrib(tbSuitInfo.nExternGroup, nLv) or {}
			local tbAttInfo   = tbExtAttrib[nLv]
			local szDesc      = FightSkill:GetMagicDesc(tbAttInfo.szAttribName, tbAttInfo.tbValue) or ""
			local szColor     = nCurLen >= nLen and "[3eee01]" or "[848484]"
			szDesc = string.format("%s(%d件)  %s", szColor, nLen, szDesc)
			table.insert(tbAttribs, szDesc)
		end
		szAttribs = table.concat(tbAttribs, "\n")
	end
	self.pPanel:Label_SetText("Text2", szAttribs)
	self.pPanel:Label_SetText("Text3", nSuitId > 0 and "[73cbd5]<断篇套装必须装备在相邻位置才能激活>[-]" or "")
end

function tbUi:FindEmptyPos()
	return JueXue:FindEmptyDuanpianPos(me)
end