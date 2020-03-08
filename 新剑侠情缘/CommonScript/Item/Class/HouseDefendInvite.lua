
local tbItem = Item:GetClass("HouseDefendInvite");
tbItem.nRandomItem = 5425;
tbItem.tbInviteItem = { 5424, 5423 };
tbItem.nInviteRatio = 5;
tbItem.nValidTime = 3600 * 24;

function tbItem:OnUse(it)
	local bHasInviteItem = false;
	for _, nItemTemplateId in ipairs(tbItem.tbInviteItem) do
		local tbItems = me.FindItemInBag(nItemTemplateId);
		if next(tbItems) then
			bHasInviteItem = true;
			break;
		end
	end

	if bHasInviteItem or not Activity:__IsActInProcessByType("HouseDefend") or MathRandom(1, 100) > tbItem.nInviteRatio then
		me.SendAward({{"item", tbItem.nRandomItem, 1}}, true, nil, Env.LogWay_HouseDefend);
		return 1;
	end

	local nCurTime = GetTime();
	local nPassTime = Lib:GetLocalDayTime(nCurTime);
	local tbActivity = Activity:GetClass("HouseDefend");
	local nTimeout = tbActivity.TIME_CLEAR - nPassTime;
	if nTimeout <= 0 then
		nTimeout = nTimeout + tbItem.nValidTime;
	end
	nTimeout = math.max(nTimeout - 30, 1);

	local nIndex = MathRandom(1, #(tbItem.tbInviteItem));
	local nItemId = tbItem.tbInviteItem[nIndex];
	local tbAward = {{"item", nItemId, 1, nCurTime + nTimeout}};
	me.SendAward(tbAward, true, true, Env.LogWay_HouseDefend);

	Log("[HouseDefendInvite] user item:", it.dwTemplateId, "gain invite item: ", me.dwID, me.szName);

	return 1;
end
