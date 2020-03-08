local tbItem = Item:GetClass("QueZhiLing")

function tbItem:OnUse(it)
	local _, tbRunning = Activity:GetActivityData()
	if not tbRunning.QueQiaoXiangHuiAct then
		me.CenterMsg("不在活动地图内")
		return
	end

	local tbAct = tbRunning.QueQiaoXiangHuiAct.tbInst
	tbAct:OnClientReq(me, "Put")
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {szFirstName = "摆放", fnFirst = "UseItem"}
end