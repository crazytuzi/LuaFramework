local tbItem = Item:GetClass("SnowmanBox");

local Snowman = Kin.Snowman

function tbItem:OnUse(it)
	local nGet = me.GetUserValue(Snowman.SAVE_ONHOOK_GROUP, Snowman.Award_Count);
	if nGet >= Snowman.nBoxOpenCount then
		me.CenterMsg("可开启礼盒的次数已经用光了",true)
		return
	end

	me.SetUserValue(Snowman.SAVE_ONHOOK_GROUP,Snowman.Award_Count,nGet + 1)

	local nItemId = tonumber(KItem.GetItemExtParam(it.dwTemplateId, 1))
	me.SendAward({{"item", nItemId, 1}}, nil, true, Env.LogWay_SnowmanAct);
	Log("[SnowmanBox] OnUse ",nItemId,it.dwTemplateId,nGet)
	return 1
end