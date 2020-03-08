local tbItem = Item:GetClass("ActivityLimitBox");

local Snowman = Kin.Snowman

tbItem.SAVE_BOX_GROUP = 129
tbItem.Count_Key = 1

function tbItem:OnUse(it)
	local nGet = me.GetUserValue(self.SAVE_BOX_GROUP, self.Count_Key);
	if nGet >= Snowman.nBoxOpenCount then
		me.CenterMsg("可开启礼盒的次数已经用光了", true)
		return
	end

	me.SetUserValue(self.SAVE_BOX_GROUP, self.Count_Key, nGet + 1)

	local nItemId = tonumber(KItem.GetItemExtParam(it.dwTemplateId, 1))

	me.SendAward({{"item", nItemId, 1}}, nil, true, Env.LogWay_SnowmanAct);

	Log("[SnowmanBox] OnUse ", nItemId, it.dwTemplateId, nGet)

	return 1
end