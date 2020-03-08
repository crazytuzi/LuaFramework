local tbItem = Item:GetClass("CardPickCoin");

function tbItem:OnUse(it)
	me.CallClientScript("Ui:OpenWindow", "CardPickingResult", "CoinFreePick");

	local tbItem = CardPicker:GetRandomItem("Coin", me);
	me.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_CoinPick);
	me.CallClientScript("CardPicker:OnCoinPickResult", {tbItem});

	-- local tbGift = CardPicker.Def.tbCoinPickGift;
	-- me.SendAward({{tbGift.szItemType, tbGift.nItemId, 1}}, nil, nil, Env.LogWay_CoinPick);

	Log("CardPicker", me.szAccount, me.dwID, "CoinItemUse", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
	return 1;
end