
local tbItem = Item:GetClass("ZhenQiItem");

function tbItem:OnUse(it)
	local nCount = KItem.GetItemExtParam(it.dwTemplateId, 1);
	if nCount <= 0 then
		me.CenterMsg("异常道具", true);
		return;
	end

	me.SendAward({{"ZhenQi", nCount}}, true, true, Env.LogWay_UseZhenQiItem);
	return 1;
end

