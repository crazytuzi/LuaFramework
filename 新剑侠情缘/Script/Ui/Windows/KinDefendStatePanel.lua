local tbUi = Ui:CreateClass("KinDefendStatePanel")
tbUi.tbOnClick = {
	BtnClose = function(self)
		self:SwitchPanel(false)
	end,

	BtnInfo = function(self)
		self:SwitchPanel()
	end,
}

function tbUi:SwitchPanel(bForce)
	local bCurShow = not bForce
	if bForce == nil then
		bCurShow = self.pPanel:IsActive("BtnClose")
	end

	if not bCurShow then
		Fuben.KinDefendMgr:SyncState()
		self:Refresh()
	end

	self.pPanel:SetActive("BtnClose", not bCurShow)
	self.pPanel:SetActive("Panel", not bCurShow)
end

function tbUi:OnOpen()
	self:SwitchPanel(false)
	self:Refresh()
end

function tbUi:Refresh()
	local tbData = Fuben.KinDefendMgr.tbStateData or {}
	for i = 1, 4 do
		local szBoss, szPlayer = "空", ""
		self.pPanel:SetActive("BossHP"..i, false)
		local tbArea = tbData[i]
		if tbArea then
			local tbBoss = tbArea.tbBoss
			if tbBoss then
				self.pPanel:SetActive("BossHP"..i, not tbBoss.bDead)
				if tbBoss.bDead then
					szBoss = string.format("%s：\n已死亡", tbBoss.szName)
				else
					szBoss = string.format("%s：", tbBoss.szName)
					if tbBoss.nInc > 0 then
						szBoss = string.format("%s\n狂怒·%s", szBoss, Lib:Transfer4LenDigit2CnNum(tbBoss.nInc))
					end
					local nHpCur, nHpMax = unpack(tbBoss.tbHp or {0, math.huge})
					self.pPanel:Label_SetText("HPTxt"..i, string.format("%.1f%%", nHpCur / nHpMax * 100))
					local nPercent = math.min(1, math.max(0, nHpCur / nHpMax))
					self.pPanel:Sprite_SetFillPercent("BossHP"..i, nPercent)
				end
			end

			local tbPlayer = tbArea.tbPlayer
			if tbPlayer then
				szPlayer = string.format("%s：\n光遁术 %s\n回春术 %s", tbPlayer.szName, tbPlayer.nGod, tbPlayer.nHeal)
			end
		end
		self.pPanel:Label_SetText("Boss"..i, szBoss)
		self.pPanel:Label_SetText("Player"..i, szPlayer)
	end
end
