Require("Script/JueXue/JueXueC.lua")
local tbUi      = Ui:CreateClass("MibenBookTips")
tbUi.szNormal   = "MibenBookTips"
tbUi.szCompare  = "MibenBookCompareTips"
tbUi.szTypeName = "秘本"
JueXue:InitTips(tbUi)

function tbUi:UpdateAttribs(pItem, tbIntValue, nTemplateId)
	local tbInfo   = KItem.GetItemBaseProp(self.nTemplateId)
	local szTxtColor = JueXue.Def.tbAttribColor[tbInfo.nQuality]
	local nAdd     = KItem.GetItemExtParam(self.nTemplateId, JueXue.Def.nItemExtAddXiuwei)
	local szAttrib = string.format("[%s]绝学修为  +%d重\n", szTxtColor or "ffffff", nAdd)
	for i = 1, JueXue.Def.nMibenAttNum do
		local nIdx      = 0
		local nValueIdx = 1
		if pItem then
			nIdx = pItem.GetIntValue(JueXue.Def.tbMibenItemData.nAttribIdxBegin + (i - 1) * 2)
			nValueIdx = pItem.GetIntValue(JueXue.Def.tbMibenItemData.nAttribValvePBegin + (i - 1) * 2)
		else
			nIdx = tbIntValue[JueXue.Def.tbMibenItemData.nAttribIdxBegin + (i - 1) * 2] or 0
			nValueIdx = tbIntValue[JueXue.Def.tbMibenItemData.nAttribValvePBegin + (i - 1) * 2] or 0
		end

		local szColor      = JueXue.Def.tbAttribColor[nValueIdx]
		local nPercent     = (JueXue.Def.tbDpAttribPercent[nValueIdx] or {}).nPercent or 0
		local tbAttribInfo = (JueXue.tbAttrib[nIdx] or {})[tbInfo.nLevel]
		if tbAttribInfo then
			local tbValue    = {}
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
			local szEnd = i == JueXue.Def.nMibenAttNum and "" or "\n"
			szAttrib = string.format("%s[%s]%s%s", szAttrib, szTxtColor or "ffffff", szDesc, szEnd)
		
			local _, szValue = FightSkill:GetMagicDescSplit(tbAttribInfo.AttribType, tbSubValue)
			szValue = string.gsub(szValue, "%+%-", "+")
			szValue = string.format("[%s](鉴定 %s)", szColor or "ffffff", szValue)
			
			if tonumber(nPercent) == 0 then
				szValue = ""
			end
			self.pPanel:Label_SetText("Text1" .. i, szValue)
		end
	end
	self.pPanel:Label_SetText("Text", szAttrib)

	local tbLabel = {"Num1", "Num3", "Num4", "Num2"}
	for i = JueXue.Def.tbMibenItemData.nDuanpianAddBegin, JueXue.Def.tbMibenItemData.nDuanpianAddEnd do
		local nValue
		if pItem then
			nValue = pItem.GetIntValue(i)
		else
			nValue = tbIntValue[i] or 0
		end
		self.pPanel:Label_SetText(tbLabel[i - JueXue.Def.tbMibenItemData.nDuanpianAddBegin + 1], string.format("%d%%", nValue))
	end
end

function tbUi:FindEmptyPos()
	return JueXue:FindEmptyMibenPos(me)
end