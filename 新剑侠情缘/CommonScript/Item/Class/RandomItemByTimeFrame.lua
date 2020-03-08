
local tbItem = Item:GetClass("RandomItemByTimeFrame");
tbItem.MAX_COUNT = 20;
function tbItem:LoadSetting()
	local szType = "dds";
	local tbTitle = {"ParamId", "DefaultRandomId", "Desc0"};
	for i = 1, self.MAX_COUNT do
		szType = szType .. "sds";
		table.insert(tbTitle, "TimeFrame" .. i);
		table.insert(tbTitle, "RandomId" .. i);
		table.insert(tbTitle, "Desc" .. i);
	end

	local tbFile = LoadTabFile("Setting/Item/RandomByTimeFrame.tab", szType, nil, tbTitle);
	self.tbAllTimeFrameInfo = {};
	local function fnCmp(a, b)
		return a[1] < b[1];
	end

	for _, tbRow in pairs(tbFile) do
		assert(tbRow.DefaultRandomId > 0, string.format("[RandomItemByTimeFrame] Error DefaultRandomId: %s, ParamId: %s", tbRow.DefaultRandomId, tbRow.ParamId));
		local tbTimeFrameInfo = {nDefaultRandomId = tbRow.DefaultRandomId, Desc0 = tbRow.Desc0 };
		local nLastOpenTime = -1;
		for i = 1, self.MAX_COUNT do
			local nRandomId = tbRow["RandomId" .. i];
			local szTimeFrame = tbRow["TimeFrame" .. i];
			local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame);
			if szTimeFrame ~= "" and nOpenTime == 0 then
				assert(false, string.format("[RandomItemByTimeFrame] Error TimeFrame: %s, ParamId: %s", szTimeFrame, tbRow.ParamId));
			end

			if nOpenTime <= 0 then
				assert(nRandomId == 0, string.format("[RandomItemByTimeFrame] Error RandomId: %s, ParamId: %s", nRandomId, tbRow.ParamId));
				break;
			end

			assert(nRandomId > 0, string.format("[RandomItemByTimeFrame] Error RandomId: %s, ParamId: %s", nRandomId, tbRow.ParamId));
			--assert(nOpenTime > nLastOpenTime, string.format("[RandomItemByTimeFrame] Error TimeFrame: %s, ParamId: %s", szTimeFrame, tbRow.ParamId));
			if nOpenTime <= nLastOpenTime then
				Log("[RandomItemByTimeFrame] Error TimeFrame: %s, ParamId: %s, remove previous", szTimeFrame, tbRow.ParamId)
				table.remove(tbTimeFrameInfo)
			end
			nLastOpenTime = nOpenTime;
			table.insert(tbTimeFrameInfo, {szTimeFrame, nRandomId, tbRow["Desc" .. i]});
		end

		if #tbTimeFrameInfo > 0 then
			self.tbAllTimeFrameInfo[tbRow.ParamId] = tbTimeFrameInfo;
		end
	end
end

function tbItem:OnUse(it)
	local nParamId = it.nRandomByTimeFrameKindId or self:GetRandomByTimeFrameIdByPlayer(me, it.dwTemplateId);
	local nRet, szMsg, tbAllAward = self:GetAwardByTimeFrame(me, nParamId, it.szName, it.dwTemplateId)
	if szMsg then
		me.CenterMsg(szMsg)
	end

	Log("[Item] RandomItemByTimeFrame OnUse", it.dwTemplateId, it.szName, me.szName, me.szAccount, me.dwID);
	return nRet, tbAllAward;
end

function tbItem:GetRandomByTimeFrameIdByPlayer(pPlayer, nItemId)
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

	local nParamId = self:GetRandomByTimeFrameIdByPlayer(pPlayer, nItemId);
	return self:GetRandomKindId(nParamId);
end

function tbItem:GetRandomKindId(nRandomByTimeFrameKindId)
	if not self.tbAllTimeFrameInfo and not MODULE_GAMESERVER then --因为读取里有用到时间轴
		self:LoadSetting();
	end
	local tbTimeFrameInfo = self.tbAllTimeFrameInfo[nRandomByTimeFrameKindId or -1];
	if not tbTimeFrameInfo then
		return;
	end

	local nRandomItemKindId = tbTimeFrameInfo.nDefaultRandomId;
	local szDesc = tbTimeFrameInfo.Desc0;
	for _, tbInfo in ipairs(tbTimeFrameInfo) do
		if GetTimeFrameState(tbInfo[1]) == 1 then
			nRandomItemKindId = tbInfo[2];
			szDesc = tbInfo[3];
		else
			break;
		end
	end

	return nRandomItemKindId, szDesc;
end

function tbItem:GetAwardByTimeFrame(pPlayer, nRandomByTimeFrameKindId, szFromItemName, dwTemplateId)
	local nRandomItemKindId = self:GetRandomKindId(nRandomByTimeFrameKindId);
	if not nRandomItemKindId then
		Log("[RandomItemByTimeFrame] OnUse ERR ?? nRandomItemKindId is nil !!", pPlayer.szName, pPlayer.dwID, szFromItemName, nRandomByTimeFrameKindId);
		return 0;
	end

	return Item:GetClass("RandomItem"):GetRandItemAward(pPlayer, nRandomItemKindId, szFromItemName, false, dwTemplateId);
end

function tbItem:GetAwardListByTimeFrame(nRandomByTimeFrameKindId, szFromItemName)
	local nRandomItemKindId = self:GetRandomKindId(nRandomByTimeFrameKindId);
	if not nRandomItemKindId then
		Log("[RandomItemByTimeFrame] OnUse ERR ?? nRandomItemKindId is nil !!", szFromItemName, nRandomByTimeFrameKindId);
		return 0;
	end

	return Item:GetClass("RandomItem"):RandomItemAward(nil, nRandomItemKindId, szFromItemName);
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local nParamId =  KItem.GetItemExtParam(nTemplateId, 1);
	local nRandomItemKindId, szDesc = self:GetRandomKindId(nParamId);
	if not Lib:IsEmptyStr(szDesc) then
		return szDesc
	end

	local nUseAwardTip =  KItem.GetItemExtParam(nTemplateId, 4);
	if nUseAwardTip ~= 1 then
		local tbInfo = KItem.GetItemBaseProp(nTemplateId)
		return tbInfo.szIntro
	end

	local nRet, _, tbAllAward = self:GetAwardListByTimeFrame(nParamId, "")
	local szAwadDesc =  table.concat( Lib:GetAwardDesCount2(tbAllAward, me), "、")
	return string.format("使用获得：[FFFE0D]%s[-]", szAwadDesc)
end

function tbItem:GetFixRandItemAward(nTemplateId)
	local nParamId =  KItem.GetItemExtParam(nTemplateId, 1);
	local nRandomItemKindId, szDesc = self:GetRandomKindId(nParamId);
	return Item:GetClass("RandomItem"):GetFixRandItemAward(nRandomItemKindId);
end



