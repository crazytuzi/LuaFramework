Require("CommonScript/Player/PlayerEventRegister.lua");
Require("CommonScript/BossLeader/BossLeaderDef.lua");

function BossLeader:LoadSetting()
	self.tbMainSetting = {};
	self.tbCrossMainSetting = {};
	self.tbAllNpcGroup = {};
	self.tbAllFirstDmgAward = {};
	self.tbAllPlayerDmgRank = {};
	self.tbShowAwardSetting = {};
	self.tbAllTMapSetting = {};
	self.tbKinItemAwardSetting = {};
	self.tbTimeFrameSetting = {};
	self.tbCrossTimeFrameSetting = {};
	self.tbLinkMapSetting = {};
	self.tbKinValueAward = {};
	self.tbCrossKinJiFenNpc = {};
	self.tbAllGroupNpcInfo = {};
	self.tbLastDmgPlayerAward = {};
	self.tbCallEventSetting = {};

--    local tbSafeCrossMapID = {};

	local tbFileData = Lib:LoadTabFile("Setting/BossLeader/Main.tab", {MapID = 1, ShowAwardID = 1, ShowNpcID = 1, NpcRateCount = 1, NpcGroupRateCount = 1, NpcLevel = 1, SortNum = 1,
																		LinkMapID = 1, Cross = 1});
	for nRow, tbInfo in pairs(tbFileData) do
		local tbMainSetting = self.tbMainSetting;
		if tbInfo.Cross == 1 then
			tbMainSetting = self.tbCrossMainSetting;

			-- tbSafeCrossMapID[tbInfo.TimeFrame] = tbSafeCrossMapID[tbInfo.TimeFrame] or {};
			-- for szKey, tbCurCrossMap in pairs(tbSafeCrossMapID) do
			--     if tbCurCrossMap[tbInfo.MapID] and szKey ~= tbInfo.TimeFrame then
			--         Log(debug.traceback(), "跨服不能相同地图");
			--     end
			-- end
			-- tbSafeCrossMapID[tbInfo.TimeFrame][tbInfo.MapID] = 1;
		end

		tbMainSetting[tbInfo.NpcType] = tbMainSetting[tbInfo.NpcType] or {};
		tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame] = tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame] or {};
		local tbMapInfo = {};
		tbMapInfo.nMapTID             = tbInfo.MapID;
		tbMapInfo.nNpcRateCount      = tbInfo.NpcRateCount;
		tbMapInfo.nNpcGroupRateCount = tbInfo.NpcGroupRateCount;
		tbMapInfo.szActivityName     = tbInfo.ActivityName or "";
		tbMapInfo.nTotalGroupRate    = 0;
		tbMapInfo.tbGroupNpc         = {};
		tbMapInfo.nShowAwardID       = tbInfo.ShowAwardID;
		tbMapInfo.nShowNpcID         = tbInfo.ShowNpcID;
		tbMapInfo.nNpcLevel          = tbInfo.NpcLevel;
		tbMapInfo.nSortNum           = tbInfo.SortNum;
		tbMapInfo.nLinkMapID         = tbInfo.LinkMapID;
		tbMapInfo.szTimeFrame        = tbInfo.TimeFrame;
		tbMapInfo.szShowName         = tbInfo.ShowName;

		for nI = 1, 10 do
			if not Lib:IsEmptyStr(tbInfo["NpcGroupID_"..nI]) and not Lib:IsEmptyStr(tbInfo["NpcGroupRate_"..nI]) then
				local nNpcGroupID = tonumber(tbInfo["NpcGroupID_"..nI]);
				local nRate    = tonumber(tbInfo["NpcGroupRate_"..nI]);
				tbMapInfo.nTotalGroupRate = tbMapInfo.nTotalGroupRate + nRate;
				local tbRateNpc = {};
				tbRateNpc.nNpcGroupID = nNpcGroupID;
				tbRateNpc.nRate       = nRate;
				table.insert(tbMapInfo.tbGroupNpc, tbRateNpc);
			end

		end

		tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame][tbMapInfo.nMapTID] = tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame][tbMapInfo.nMapTID] or {};
		table.insert(tbMainSetting[tbInfo.NpcType][tbInfo.TimeFrame][tbMapInfo.nMapTID], tbMapInfo);
		self.tbAllTMapSetting[tbMapInfo.nMapTID] = tbInfo.NpcType;
	end

	tbFileData = Lib:LoadTabFile("Setting/BossLeader/LinkMap.tab", {LinkMapID = 1, TotalMapCount = 1, MaxOneNpcCount = 1, TotalNpcCount = 1, TrueNpcCount = 1, TrueNpcGroupIndex = 1, FalseNpcGroupIndex = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbLinkMapSetting[tbInfo.LinkMapID] = tbInfo;
	end


	tbFileData = Lib:LoadTabFile("Setting/BossLeader/NpcGroup.tab", {GroupID = 1, NpcID = 1, NpcLevel = 1, PosX = 1, CalcValueType = 1, IsRecordDeath = 1, NpcMaxLife = 1,
		PosY = 1, Rate = 1, SoulStoneID = 1, PlayerAwardID = 1, ValueParam = 1, KinItemAwardID = 1, MJSoulStoneID = 1, IsFalse = 1, Mask = 1, ValueGroupID = 1,
		LastAwardID = 1, CallEventID = 1});

	for nRowIndex, tbInfo in pairs(tbFileData) do
		self.tbAllNpcGroup[tbInfo.GroupID] = self.tbAllNpcGroup[tbInfo.GroupID] or {};
		self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate = self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate or 0;
		self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc = self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc or {};
		self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate = self.tbAllNpcGroup[tbInfo.GroupID].nTotalRate + tbInfo.Rate;
		tbInfo.tbExtRandomItemID = {};
		for nI = 1, 5 do
			if not Lib:IsEmptyStr(tbInfo["ExtRandomItemID"..nI]) then
				tbInfo.tbExtRandomItemID[nI] = tonumber(tbInfo["ExtRandomItemID"..nI]);
			end
		end

		tbInfo.nRowIndex = nRowIndex;

		if MODULE_GAMECLIENT then
			table.insert(self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc, {
				NpcID = tbInfo.NpcID;
				NpcLevel = tbInfo.NpcLevel;
			});
		else
			table.insert(self.tbAllNpcGroup[tbInfo.GroupID].tbRateNpc, tbInfo);
			self.tbAllGroupNpcInfo[tbInfo.nRowIndex] = tbInfo;
		end

		tbInfo.tbLingPai = {};
		for i, szItemId in ipairs(Lib:SplitStr(tbInfo.LingPai, "|")) do
			if not tonumber(szItemId) then
				break;
			end
			tbInfo.tbLingPai[i] = tonumber(szItemId);
		end
	end


	tbFileData = Lib:LoadTabFile("Setting/BossLeader/FirstDmgAward.tab", {});
	for _, tbInfo in pairs(tbFileData) do
		local tbAllAward = {};
		tbAllAward.tbBoss = Lib:GetAwardFromString(tbInfo.BossAward);
		tbAllAward.tbLeader = Lib:GetAwardFromString(tbInfo.LeaderAward);
		self.tbAllFirstDmgAward[tbInfo.TimeFrame] = tbAllAward;
	end

	if not MODULE_GAMECLIENT then
		tbFileData = Lib:LoadTabFile("Setting/BossLeader/PlayerDmgRankAward.tab", {AwardID = 1, Rank = 1, Rate = 1, AuctionAwardCount = 1, AuctionAwardRate = 1});
		for _, tbInfo in pairs(tbFileData) do
			self.tbAllPlayerDmgRank[tbInfo.AwardID] = self.tbAllPlayerDmgRank[tbInfo.AwardID] or {};

			local tbAllAward = {};
			tbAllAward.tbAward = Lib:GetAwardFromString(tbInfo.Award);
            --@_@ 按照首领的伤害排名给倍数奖励
            for _, award in ipairs(tbAllAward.tbAward) do
                award[3] = #award >= 3 and award[3] * self.nItemAwardValueParam or self.nItemAwardValueParam;
            end
			tbAllAward.nRateAward = tbInfo.Rate;
			tbAllAward.tbRateAward = Lib:GetAwardFromString(tbInfo.AwardRate);
			tbAllAward.tbAuctionAward = Lib:GetAwardFromString(tbInfo.AuctionAward);
			tbAllAward.nAuctionAwardCount = tbInfo.AuctionAwardCount;
			tbAllAward.nAuctionAwardRate = tbInfo.AuctionAwardRate;
			self.tbAllPlayerDmgRank[tbInfo.AwardID][tbInfo.Rank] = tbAllAward;

			for _, tbAward in pairs(tbAllAward.tbAuctionAward) do
				assert(Player.AwardType[tbAward[1]] == Player.award_type_item, "auction only allow item");
			end
		end
	end

	tbFileData = Lib:LoadTabFile("Setting/BossLeader/ShowAward.tab", {ShowAwardID = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbShowAwardSetting[tbInfo.ShowAwardID] = {};
		self.tbShowAwardSetting[tbInfo.ShowAwardID].tbAllAward = {};
		--self.tbShowAwardSetting[tbInfo.ShowAwardID].szShowName = tbInfo.ShowName;

		for nI = 1, 20 do
			if not Lib:IsEmptyStr(tbInfo["Award"..nI]) then
			   local tbAllAward = Lib:GetAwardFromString(tbInfo["Award"..nI]);
			   table.insert(self.tbShowAwardSetting[tbInfo.ShowAwardID].tbAllAward, tbAllAward[1]);
			end
		end
	end

	tbFileData = LoadTabFile("Setting/BossLeader/KinItemAward.tab", "ddddd", nil, {"GroupID", "ItemID", "Rate", "WorldNotice", "KinNotice"});
	for _, tbInfo in pairs(tbFileData) do
		self.tbKinItemAwardSetting[tbInfo.GroupID] = self.tbKinItemAwardSetting[tbInfo.GroupID] or {};
		local tbKinItemAward = self.tbKinItemAwardSetting[tbInfo.GroupID];
		tbKinItemAward.tbAllItem = tbKinItemAward.tbAllItem or {};
		tbKinItemAward.nTotalRate = tbKinItemAward.nTotalRate or 0;
		tbKinItemAward.nTotalRate = tbKinItemAward.nTotalRate + tbInfo.Rate;
		table.insert(tbKinItemAward.tbAllItem, tbInfo);
	end

	local tbFileData = Lib:LoadTabFile("Setting/BossLeader/TimeFrameInfo.tab", {Cross = 1, BaoDiMJLingParam = 1, RandomSoulParam = 1, RandomMJStoneParam = 1, RandomMJLingParam = 1});
	if MODULE_GAMECLIENT then
		tbFileData = {};
	end
	for nRow, tbInfo in pairs(tbFileData) do
		tbInfo.tbNExtRandomParam = {};

		for nI = 1, 5 do
			local szExtName = string.format("ExtRandomItem%sParam", nI);
			if not Lib:IsEmptyStr(tbInfo[szExtName]) then
				tbInfo.tbNExtRandomParam[nI] = tonumber(tbInfo[szExtName]);
			end
		end

		tbInfo.tbCalcValue = {};
		for nI = 1, 10 do
			if not Lib:IsEmptyStr(tbInfo["RandomSoulParam"..nI]) or
			   not Lib:IsEmptyStr(tbInfo["RandomMJStoneParam"..nI]) or
			   not Lib:IsEmptyStr(tbInfo["RandomMJLingParam"..nI]) then
			   local tbValue = {};
			   tbValue.RandomSoulParam = tonumber(tbInfo["RandomSoulParam"..nI]);
			   tbValue.RandomMJStoneParam = tonumber(tbInfo["RandomMJStoneParam"..nI]);

			   tbValue.tbRandomMJLingParam = {};
			   for i, szRate in ipairs(Lib:SplitStr(tbInfo["RandomMJLingParam"..nI], "|")) do
					tbValue.tbRandomMJLingParam[i] = tonumber(szRate) or 0;
			   end

			   tbValue.tbExtRandomParam = {};
			   for nJ = 1, 5 do
					local szExtName = string.format("ExtRandomItem%sParam%s", nJ, nI);
					if not Lib:IsEmptyStr(tbInfo[szExtName]) then
						tbValue.tbExtRandomParam[nJ]  = tonumber(tbInfo[szExtName]);
					end
			   end

			   tbInfo.tbCalcValue[nI] = tbValue;
			end
		end

		tbInfo.tbBaoDiAward = {};
		for nI = 1, 5 do
			if not Lib:IsEmptyStr(tbInfo["BaoDiItemID"..nI]) or
			   not Lib:IsEmptyStr(tbInfo["BaoDiItemParam"..nI]) then
			   local tbBaoDi = {};
			   tbBaoDi.BaoDiItemID = tonumber(tbInfo["BaoDiItemID"..nI]);
			   tbBaoDi.BaoDiItemParam = tonumber(tbInfo["BaoDiItemParam"..nI]);
			   tbBaoDi.BaoDiItemWorldMsg = 0;
			   if not Lib:IsEmptyStr(tbInfo["BaoDiItemWorldMsg"..nI]) then
					tbBaoDi.BaoDiItemWorldMsg = tonumber(tbInfo["BaoDiItemWorldMsg"..nI]);
			   end

				tbBaoDi.BaoDiItemKinMsg = 0;
				if not Lib:IsEmptyStr(tbInfo["BaoDiItemKinMsg"..nI]) then
					tbBaoDi.BaoDiItemKinMsg = tonumber(tbInfo["BaoDiItemKinMsg"..nI]);
				end

			   table.insert(tbInfo.tbBaoDiAward, tbBaoDi);
			end
		end

		if tbInfo.Cross == 1 then
			self.tbCrossTimeFrameSetting[tbInfo.TimeFrame] = tbInfo;
		else
			self.tbTimeFrameSetting[tbInfo.TimeFrame] = tbInfo;
		end
	end


	local tbFileData = Lib:LoadTabFile("Setting/BossLeader/KinValueAward.tab", {GroupID = 1, ItemID = 1, Param = 1, NotSave = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbKinValueAward[tbInfo.GroupID] = self.tbKinValueAward[tbInfo.GroupID] or {};
		self.tbKinValueAward[tbInfo.GroupID][tbInfo.TimeFrame] = self.tbKinValueAward[tbInfo.GroupID][tbInfo.TimeFrame] or {};
		table.insert(self.tbKinValueAward[tbInfo.GroupID][tbInfo.TimeFrame], tbInfo);
	end

	local tbFileData = Lib:LoadTabFile("Setting/BossLeader/CrossKinJiFenNpc.tab", {NpcID = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbCrossKinJiFenNpc[tbInfo.TimeFrame] = self.tbCrossKinJiFenNpc[tbInfo.TimeFrame] or {};
		self.tbCrossKinJiFenNpc[tbInfo.TimeFrame][tbInfo.NpcID] = tbInfo;
	end

	local tbFileData = Lib:LoadTabFile("Setting/BossLeader/LastDmgPlayerAward.tab", {LastAwardID = 1});
	for _, tbInfo in pairs(tbFileData) do
		local tbLastAwardInfo = {};
		tbLastAwardInfo.tbAllAward = Lib:GetAwardFromString(tbInfo.AllAward);
		self.tbLastDmgPlayerAward[tbInfo.LastAwardID] = tbLastAwardInfo;
	end

	local tbFileData = Lib:LoadTabFile("Setting/BossLeader/CallEvent.tab", {CallEventID = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbCallEventSetting[tbInfo.CallEventID] = self.tbCallEventSetting[tbInfo.CallEventID] or {};
		self.tbCallEventSetting[tbInfo.CallEventID][tbInfo.Type] =  self.tbCallEventSetting[tbInfo.CallEventID][tbInfo.Type] or {};
		table.insert(self.tbCallEventSetting[tbInfo.CallEventID][tbInfo.Type], tbInfo);
	end
end

BossLeader:LoadSetting();

function BossLeader:GetKinItemAward(nGroupID)
	return self.tbKinItemAwardSetting[nGroupID];
end

function BossLeader:GetLinkMapInfo(nLinkID)
	if not nLinkID then
		return;
	end

	return self.tbLinkMapSetting[nLinkID];
end

function BossLeader:GetTimeFrameNpcGroup(szType)
	if not MODULE_ZONESERVER then
		local tbAllTimeNpc = self.tbMainSetting[szType];
		assert(tbAllTimeNpc, "GetTimeFrameNpcGroup Not Type" ..szType);
		local szCurTimeFrame = Lib:GetMaxTimeFrame(tbAllTimeNpc);
		return tbAllTimeNpc[szCurTimeFrame];
	end

	local szTimeFrame = self:GetCrossBossTimeFrame();
	return self.tbCrossMainSetting[szType][szTimeFrame];
end

function BossLeader:GetCrossTimeFrameNpcGroup(szType)
	local tbAllTimeNpc = self.tbCrossMainSetting[szType];
	if not tbAllTimeNpc then
		return;
	end

	local szTimeFrame = self:GetCrossBossTimeFrame() or Lib:GetMaxTimeFrame(tbAllTimeNpc);
	return tbAllTimeNpc[szTimeFrame];
end

function BossLeader:GetKinValueAward(nGroupID)
	local tbGroupAward = self.tbKinValueAward[nGroupID];
	if not tbGroupAward then
		return;
	end

	local szCurTimeFrame = Lib:GetMaxTimeFrame(tbGroupAward);
	return tbGroupAward[szCurTimeFrame];
end

function BossLeader:GetTimeFrameSetting()
	local tbTimeFrameSetting = self.tbTimeFrameSetting;
	if self.bCalcCross then
		tbTimeFrameSetting = self.tbCrossTimeFrameSetting;
	end

	local szCurTimeFrame = Lib:GetMaxTimeFrame(tbTimeFrameSetting);
	return tbTimeFrameSetting[szCurTimeFrame];
end

function BossLeader:GetGroupNpc(nGroupID)
	return self.tbAllNpcGroup[nGroupID] or {};
end

function BossLeader:GetGroupNpcInfoByIndex(nRowIndex)
	return self.tbAllGroupNpcInfo[nRowIndex];
end

function BossLeader:GetFirstDmgAward(szType)
	local szCurTimeFrame = Lib:GetMaxTimeFrame(self.tbAllFirstDmgAward);
	local tbAward =  self.tbAllFirstDmgAward[szCurTimeFrame];
	if not tbAward then
		return;
	end

	return tbAward["tb"..szType];
end

function BossLeader:GetShowAward(nShowAwardID)
	return self.tbShowAwardSetting[nShowAwardID];
end

function BossLeader:IsBossLeaderMap(nMapTID, szType)
	if not self.tbAllTMapSetting[nMapTID] then
		return false;
	end

	if szType and self.tbAllTMapSetting[nMapTID] ~= szType then
		return false;
	end

	return true;
end

function BossLeader:GetCrossKinJiFenNpc()
	local szCurTimeFrame = Lib:GetMaxTimeFrame(self.tbCrossKinJiFenNpc);
	return self.tbCrossKinJiFenNpc[szCurTimeFrame];
end

function BossLeader:GetPlayerBaseValue()
	local szTimeFrame = Lib:GetMaxTimeFrame(self.tbTimePlayerValue);
	local nPlayerBaseValue = self.tbTimePlayerValue[szTimeFrame] or 1;
	return nPlayerBaseValue;
end

function BossLeader:GetKinTimeDmgRankValue()
	local tbKinDmgRankValue = self.tbKinDmgRankValue;
	if self.bCalcCross then
		tbKinDmgRankValue = self.tbCrossKinDmgRankValue;
	end

	local szTimeFrame = Lib:GetMaxTimeFrame(tbKinDmgRankValue);
	if not szTimeFrame or szTimeFrame == "" then
		return;
	end

	local tbTimeDmgRankValue = tbKinDmgRankValue[szTimeFrame];
	return tbTimeDmgRankValue;
end

function BossLeader:GetLastPlayerAward(nLastAwardID)
	return self.tbLastDmgPlayerAward[nLastAwardID];
end

function BossLeader:GetCallEventInfo(nCallEventID, szType)
	local tbEventInfo = self.tbCallEventSetting[nCallEventID];
	if not tbEventInfo then
		return;
	end

	return tbEventInfo[szType];
end