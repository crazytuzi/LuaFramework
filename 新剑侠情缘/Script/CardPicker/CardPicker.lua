function CardPicker:GetLeftSTime()
	local nLeftSTime = me.GetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_LEFT_S_TIME);
	if nLeftSTime == 0 then
		nLeftSTime = 10;
	end
	return nLeftSTime;
end

function CardPicker:GetNextFreePickTime()
	local nNextGoldFree = me.GetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_GOLD_FREE_TIME);
	if nNextGoldFree == 0 then
		RemoteServer.OnCardPickerRequest("UpdateFreeTimeData");
		nNextGoldFree = GetTime() + 1;
	end
	return nNextGoldFree;
end

function CardPicker:GetNextCoinFreePickTime()
	local nNextCoinFreeTime = me.GetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_COIN_FREE_TIME);
	if nNextCoinFreeTime == 0 then
		nNextCoinFreeTime = GetTime() + 1;
	end
	return nNextCoinFreeTime;
end

function CardPicker:OnGoldPickResult(tbResult, tbGift)
	CardPicker:OnCardPcikCommonResult("Gold", tbResult, tbGift);
	Ui:ClearRedPointNotify("GoldFreePick");
end

function CardPicker:OnTenPickResult(tbResult, tbGift)
	CardPicker:OnCardPcikCommonResult("Ten", tbResult, tbGift);
	CardPicker:UpdateRemoteInfo();
end

function CardPicker:OnCoinPickResult(tbResult, tbGift)
	CardPicker:OnCardPcikCommonResult("Coin", tbResult, tbGift);
end

function CardPicker:OnCardPcikCommonResult(szType, tbResult, tbGift)
	UiNotify.OnNotify(UiNotify.emNOTIFY_CARD_PICKING);
	local fnPick = function ()
		Lib:RandomArray(tbResult);
		CardPicker.tbResultCache = tbResult;

		if Ui:WindowVisible("CardPickingResult") ~= 1 then
			Ui:OpenWindow("CardPickingResult", szType);
		end
	end

	if tbGift then
		local tbItemInfo = KItem.GetItemBaseProp(tbGift.nItemId) or {};
		local szTips = string.format("成功购买[FFFE0D]%s*%d[-], 同时获得赠送的[FFFE0D]%d[-]次招募次数，点击进行招募。\n([FFFE0D]%%d[-]秒后将自动进行招募)", tbItemInfo.szName or "", #tbResult, #tbResult);
		me.MsgBox(szTips, {{"招募", fnPick}}, nil, 5, fnPick);
	else
		fnPick();
	end
end

function CardPicker:OnCardPickFail(szTips)
	Ui:CloseWindow("CardPickingResult");
	UiNotify.OnNotify(UiNotify.emNOTIFY_CARD_PICKING);
	if szTips then
		me.CenterMsg(szTips);
	end
end

function CardPicker:GetResultCache()
	return CardPicker.tbResultCache;
end

function CardPicker:ClearResultCache()
	CardPicker.tbResultCache = nil;
end

function CardPicker:IsItemFlop(szItemType, nItemId, nShowLevel)
	if szItemType == "Partner" then
		nShowLevel = nShowLevel or Partner.tbDes2QualityLevel.S;
		local _, nQualityLevel = GetOnePartnerBaseInfo(nItemId);
		if nQualityLevel and nQualityLevel <= nShowLevel then
			return true;
		end
	elseif szItemType == "PartnerCard" then
		nShowLevel = nShowLevel or Partner.tbDes2QualityLevel.S;
		local nQualityLevel = PartnerCard:GetQualityByCardId(nItemId)
		if nQualityLevel and nQualityLevel <= nShowLevel then
			return true;
		end
	end
	return false;
end

function CardPicker:GetGoldTenCost()
	if self.nCacheGoldTenCost then
		return self.nCacheGoldTenCost, self.nCacheGoldTenSaleFlag;
	end

	return CardPicker.Def.nGoldTenCost;
end

function CardPicker:UpdateRemoteInfo()
	RemoteServer.OnCardPickerRequest("UpdateCardPickInfo");
end

function CardPicker:GetCurSpecialPartner()
	if self.tbSpecialPartner then
		return self.tbSpecialPartner;
	end

	return CardPicker.Def.tbSpecialTenGoldSPartner;
end

function CardPicker:OnSyncGoldTenInfo(nGoldTenCost, nGoldTenSaleFlag, tbSpecialPartner)
	self.nCacheGoldTenCost = nGoldTenCost;
	self.nCacheGoldTenSaleFlag = nGoldTenSaleFlag;
	self.tbSpecialPartner = tbSpecialPartner;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CARD_PICKING);
end

function CardPicker:Ask4CardPickHistory()
	RemoteServer.OnCardPickerRequest("Ask4CardPickHistory");
end


CardPicker.tbCardPickType2Name = {
	CoinPick     = "银两购买-购买一次",
	CoinTenPick  = "银两购买-购买十次",
	CoinFreePick = "银两购买-免费",
	GoldPick     = "元宝购买-购买一次",
	GoldTenPick  = "元宝购买-购买十次",
	GoldFreePick = "元宝购买-免费",
}

function CardPicker:OnSyncPickHistory(tbHistory)
	local tbString = {};
	for _, tbData in ipairs(tbHistory) do
		local szName, szType, nItemId = unpack(tbData);
		local tbUtf8s = Lib:GetUft8Chars(szName);
		for i, _ in ipairs(tbUtf8s) do
			if i ~= 1 then
				tbUtf8s[i] = "*";
			end
		end

		szName = table.concat(tbUtf8s);
		local szPartnerName, nQualityLevel = GetOnePartnerBaseInfo(nItemId);
		local szHistory = string.format("\n[FFFE0D]%s[-]在[FFFE0D]%s[-]中获得%s级同伴：%s", 
										szName, CardPicker.tbCardPickType2Name[szType] or "",
										Partner.tbQualityLevelDes[nQualityLevel], szPartnerName);

		table.insert(tbString, szHistory);
	end
	
	self.szLastestHistory = table.concat(tbString);
	UiNotify.OnNotify(UiNotify.emNOTIFY_CARD_PICKING);
end

function CardPicker:GetLatestPickHistory()
	return self.szLastestHistory or "";
end

