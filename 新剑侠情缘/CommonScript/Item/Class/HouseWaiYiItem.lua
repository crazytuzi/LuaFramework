
local tbItem = Item:GetClass("HouseWaiYiItem");

function tbItem:OnUse(it)
	local nHouseWaiYiId = KItem.GetItemExtParam(it.dwTemplateId, 1);
	if not House.tbHouseWaiYiSetting[nHouseWaiYiId] then
		me.CenterMsg("无效道具");
		return;
	end

	local bRet, szMsg = House:AddHouseWaiYi(me, nHouseWaiYiId);
	if not bRet then
		me.CenterMsg(szMsg or "大侠已拥有此装饰");
		return;
	end

	me.CenterMsg("成功放入家园装饰，快回家园看看吧！");
	return 1;
end


function tbItem:GetUseSetting(nTemplateId, nItemId)
	if not nItemId then
		return {};
	end

	return {szFirstName = "放入家园装饰", fnFirst = "UseItem"};
end