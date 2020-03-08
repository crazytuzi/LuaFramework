local tbItem = Item:GetClass("WorldCupUnidentMedal8")

function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("WorldCupAct") then
		me.CenterMsg("活动已经结束", true)
		return 1
	end

	local _, tbRunning = Activity:GetActivityData()
	local tbAct = tbRunning.WorldCupAct.tbInst
	local bOk, szErr = tbAct:CheckPlayer(me)
	if not bOk then
		me.CenterMsg(szErr)
		return 0
	end
	local szMoneyName = Shop:GetMoneyName(tbAct.szIdentyCostType)
	if me.GetMoney(tbAct.szIdentyCostType)<tbAct.nIdentyMedalCost or not me.CostMoney(tbAct.szIdentyCostType, tbAct.nIdentyMedalCost, Env.LogWay_WorldCupAct) then
		me.CenterMsg(string.format("%s不足", szMoneyName))
		return 0
	end
    me.CenterMsg(string.format("鉴定消耗了%d%s", tbAct.nIdentyMedalCost, szMoneyName), true)

	local nIdx = MathRandom(#tbAct.tbShowItems8)
	local nTempId = tbAct.tbShowItems8[nIdx]
	local _, nEndTime = tbAct:GetOpenTimeInfo()
    local tbAward = {{"item", nTempId, 1, nEndTime}}
    me.SendAward(tbAward, true, true, Env.LogWay_WorldCupAct)

	return 1
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {szFirstName = "鉴定", fnFirst = "UseItem"}
end