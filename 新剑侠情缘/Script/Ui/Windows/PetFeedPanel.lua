local tbUi = Ui:CreateClass("PetFeedPanel")
tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	Btn1 = function(self)
		Pet:Feed(1)
	end,
	Btn2 = function(self)
		Pet:Feed(2)
	end,
}

function tbUi:OnOpen(tbPets)
	self.tbPets = tbPets
	self:Refresh()
end

function tbUi:Refresh()
	for i=1, 2 do
		self.pPanel:Label_SetText("Label"..i, Pet.Def.FeedCfg[i].szName)
		self.pPanel:Label_SetText("TxtCost"..i, Pet.Def.FeedCfg[i].nPrice)
		if Pet.Def.FeedCfg[i].szIcon and Pet.Def.FeedCfg[i].szIcon~="" then
			self.pPanel:Sprite_SetSprite("Sprite"..i, Pet.Def.FeedCfg[i].szIcon, Pet.Def.FeedCfg[i].szIconAtlas)
		end
	end
	local _, nCur = Pet:CheckFeedCount(me)
	self.pPanel:Label_SetText("AssistTime", string.format("剩余喂食次数：%d", math.max(Pet.Def.FeedCfg.nDailyLimit-nCur, 0)))

	local nCurBuffId = me.GetUserValue(Pet.Def.SaveGrp, Pet.Def.SaveKeyBuffId)
	local nCurBuffLvl = me.GetUserValue(Pet.Def.SaveGrp, Pet.Def.SaveKeyBuffLvl)
	local tbBuff = self:GetBuffData(nCurBuffId, nCurBuffLvl)
	self.pPanel:SetActive("Buff", false)
	if tbBuff then
		self.pPanel:Sprite_SetSprite("BuffSprite", tbBuff.szIcon, tbBuff.szAtlas)
		self.pPanel:Label_SetText("BuffName", string.format("%s    等级：%d", tbBuff.szName, nCurBuffLvl))

		local szEffect = nil
		if nCurBuffId and nCurBuffId>0 then
		    local bOldCalcValue = FightSkill.bCalcValue
		    FightSkill.bCalcValue = true
		    local _, szEffectTmp = Lib:CallBack({FightSkill.GetSkillStateMagicDesc, FightSkill, nCurBuffId, nCurBuffLvl})
		    FightSkill.bCalcValue = bOldCalcValue
		    szEffect = szEffectTmp
		end
		self.pPanel:Label_SetText("BuffEffect", szEffect or "")
		self.pPanel:SetActive("Buff", true)
	end

	local nNow = GetTime()
	self.ScrollView:Update(#self.tbPets, function(pGrid, nIdx)
		local tbPet = self.tbPets[nIdx]
		local nPetTemplateId = tbPet.nPetTemplateId
		pGrid.pPanel:Label_SetText("Name", tbPet.szName or KNpc.GetNameByTemplateId(nPetTemplateId))

		local nFaceId = KNpc.GetNpcShowInfo(nPetTemplateId)
		local szAtlas, szSprite = Npc:GetFace(nFaceId)
		pGrid.pPanel:Sprite_SetSprite("Head", szSprite, szAtlas)

		pGrid.pPanel:Label_SetText("Adopt", "领养："..Lib:TimeDesc16(nNow-tbPet.nBornTime))
		pGrid.pPanel:Label_SetText("Remaining", "剩余："..(tbPet.nDeadline<=0 and "永久" or Lib:TimeDesc16(tbPet.nDeadline-nNow)))

		pGrid.BtnNameEdit.pPanel.OnTouchEvent = function()
			Ui:OpenWindow("PetChangeName", nPetTemplateId)
		end
	end)
end

function tbUi:GetBuffData(nBuffId, nLevel)
	if not nBuffId or nBuffId<=0 then
		return nil
	end

	local pNpc = me.GetNpc()
	if not pNpc then
		return nil
	end

	local tbState = pNpc.GetSkillState(nBuffId)
    if not tbState or tbState.nEndFrame<=0 then
    	return nil
    end

	local tbStateEffect = FightSkill:GetStateEffectBySkill(nBuffId, nLevel)
	if not tbStateEffect then
		Log("[x] PetFeedPanel:GetBuffData", nBuffId)
		return nil
	end

	return {
		szName = tbStateEffect.StateName,
		szIcon = tbStateEffect.Icon,
		szAtlas = tbStateEffect.IconAtlas,
		szEffect = tbStateEffect.MagicDesc,
	}
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_MAP_LEAVE, function() self:OnLeaveMap() end},
		{UiNotify.emNOTIFY_PET_FEED_REFRESH, function() self:Refresh() end},
	}
end
