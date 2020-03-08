
local tbUnidentify = Item:GetClass("UnidentifyScriptItem");

function tbUnidentify:OnUse(it)
	local nCost = self:GetIdentifyCost(it.dwTemplateId)
	local nEquipTemplateId = KItem.GetItemExtParam(it.dwTemplateId, 2);
	local nOtherTemplateId = KItem.GetItemExtParam(it.dwTemplateId, 3);
	if nEquipTemplateId <= 0 or not me.CostMoney("Coin", nCost, Env.LogWay_IdentifyItem) then
		return
	end

	if nOtherTemplateId > 0 and MarketStall:CheckIsLimitPlayer(me) then
		nEquipTemplateId = nOtherTemplateId;
	end

	me.SendAward({{"item", nEquipTemplateId, 1}}, true, false, Env.LogWay_IdentifyItem);
	me.CenterMsg("鉴定成功");
	return 1;
end

function tbUnidentify:GetIdentifyCost(dwTemplateId)
	return KItem.GetItemExtParam(dwTemplateId, 1);
end

function tbUnidentify:CheckUsable(it)
	local nCost = self:GetIdentifyCost(it.dwTemplateId)
	if me.GetMoney("Coin") < nCost then
		return 0, string.format("您身上不够%d银两", nCost)
	end

	return 1;
end

function tbUnidentify:GetIntroBottom(nTemplateId)
	local _, szMoneyEmotion = Shop:GetMoneyName("Coin")
	return string.format("鉴定消耗 %s %d", szMoneyEmotion, self:GetIdentifyCost(nTemplateId));
end

function tbUnidentify:GetUseSetting()
	return {szFirstName = "鉴定", fnFirst = "UseItem"};
end
