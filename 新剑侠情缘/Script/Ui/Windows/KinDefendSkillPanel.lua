local tbUi = Ui:CreateClass("KinDefendSkillPanel")
tbUi.tbOnClick = {
	Skill1 = function(self)
		self:StartBtnEffect("Skill1")
		if (self.nGod or 0) <= 0 then
			me.CenterMsg("技能次数不足")
			return
		end
		Fuben.KinDefendMgr:UseGodSkill()
	end,

	Skill2 = function(self)
		self:StartBtnEffect("Skill2")
		if (self.nHeal or 0) <= 0 then
			me.CenterMsg("技能次数不足")
			return
		end
		Fuben.KinDefendMgr:UseHealSkill()
	end,
}

tbUi.tbOnLongPress = {
	Skill1 = function(self)
	 	local WorldPos = self.pPanel:GetWorldPosition("Skill1")
	 	local nSkillId, nSkillLevel = unpack(Fuben.KinDefendMgr.Def.tbGoldSkill)
        self:ShowSkillInfo(nSkillId, nSkillLevel, {WorldPos.x, WorldPos.y, 50, 120})
	end,

	Skill2 = function(self)
		local WorldPos = self.pPanel:GetWorldPosition("Skill1")
		local nSkillId, nSkillLevel = unpack(Fuben.KinDefendMgr.Def.tbHealSkill)
        self:ShowSkillInfo(nSkillId, nSkillLevel, {WorldPos.x, WorldPos.y, 50, 120})
	end,
}

function tbUi:OnOpen(nGodSub, nHealSub)
	self:Refresh(nGodSub, nHealSub)
end

function tbUi:Refresh(nGodSub, nHealSub)
	self.nGod = math.floor(nGodSub / Fuben.KinDefendMgr.Def.nKillCountPerGodSkill)
	self.nHeal = math.floor(nHealSub / Fuben.KinDefendMgr.Def.nPickCountPerHealSkill)

	self.pPanel:Label_SetText("Skill1Time", self.nGod)
	self.pPanel:Label_SetText("Skill2Time", self.nHeal)
	self.pPanel:ChangeRotate("Line12", -(nGodSub / Fuben.KinDefendMgr.Def.nKillCountPerGodSkill) * 360)
	self.pPanel:ChangeRotate("Line22", -(nHealSub / Fuben.KinDefendMgr.Def.nPickCountPerHealSkill) * 360)

	self.pPanel:SetActive("SkillUnavailable1", self.nGod <= 0)
	self.pPanel:SetActive("SkillUnavailable2", self.nHeal <= 0)
end

function tbUi:ShowSkillInfo(nSkillId, nSkillLevel, tbWorldPos)
	local tbSkillShowInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel)
    tbSkillShowInfo.bMax = false
    tbSkillShowInfo.bNotNextInfo = true
    tbSkillShowInfo.nLevel = nSkillLevel
    tbSkillShowInfo.nExtLevel = 0
    tbSkillShowInfo.nMaxLevel = nSkillLevel
    Ui:OpenWindow("SkillShow", tbSkillShowInfo, tbWorldPos)
end

tbUi.tbAttackEffect =
{
    ["Skill1"] = "texiao1",
    ["Skill2"] = "texiao2",
}

tbUi.tbColseTimerAttack = tbUi.tbColseTimerAttack or {}
tbUi.tbOpenTimerAttack = tbUi.tbOpenTimerAttack or {}

function tbUi:StartBtnEffect(szBtnName)
    local szEffectName = self.tbAttackEffect[szBtnName]
    self:CloseAttackTimer(szEffectName)
    self.pPanel:SetActive(szEffectName, false)
    self.tbOpenTimerAttack[szEffectName] = Timer:Register(1, self.OpenActiveEffect, self, szEffectName)
end

function tbUi:OpenActiveEffect(szName)
    self.pPanel:SetActive(szName, true)
    self.tbOpenTimerAttack[szName] = nil
    self:CloseAttackTimer(szName)
    self.tbColseTimerAttack[szName] = Timer:Register(Env.GAME_FPS * 2, self.CloseActiveEffect, self, szName)
end

function tbUi:CloseActiveEffect(szName)
    self.pPanel:SetActive(szName, false)
    self.tbColseTimerAttack[szName] = nil
    self:CloseAttackTimer(szName)
end

function tbUi:CloseAttackTimer(szName)
    if self.tbColseTimerAttack[szName] then
        Timer:Close(self.tbColseTimerAttack[szName])
        self.tbColseTimerAttack[szName] = nil
    end

    if self.tbOpenTimerAttack[szName] then
        Timer:Close(self.tbOpenTimerAttack[szName])
        self.tbOpenTimerAttack[szName] = nil
   end
end
