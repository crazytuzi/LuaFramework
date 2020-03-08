local tbItem = Item:GetClass("WomensDayItem")

function tbItem:OnUse(it)
	local tbAct = Activity:GetClass("WomenDayFubenAct")
	local nMapTemplateId = tbAct.nFubenMapTID

	if me.nMapTemplateId~=nMapTemplateId then
		me.CenterMsg("未到使用时机")
		return
	end

	local pMonsterNpc = nil
	local nMapId = me.nMapId
	local tbAllNpcs = KNpc.GetMapNpc(nMapId)
	for _, pNpc in ipairs(tbAllNpcs) do
		if pNpc.nTemplateId==tbAct.nBossId then
			pMonsterNpc = pNpc
			break
		end
	end

	if not pMonsterNpc then
		me.CenterMsg("未到使用时机")
		return
	end

	local pMeNpc = me.GetNpc()
	if pMeNpc.GetDistance(pMonsterNpc.nId)>tbAct.nMaxSkillDist then
		me.CenterMsg("距离目标太远了！")
		return
	end

	Activity:OnPlayerEvent(me, "Act_UseWomensDayItem")
	me.CallClientScript("Ui:CloseWindow", "QuickUseItem")

	return 1
end
