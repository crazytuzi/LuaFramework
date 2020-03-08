local tbItem = Item:GetClass("CardPickDiamond");

function tbItem:OnUse(it)
	me.CallClientScript("Ui:OpenWindow", "CardPickingResult", "GoldFreePick");

	local tbItem = CardPicker:GetNextGoldItem(me);
	local tbItems, bHasSSPlus = CardPicker:HiddenRuleHandler({tbItem}, me);
	tbItem = unpack(tbItems);

	me.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_GoldPick);
	me.CallClientScript("CardPicker:OnCoinPickResult", {tbItem});

	Log("CardPicker Diamond", me.szAccount, me.dwID, "GoldItemUse", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
	return 1;
end