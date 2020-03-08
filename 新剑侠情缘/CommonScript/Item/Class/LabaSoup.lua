local tbItem = Item:GetClass("LabaSoup")

tbItem.nSkillId = 2316
tbItem.nBuffDuration = 23*3600
tbItem.nExpAddRate = 0.6

function tbItem:OnUse(it)
	if self:HasDrank(me) then
		me.CenterMsg("少侠已喝过腊八粥了，还是稍后再喝吧")
		return 0
	end

	me.AddSkillState(self.nSkillId, 1, 2, GetTime()+self.nBuffDuration, 1, 1)
	me.CenterMsg("你喝了一碗腊八粥")
	me.Msg("你喝了一碗腊八粥")

	return 1
end

function tbItem:HasDrank(pPlayer)
	return pPlayer.GetNpc().GetSkillState(self.nSkillId)
end

function tbItem:GetExpAddRate(pPlayer)
	return self:HasDrank(pPlayer) and self.nExpAddRate or 0
end