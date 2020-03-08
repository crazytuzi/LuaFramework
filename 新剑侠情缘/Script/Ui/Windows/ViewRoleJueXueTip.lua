local tbUi = Ui:CreateClass("ViewRoleJueXueTip")
tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end
}
tbUi.tbHeight = {35, 63, 91, 120}
function tbUi:OnOpen(tbEquip)
	local tbAllAttrib = JueXue:GetAllAttrib(tbEquip)
	local fnSkillIcon = function (tbSkillItem)
		local tbSkillInfo = FightSkill:GetSkillShowTipInfo(unpack(tbSkillItem.tbSkillInfo))
		Ui:OpenWindow("SkillShow", tbSkillInfo)
	end
	for i = 1, 5 do
		local nSkillId, nLevel = next(tbAllAttrib.tbSkill)
		self.pPanel:SetActive("Skill" .. i, nSkillId or false)
		if nSkillId then
			tbAllAttrib.tbSkill[nSkillId] = nil
			local nMaxLevel = JueXue:GetXiuLianSkillMaxLv()
			local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nLevel, nMaxLevel)
			self.pPanel:Sprite_SetSprite("Skill" .. i, tbSubInfo.szIcon, tbSubInfo.szIconAltlas)
			self["Skill" .. i].pPanel:Label_SetText("Level" .. i, nLevel)
			self["Skill" .. i].tbSkillInfo = {nSkillId, nLevel, nMaxLevel}
			self["Skill" .. i].pPanel.OnTouchEvent = fnSkillIcon
		end
	end

	local fnSuit = function (tbSuitItem)
		local tbSuit     = tbSuitItem.tbSuit
		local tbSuitInfo = JueXue.tbSuitAttrib[tbSuit[1]]
		local szAttribs  = ""
		local tbAttribs  = {}
		for nLv, nLen in ipairs(tbSuitInfo.tbCount2SkillLv) do
			local tbExtAttrib = KItem.GetExternAttrib(tbSuitInfo.nExternGroup, nLv) or {}
			local tbAttInfo   = tbExtAttrib[nLv]
			local szDesc      = FightSkill:GetMagicDesc(tbAttInfo.szAttribName, tbAttInfo.tbValue) or ""
			local szColor     = tbSuit[2] >= nLen and "[3eee01]" or "[848484]"
			szDesc = string.format("%s(%d件)  %s", szColor, nLen, szDesc)
			table.insert(tbAttribs, szDesc)
		end
		szAttribs = table.concat(tbAttribs, "\n")
		Ui:OpenWindow("TxtTipPanel", szAttribs)
	end
	for i = 1, 8 do
		local tbSuit = tbAllAttrib.tbSuit[i]
		self.pPanel:SetActive("SuitName" .. i, tbSuit or false)
		if tbSuit then
			local tbSuitInfo = JueXue.tbSuitAttrib[tbSuit[1]]
			local szSuit = string.format("[3eee01]%s (%d/%d)", tbSuitInfo.szSuitName, tbSuit[2], tbSuitInfo.nMaxLen)
			self.pPanel:Label_SetText("SuitName" .. i, szSuit)
			self["SuitName" .. i].tbSuit = tbSuit
			self["SuitName" .. i].pPanel.OnTouchEvent = fnSuit
		end
	end
	local nLine   = math.ceil(#tbAllAttrib.tbSuit / 2)
	local nHeight = self.tbHeight[nLine] or 0
	self.pPanel:Widget_SetSize("Bg_Suit", 380, nHeight)

	self.pPanel:Label_SetText("Attribute", tbAllAttrib.szAttrib)
	local tbTextSize = self.pPanel:Label_GetPrintSize("Attribute")
	self.pPanel:Widget_SetSize("datagroup", 380, 144 + nHeight + tbTextSize.y)
	self.pPanel:UpdateDragScrollView("datagroup")
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME)
end