
local tbItem = Item:GetClass("RandomItemByLevel");
tbItem.MAX_COUNT = 20;
function tbItem:LoadSetting()
	local szType = "d";
	local tbTitle = {"ParamId"};
	for i = 1, self.MAX_COUNT do
		szType = szType .. "dd";
		table.insert(tbTitle, "Level" .. i);
		table.insert(tbTitle, "RandomId" .. i);
	end

	local tbFile = LoadTabFile("Setting/Item/RandomByLevel.tab", szType, nil, tbTitle);
	self.tbAllLevelInfo = {};
	local function fnCmp(a, b)
		return a[1] < b[1];
	end
	for _, tbRow in pairs(tbFile) do
		local tbLevelInfo = {};
		for i = 1, self.MAX_COUNT do
			if tbRow["Level" .. i] and tbRow["Level" .. i] > 0 and tbRow["RandomId" .. i] and tbRow["RandomId" .. i] > 0 then
				table.insert(tbLevelInfo, {tbRow["Level" .. i], tbRow["RandomId" .. i]});
			end
		end

		if #tbLevelInfo > 0 then
			table.sort(tbLevelInfo, fnCmp);
			tbLevelInfo[#tbLevelInfo][1] = 99999;
			self.tbAllLevelInfo[tbRow.ParamId] = tbLevelInfo;
		end
	end
end

function tbItem:GetAllLevelInfo()
	if not self.tbAllLevelInfo then
		self:LoadSetting()
	end
	return self.tbAllLevelInfo
end	

function tbItem:OnUse(it)
	local nParamId = it.nRandomByLevelKindId or self:GetRandomByLevelIdByPlayer(me, it.dwTemplateId);
	local nRet, szMsg, tbAllAward = self:GetAwardByLevel(me, nParamId, it.szName, it.dwTemplateId)
	if szMsg then
		me.CenterMsg(szMsg, true)
	end

	--Log("[Item] RandomItemByLevel OnUse", it.dwTemplateId, it.szName, me.szName, me.szAccount, me.dwID);
	return nRet, tbAllAward;
end

function tbItem:GetRandomByLevelIdByPlayer(pPlayer, nItemId)
	if not MODULE_GAMESERVER then
		return 0;
	end

	local nParamId = KItem.GetItemExtParam(nItemId, 1);
	local nParamIdLimit = KItem.GetItemExtParam(nItemId, 3);
	local nDebt = Player:GetRewardValueDebt(pPlayer.dwID);
	if nParamIdLimit and nParamIdLimit > 0 and (MarketStall:CheckIsLimitPlayer(pPlayer) or (nDebt and nDebt > 0)) then
		nParamId = nParamIdLimit;
	end
	return nParamId;
end

function tbItem:GetRandomKindIdByPlayer(pPlayer, nItemId)
	if not MODULE_GAMESERVER then
		return 0;
	end

	local nParamId = self:GetRandomByLevelIdByPlayer(pPlayer, nItemId);
	return self:GetRandomKindId(pPlayer.nLevel, nParamId);
end

function tbItem:GetRandomKindId(nLevel, nRandomByLevelKindId)
	local tbAllLevelInfo = self:GetAllLevelInfo()
    local tbLevelInfo = tbAllLevelInfo[nRandomByLevelKindId or -1];
	if not tbLevelInfo then
		return;
	end

	local nRandomItemKindId;
	for _, tbInfo in pairs(tbLevelInfo) do
		if nLevel <= tbInfo[1] then
			nRandomItemKindId = tbInfo[2];
			break;
		end
	end

	if not nRandomItemKindId then
		return;
	end

	return nRandomItemKindId;
end

function tbItem:GetAwardByLevel(pPlayer, nRandomByLevelKindId, szFromItemName, dwTemplateId)
	local nRandomItemKindId = self:GetRandomKindId(pPlayer.nLevel, nRandomByLevelKindId);
	if not nRandomItemKindId then
		Log("[RandomItemByLevel] OnUse ERR ?? nRandomItemKindId is nil !!", pPlayer.szName, pPlayer.dwID, szFromItemName, nRandomByLevelKindId);
		return 0;
	end

	return Item:GetClass("RandomItem"):GetRandItemAward(pPlayer, nRandomItemKindId, szFromItemName, false, dwTemplateId);
end

-- pPlayer 可不传，传pPlayer才能进行公告操作，像藏宝图不想用GetAwardByLevel直接发奖励，又想公告
function tbItem:GetAwardListByLevel(nLevel, nRandomByLevelKindId, szFromItemName, pPlayer)
	local nRandomItemKindId = self:GetRandomKindId(nLevel, nRandomByLevelKindId);
	if not nRandomItemKindId then
		Log("[RandomItemByLevel] OnUse ERR ?? nRandomItemKindId is nil !!", nLevel, szFromItemName, nRandomByLevelKindId);
		return 0;
	end
	return Item:GetClass("RandomItem"):RandomItemAward(pPlayer, nRandomItemKindId, szFromItemName);
end
