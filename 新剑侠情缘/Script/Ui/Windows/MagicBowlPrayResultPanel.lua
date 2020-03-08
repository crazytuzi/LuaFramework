local tbUi = Ui:CreateClass("MagicBowlPrayResultPanel")

tbUi.tbOnClick = {
	BtnCancel = function(self)
		House:MagicBowlConfirmPrayResult(false)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnChange = function(self)
		House:MagicBowlConfirmPrayResult(true)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen(tbPrayIdxs)
	self.tbPrayIdxs = tbPrayIdxs
	self:UpdateAttr()
end

function tbUi:UpdateAttr()
	local tbData = House:GetMagicBowlData(me.dwID)
	if not tbData then
		return
	end

	local nMaxAttrCount = Furniture.MagicBowl:GetMaxAttrCount(me.dwID)
	for i=1, 8 do
		local bValid = i<=nMaxAttrCount
		if bValid then
			local szKey1, szKey2 = string.format("Attribute1%d", i), string.format("Attribute2%d", i)
			local szValue1, szValue2 = "", ""
			local nSaveData = tbData.tbAttrs[i]
			local nAttribLevel1, nAttribLevel2 = 0, 0
			if nSaveData then
				szValue1, nAttribLevel1 = self:GetPrayDesc(nSaveData, tbData.tbPray.tbIdxs[i])
				szValue2, nAttribLevel2 = self:GetPrayDesc(nSaveData, self.tbPrayIdxs[i])
			end
			self.pPanel:Label_SetText(szKey1, szValue1)
			local szColor  = Item:GetQualityColor(nAttribLevel1)
			self.pPanel:Label_SetColorByName(szKey1, szColor or "White")

			self.pPanel:Label_SetText(szKey2, szValue2)
			local szPrayColor  = Item:GetQualityColor(nAttribLevel2)
			self.pPanel:Label_SetColorByName(szKey2, szPrayColor or "White")
		end
		self.pPanel:SetActive("Attribute1"..i, bValid)
		self.pPanel:SetActive("Attribute2"..i, bValid)
	end
end

function tbUi:GetPrayDesc(nSaveData, nIdx)
	local _, szDesc, nQuility = unpack(Furniture.MagicBowl.Def.tbPrayPercentDesc[nIdx])
	local _, tbMa = Furniture.MagicBowl:GetPrayValue(nSaveData, nIdx)
	local nAttribId = Item.tbRefinement:SaveDataToAttrib(nSaveData)
	local szType = Item.tbRefinement:AttribIdToChar(nAttribId)
	local szBuff = FightSkill:GetMagicDesc(szType, tbMa)
	return string.format("%s（%s）", szBuff, szDesc), nQuility
end
