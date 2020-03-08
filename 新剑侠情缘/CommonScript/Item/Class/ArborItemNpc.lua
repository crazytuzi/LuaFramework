local tbItem = Item:GetClass("ArborItemNpc");

function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("ArborDayCure") then
		me.CenterMsg("活动已经结束", true)
		return 
	end

	local nNpcTID =  KItem.GetItemExtParam(it.dwTemplateId, 1);
	if not nNpcTID then
		me.CenterMsg("未知道具", true)
		return 
	end

	Activity:OnPlayerEvent(me, "Act_UseArborItemNpc", it.dwTemplateId, nNpcTID);
end