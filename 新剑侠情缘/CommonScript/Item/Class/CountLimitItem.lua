local tbItem = Item:GetClass("CountLimitItem");

function tbItem:GetTip(it)
	if not it.dwId then
		return "";
	end

	local nMaxCount = KItem.GetItemExtParam(it.dwTemplateId, 1);
	local nUsedCount = it.GetIntValue(1);
	return string.format("剩余可浇水次数：%d/%d", nMaxCount - nUsedCount, nMaxCount);
end

function tbItem:GetUseSetting()
	return {};
end