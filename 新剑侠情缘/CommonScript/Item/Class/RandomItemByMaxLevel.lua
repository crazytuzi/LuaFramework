
local tbItem = Item:GetClass("RandomItemByMaxLevel");


function tbItem:OnUse(it)
	local nParamId = it.nRandomByLevelKindId or KItem.GetItemExtParam(it.dwTemplateId, 1);
	local nRet, szMsg, tbAllAward = self:GetAwardByLevel(me, nParamId, it.szName, it.dwTemplateId)
	if szMsg then
		me.CenterMsg(szMsg, true)
	end

	Log("[Item] RandomItemByMaxLevel OnUse", it.dwTemplateId, it.szName, me.szName, me.szAccount, me.dwID);
	return nRet, tbAllAward;
end

function tbItem:GetAwardByLevel(pPlayer, nRandomByLevelKindId, szFromItemName, dwTemplateId)
	local nRandomItemKindId = Item:GetClass("RandomItemByLevel"):GetRandomKindId(GetMaxLevel(), nRandomByLevelKindId);
	if not nRandomItemKindId then
		Log("[RandomItemByMaxLevel] OnUse ERR ?? nRandomItemKindId is nil !!", pPlayer.szName, pPlayer.dwID, szFromItemName, nRandomByLevelKindId);
		return 0;
	end

	return Item:GetClass("RandomItem"):GetRandItemAward(pPlayer, nRandomItemKindId, szFromItemName, true, dwTemplateId);
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local nParamId =  KItem.GetItemExtParam(nTemplateId, 1);
	local nUseAwardTip =  KItem.GetItemExtParam(nTemplateId, 3);
	if nUseAwardTip ~= 1 then
		local tbInfo = KItem.GetItemBaseProp(nTemplateId)
		return tbInfo.szIntro
	end
	local nRet, _, tbAllAward = Item:GetClass("RandomItemByLevel"):GetAwardListByLevel(TimeFrame:GetMaxLevel(), nParamId, "")
	local szAwadDesc =  table.concat( Lib:GetAwardDesCount2(tbAllAward, me), "、")
	return string.format("使用获得：[FFFE0D]%s[-]", szAwadDesc)
end



