local tbItem = Item:GetClass("CangBaoTu");
tbItem.TYPE_NORMAL = 1;
tbItem.TYPE_SENIOR = 2;
tbItem.TYPE_ONLYAWARD = 3; --只是挖出随机奖励

tbItem.PARAM_MAPID = 1;
tbItem.PARAM_POSX = 2;
tbItem.PARAM_POSY = 3;

tbItem.tbSetting = {}

tbItem.tbSetting[tbItem.TYPE_NORMAL] = {
	nWaBaoTime = 3, 				-- 挖宝读条时间
	CHANGE_MAP_RATE = 500,  		-- 一个地图挖宝次数达到最小次数时下个挖宝点切换地图的概率，以1000为分母
	MIN_POS_COUNT_ONE_MAP = 3,		-- 一个地图最小连续挖宝次数
	MAX_POS_COUNT_ONE_MAP = 5,		-- 一个地图内连续挖宝次数
}

tbItem.tbSetting[tbItem.TYPE_SENIOR] = {
	nWaBaoTime = 3, 				-- 挖宝读条时间
	CHANGE_MAP_RATE = 500,  		-- 一个地图挖宝次数达到最小次数时下个挖宝点切换地图的概率，以1000为分母
	MIN_POS_COUNT_ONE_MAP = 3,		-- 一个地图最小连续挖宝次数
	MAX_POS_COUNT_ONE_MAP = 5,		-- 一个地图内连续挖宝次数
}
tbItem.tbSetting[tbItem.TYPE_ONLYAWARD] =  Lib:CopyTB(tbItem.tbSetting[tbItem.TYPE_NORMAL])

local nSeniorUseLevel = 40;  --高级藏宝图使用等级

tbItem.nDungeonWaiteTime = 1;  --触发地宫延迟1秒进入
tbItem.nMinDungeonTimes = 15; -- 最少多少次出一次地宫
tbItem.tbDungeonRate = {
	{20, 5000},  --20级触发地宫的概率，十万分之
	{30, 5000},
	{40, 5000},
	{50, 5000},
	{60, 5000},
	{70, 5000},
	{80, 5000},
	{90, 5000},
	{150, 5000},  --地宫固定0.05的触发概率
};

tbItem.tbDungeonData = tbItem.tbDungeonData or {};

tbItem.MAX_DBZ_RATE = 100000;
tbItem.tbDBZRate =
{
	{59, 37660},  --59级及以下挖到“夺宝贼”的概率
	{69, 31920},  --60~69级挖到“夺宝贼”的概率
	{79, 31020},
	{89, 32700},
	{99, 32700},
	{109, 32700},
	{119, 31900},
}

tbItem.tbDBZOffsetPos =
{
	{3,0},
	{-3,0},
	{0,3},
	{0,-3},
	{6,0},
	{-6,0},
	{0,6},
	{0,-6},
	{3,3},
	{3,-3},
}

tbItem.nMinDBZCount = 8;				--盗宝贼最小数量
tbItem.nMaxDBZCount = 12;				--盗宝贼最大数量 nMaxDBZCount - 1

tbItem.tbDBZAward = tbItem.tbDBZAward or {};

tbItem.nDBZId = 1253;

tbItem.szDBZBlackMsg = "遭夺宝贼埋伏…";
tbItem.szBossBlackMsg = "不慎挖到野外首领的巢穴…";

tbItem.nNeedTeamate = 2 						-- 高级藏宝图需要的队友人数 >= nNeedTeamate
tbItem.tbAssistAward = {{"Contrib", 100}} 		-- 队友协助挖宝的奖励

--Boss触发概率
tbItem.nBossRate = 50
tbItem.nBossTotalRate = 1000
tbItem.szBossType = "CangBaoTuBoss"

tbItem.BossOffsetPos =  						-- Boss出现的位置偏移(相对玩家位置)
{
	{-5,-5},
}

tbItem.SeniorCanBaoTuImitity = 20  --高级藏宝图加亲密度

tbItem.SAVE_GROUP = 180
tbItem.Continue_DBZ = 1 			-- 连续出现夺宝贼
tbItem.ItemGungeon_Count = 11 		-- 每天进入随机地宫的次数
tbItem.ItemGungeon_Count = 12 		-- 每天进入随机地宫的次数更新时间

tbItem.szItemDungeonTimeFrame = "OpenLevel109"

tbItem.Floor1_Normal = 1 			-- 普通触发地宫的第一层类型
tbItem.Floor1_ItemDungeon = 2 		-- 使用道具触发地宫的第一层类型

function tbItem:LoadSetting()
	local tbNormalFile = LoadTabFile("Setting/CangBaoTu/CangBaoTu.tab", "dddd", nil, {"nLevel", "MapTemplateId", "X", "Y"});
	local tbSeniorFile = LoadTabFile("Setting/CangBaoTu/SeniorCangBaoTu.tab", "dddd", nil, {"nLevel", "MapTemplateId", "X", "Y"});
	local tbDBZAward   = LoadTabFile("Setting/CangBaoTu/DuoBaoZeiAward.tab", "dsdd", "AwardID", {"AwardID", "Award", "Rate","Level"});

	self.tbAllPos = {};
	self.tbAllPos[self.TYPE_NORMAL] = {};
	self.tbAllPos[self.TYPE_SENIOR] = {};
	self.tbAllPos[self.TYPE_ONLYAWARD] = {};

	self.tbLevel = {}
	self.tbLevel[self.TYPE_NORMAL] = {};
	self.tbLevel[self.TYPE_SENIOR] = {};

	for _, tbRow in pairs(tbNormalFile) do
		self.tbLevel[self.TYPE_NORMAL].nMinLevel = math.min(tbRow.nLevel, self.tbLevel[self.TYPE_NORMAL].nMinLevel or 999);
		self.tbAllPos[self.TYPE_NORMAL][tbRow.MapTemplateId] = self.tbAllPos[self.TYPE_NORMAL][tbRow.MapTemplateId] or {};
		self.tbAllPos[self.TYPE_NORMAL][tbRow.MapTemplateId].nLevel = tbRow.nLevel;
		table.insert(self.tbAllPos[self.TYPE_NORMAL][tbRow.MapTemplateId], {tbRow.MapTemplateId, tbRow.X, tbRow.Y});
	end

	for _, tbRow in pairs(tbSeniorFile) do
		self.tbLevel[self.TYPE_SENIOR].nMinLevel = math.min(tbRow.nLevel, self.tbLevel[self.TYPE_SENIOR].nMinLevel or 999);
		self.tbAllPos[self.TYPE_SENIOR][tbRow.MapTemplateId] = self.tbAllPos[self.TYPE_SENIOR][tbRow.MapTemplateId] or {};
		self.tbAllPos[self.TYPE_SENIOR][tbRow.MapTemplateId].nLevel = tbRow.nLevel;
		table.insert(self.tbAllPos[self.TYPE_SENIOR][tbRow.MapTemplateId], {tbRow.MapTemplateId, tbRow.X, tbRow.Y});
	end

	self.tbLevel[self.TYPE_ONLYAWARD] = Lib:CopyTB(self.tbLevel[self.TYPE_NORMAL])
	self.tbAllPos[self.TYPE_ONLYAWARD] = Lib:CopyTB(self.tbAllPos[self.TYPE_NORMAL])

	for nAwardID,tbRow in ipairs(tbDBZAward) do
		self.tbDBZAward[nAwardID] = self.tbDBZAward[nAwardID] or {};
		self.tbDBZAward[nAwardID].nAwardID = tbRow.AwardID
		self.tbDBZAward[nAwardID].tbAward = Lib:GetAwardFromString(tbRow.Award);
		self.tbDBZAward[nAwardID].nRate = tbRow.Rate;
		self.tbDBZAward[nAwardID].nLevel = tbRow.Level;
	end

end

tbItem:LoadSetting();

function tbItem:OnCreate(it)

end

function tbItem:OnNotifyItem(pPlayer,it,tbMsg)

	if not tbMsg then
		return
	end

	if not it.GetIntValue(self.PARAM_MAPID) == 0 then
		return
	end

	local nMapTemplateId = tbMsg.nMapTemplateId
	local nPosX = tbMsg.nPosX
	local nPosY = tbMsg.nPosY
	local nItemType = tbMsg.nItemType

	if not nItemType or not nMapTemplateId or not nPosX or not nPosY then
		return
	end

	if not self.tbAllPos[nItemType] or not self.tbAllPos[nItemType][nMapTemplateId] then
		return;
	end

	if not self:Islegal(nItemType,nMapTemplateId, nPosX, nPosY,pPlayer) then
		self:RandomPos(it,pPlayer)
	else
		it.SetIntValue(self.PARAM_MAPID, nMapTemplateId);
		it.SetIntValue(self.PARAM_POSX, nPosX);
		it.SetIntValue(self.PARAM_POSY, nPosY);
	end
end

function tbItem:GetTip(it)
	if not it.dwId then
		return "";
	end

	local nItemType =  KItem.GetItemExtParam(it.dwTemplateId, 2);

	local nMapTemplateId,nPosX,nPosY = 0,0,0

	if it.GetIntValue(self.PARAM_MAPID) == 0 then
		nMapTemplateId,nPosX,nPosY = self:RandomPos(it,me)
		local tbMsg =
		{
			nItemType = nItemType,
			nMapTemplateId = nMapTemplateId,
			nPosX = nPosX,
			nPosY = nPosY,
		}
		RemoteServer.NotifyItem(it.dwId,tbMsg)
	else
		nMapTemplateId,nPosX,nPosY = self:GetCangBaoTuPos(it)
	end

	if not nMapTemplateId then
		Log("CangBaoTu GetTip nMapTemplateId is null!!",nMapTemplateId)
		return "";
	end
	local tbMapSetting = Map:GetMapSetting(nMapTemplateId);
	if not tbMapSetting then
		Log("CangBaoTu GetTip tbMapSetting is null!!",tbMapSetting)
		return "";
	end

	local szTip = ""
	if me.nLevel >= nSeniorUseLevel or nItemType ~= self.TYPE_SENIOR then
		szTip = szTip ..string.format("藏宝点：%s(%s, %s)\n", tbMapSetting.MapName, math.floor(nPosX * Map.nShowPosScale), math.floor(nPosY * Map.nShowPosScale));
	end

	if nItemType == self.TYPE_SENIOR then
		szTip = szTip ..string.format("等级要求：%d级",nSeniorUseLevel);
	end
	return szTip
end

function tbItem:RandomPosFromType(pItem, pPlayer, nItemType)
	local nLevel = pPlayer and pPlayer.nLevel or self.tbLevel[nItemType].nMinLevel;
	-- 高级藏宝图等级不够打开界面的时候random
	nLevel = nLevel < self.tbLevel[nItemType].nMinLevel and self.tbLevel[nItemType].nMinLevel or nLevel

	local tbCurInfo = {tbUsedMap = {}};
	if pPlayer and pPlayer.tbCangBatoTuInfo and pPlayer.tbCangBatoTuInfo[nItemType] then
		tbCurInfo = pPlayer.tbCangBatoTuInfo[nItemType]
	end

	local tbPosInfo = {};
	local nTotalCount = 0;
	if tbCurInfo.nMapTemplateId then
		tbPosInfo = {self.tbAllPos[nItemType][tbCurInfo.nMapTemplateId]};
		nTotalCount = #self.tbAllPos[nItemType][tbCurInfo.nMapTemplateId];
	else
		for nMapTemplateId, tbInfo in pairs(self.tbAllPos[nItemType]) do
			if not tbCurInfo.tbUsedMap[nMapTemplateId] and nLevel >= tbInfo.nLevel then
				table.insert(tbPosInfo, tbInfo);
				nTotalCount = nTotalCount + #tbInfo;
			end
		end
	end

	local nRandom = MathRandom(nTotalCount);
	local tbPos = nil;
	for _, tbInfo in pairs(tbPosInfo) do
		tbPos = tbInfo[nRandom];
		if tbPos then
			break;
		end

		nRandom = nRandom - #tbInfo;
	end

	if MODULE_GAMESERVER then
		pItem.SetIntValue(self.PARAM_MAPID, tbPos[1]);
		pItem.SetIntValue(self.PARAM_POSX, tbPos[2]);
		pItem.SetIntValue(self.PARAM_POSY, tbPos[3]);
	end

	return tbPos[1],tbPos[2],tbPos[3]
end

function tbItem:RandomPos(pItem, pPlayer)
	local nItemType =  KItem.GetItemExtParam(pItem.dwTemplateId, 2);
	return self:RandomPosFromType(pItem, pPlayer, nItemType)
end

function tbItem:GetCangBaoTuPos(pItem)
	local nMapTemplateId = pItem.GetIntValue(self.PARAM_MAPID);
	local nPosX = pItem.GetIntValue(self.PARAM_POSX);
	local nPosY = pItem.GetIntValue(self.PARAM_POSY);
	return nMapTemplateId, nPosX, nPosY;
end

function tbItem:CheckCanWaBao(pPlayer, nItemId)
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem or pItem.szClass ~= "CangBaoTu" then
		return false, "咦，藏宝图呢！";
	end

	local nMapTemplateId, nPosX, nPosY = self:GetCangBaoTuPos(pItem);
	local nMpaId, nX, nY = pPlayer.GetWorldPos();
	if pPlayer.nMapTemplateId ~= nMapTemplateId or math.abs(nPosX - nX) > 100 or math.abs(nPosY - nY) > 100 then
		return false, "此处没有宝藏，换个地方试试吧！";
	end

	return true, szMsg, pItem;
end

function tbItem:RecordPlayerInfo(pPlayer,nItemType)
	if not self.tbAllPos[nItemType][pPlayer.nMapTemplateId] then
		return;
	end
	pPlayer.tbCangBatoTuInfo = pPlayer.tbCangBatoTuInfo or {}
	pPlayer.tbCangBatoTuInfo[nItemType] = pPlayer.tbCangBatoTuInfo[nItemType] or {tbUsedMap = {}};
	if not pPlayer.tbCangBatoTuInfo[nItemType].nMapTemplateId or pPlayer.tbCangBatoTuInfo[nItemType].nMapTemplateId ~= pPlayer.nMapTemplateId then
		pPlayer.tbCangBatoTuInfo[nItemType].nMapTemplateId = pPlayer.nMapTemplateId;
		pPlayer.tbCangBatoTuInfo[nItemType].nCurCount = 0;
	end

	pPlayer.tbCangBatoTuInfo[nItemType].nCurCount = pPlayer.tbCangBatoTuInfo[nItemType].nCurCount + 1;

	if pPlayer.tbCangBatoTuInfo[nItemType].nCurCount < self.tbSetting[nItemType].MIN_POS_COUNT_ONE_MAP then
		return;
	end

	if pPlayer.tbCangBatoTuInfo[nItemType].nCurCount < self.tbSetting[nItemType].MAX_POS_COUNT_ONE_MAP then
		if MathRandom(1000) <= self.tbSetting[nItemType].CHANGE_MAP_RATE then
			return;
		end
	end

	pPlayer.tbCangBatoTuInfo[nItemType].nMapTemplateId = nil;
	pPlayer.tbCangBatoTuInfo[nItemType].nCurCount = nil;
	pPlayer.tbCangBatoTuInfo[nItemType].tbUsedMap[pPlayer.nMapTemplateId] = 1;

	local nCanUseMapCount = 0;
	for _, tbInfo in pairs(self.tbAllPos[nItemType]) do
		if pPlayer.nLevel >= tbInfo.nLevel then
			nCanUseMapCount = nCanUseMapCount + 1;
		end
	end

	if Lib:CountTB(pPlayer.tbCangBatoTuInfo[nItemType].tbUsedMap) >= nCanUseMapCount then
		pPlayer.tbCangBatoTuInfo[nItemType].tbUsedMap = {};
	end
end

function tbItem:CheckDungeon(pPlayer)
	tbItem.tbDungeonData[me.dwID] = tbItem.tbDungeonData[me.dwID] or {nCurTimes = 0};
	local tbDData = tbItem.tbDungeonData[me.dwID];
	if tbDData.nCurTimes >= tbItem.nMinDungeonTimes then
		tbDData.nCurTimes = 0;
		tbDData.bHasDungeon = false;
	end
	tbDData.nCurTimes = tbDData.nCurTimes + 1;

	if tbDData.bHasDungeon then
		return;
	end

	local nRate = 0;
	for _, tbInfo in pairs(self.tbDungeonRate) do
		nRate = tbInfo[2];
		if pPlayer.nLevel <= tbInfo[1] then
			break;
		end
	end

	if MathRandom(100000) > nRate then
		return;
	end

	tbDData.bHasDungeon = true;
	local fnCallBack = function (dwRoleId)
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if not pPlayer then
			return;
		end
		Fuben.DungeonFubenMgr:CreateFuben(pPlayer, true);
	end

	local nMapId, nX, nY = pPlayer.GetWorldPos();
	pPlayer.CallClientScript("Ui:PlayEffect", 9013, nX, nY, 0);
	Timer:Register(Env.GAME_FPS * self.nDungeonWaiteTime + 1, fnCallBack, pPlayer.dwID);
	return true;
end


function tbItem:CheckDaoBaoZei(pPlayer)

	local nRate = 0;

	for _, tbInfo in ipairs(self.tbDBZRate) do
		nRate = tbInfo[2];
		if pPlayer.nLevel <= tbInfo[1] then
			break;
		end
	end
	local nHit =MathRandom(self.MAX_DBZ_RATE)

	if nHit > nRate then
		return;
	end

	self:RandomDBZ(pPlayer);

	return true;
end

function tbItem:RandomDBZ(pPlayer)
	local nCount = math.floor(MathRandom(self.nMinDBZCount,self.nMaxDBZCount));
	local nMapID,nPox,nPoy = pPlayer.GetWorldPos();
	for i=1,nCount do
		local tbOffsetPos = self.tbDBZOffsetPos[i] or {0,0};
		KNpc.Add(self.nDBZId, pPlayer.nLevel, 1, nMapID, nPox + tbOffsetPos[1], nPoy + tbOffsetPos[2], 0);
	end
end

function tbItem:GetDBZAwardInfo(nLevel)
	local nAwardLevel = 0
	for _,tbInfo in ipairs(self.tbDBZAward) do
		if nLevel <= tbInfo.nLevel then
			nAwardLevel = tbInfo.nLevel
			break;
		else
			nAwardLevel = tbInfo.nLevel
		end
	end

	local tbAwardInfo = {}
	local nTotalRate = 0
	for _,tbInfo in pairs(self.tbDBZAward) do
		if nAwardLevel == tbInfo.nLevel then
			nTotalRate = nTotalRate + tbInfo.nRate
			table.insert(tbAwardInfo,tbInfo)
		end
	end

	return tbAwardInfo,nTotalRate
end

function tbItem:RandomDBZAward(nLevel)
	local tbAwardInfo,nTotalRate = self:GetDBZAwardInfo(nLevel);
	if not next(tbAwardInfo) then
		return
	end

	local nHit = MathRandom(1,nTotalRate);
	local tbAward = {}
	for _,tbRow in ipairs(tbAwardInfo) do
		if tbRow.nRate >= nHit then
			tbAward = tbRow.tbAward
			break;
		else
			nHit = nHit - tbRow.nRate;
		end
	end

	return tbAward;
end

function tbItem:OnEndProgress(nItemId)
	self:UpdateHeadState(me, false);
	local bRet, szMsg, pItem = self:CheckCanWaBao(me, nItemId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	bRet = false;
	local szName = pItem.szName;
	local nCount = pItem.nCount;
	local nItemDwId = pItem.dwId;
	local nRandomByLevelKindId = pItem.nRandomByLevelKindId;
	local ndwTemplateId = pItem.dwTemplateId;
	local nParamId = nRandomByLevelKindId or KItem.GetItemExtParam(ndwTemplateId, 1);
	local nItemType =  KItem.GetItemExtParam(ndwTemplateId, 2);

	if nItemType == self.TYPE_SENIOR then 								-- 读条后判断
		local bAllReady,szTips = self:CheckTeamMember(pItem)
		if not bAllReady then
			me.CenterMsg(szTips);
			return
		end
	end

	local nConsumeCount = me.ConsumeItem(pItem, 1, Env.LogWay_CangBaoTuWaBao); -- 这里逻辑上比较危险，防止刷，所以不管成功失败，都扣除藏宝图，有问题了再补
	if nConsumeCount ~= 1 then
		Log("tbItem:OnEndProgress ConsumeItem fail",nItemType,ndwTemplateId,nConsumeCount);
		return
	end

	if self.TYPE_NORMAL == nItemType then
		bRet = self:CheckDungeon(me);
	elseif self.TYPE_SENIOR == nItemType then
		self:AddImitity()
		bRet = self:CheckBoss()
		if not bRet then
			bRet = self:CheckDaoBaoZei(me);
			if bRet then
				Achievement:AddCount(me, "HighCangbaotu_2", 1);			--被围攻了
				Dialog:SendBlackBoardMsg(me, self.szDBZBlackMsg);
				local nContinue = me.GetUserValue(self.SAVE_GROUP, self.Continue_DBZ);
				nContinue = nContinue + 1
				me.SetUserValue(self.SAVE_GROUP, self.Continue_DBZ, nContinue);
				if nContinue >= 3 then
					Achievement:AddCount(me, "HighCangbaotu_3thieves", 1);
				end
				if nContinue >= 5 then
					Achievement:AddCount(me, "HighCangbaotu_5thieves", 1);
				end
			else
				me.SetUserValue(self.SAVE_GROUP, self.Continue_DBZ, 0);
			end
		end
	end

	if not bRet then 						-- 没有触发事件
		local nRet, szMsg, tbAllAward,tbAdd2AuctionIndex = Item:GetClass("RandomItemByLevel"):GetAwardListByLevel(me.nLevel, nParamId, szName, me)

		if nRet ~= 1 then
			me.CenterMsg("咦，挖宝失败了！");
			return;
		end

		local tbAllAwardWithOpen = {}
		local tbAllAuctionAward = {}
		if tbAdd2AuctionIndex and next(tbAdd2AuctionIndex) then
			tbAllAward,tbAllAuctionAward = self:Add2PersonAuction(tbAllAward,tbAdd2AuctionIndex)
		end

		local tbAllAuctionAward2 = {}
		local tbAdd2AuctionIndex2 = {}
		tbAllAward,tbAdd2AuctionIndex2 = KPlayer:FormatAward(me, tbAllAward, szName);
		if tbAdd2AuctionIndex2 and next(tbAdd2AuctionIndex2) then
			tbAllAward,tbAllAuctionAward2 = self:Add2PersonAuction(tbAllAward,tbAdd2AuctionIndex2)
		end

		tbAllAward = KPlayer:MgrAward(me, tbAllAward);

		me.SendAward(tbAllAward, nil,nil, Env.LogWay_CangBaoTuWaBao)

		tbAllAwardWithOpen = Lib:MergeTable(tbAllAuctionAward, tbAllAward)
		tbAllAwardWithOpen = Lib:MergeTable(tbAllAuctionAward2, tbAllAwardWithOpen)

		if self.TYPE_NORMAL == nItemType then
			for _, tbAward in pairs(tbAllAwardWithOpen or {}) do
				if tbAward[1] and Player.AwardType[tbAward[1]] and Player.AwardType[tbAward[1]] == Player.award_type_item then
					local nItemId = tbAward[2];
					if nItemId == 792 then -- 古旧的宝箱
						Achievement:AddCount(me, "Cangbaotu_2", 1);
					end
					local tbBaseInfo = KItem.GetItemBaseProp(nItemId);
					if tbBaseInfo.nQuality >= 3 then
						Achievement:AddCount(me, "Cangbaotu_3", 1);
					end
				end
			end
		elseif self.TYPE_SENIOR == nItemType then

			self:SendTeamAssistAward()

			for _, tbAward in pairs(tbAllAwardWithOpen or {}) do
				if tbAward[1] and Player.AwardType[tbAward[1]] and Player.AwardType[tbAward[1]] == Player.award_type_item then
					local nItemId = tbAward[2];
					if nItemId == 1430 or nItemId == 1431 or nItemId == 1432 then
						Achievement:AddCount(me, "HighCangbaotu_3", 1);					-- 武林秘籍
					end

					local tbBaseInfo = KItem.GetItemBaseProp(nItemId);
					if tbBaseInfo.szClass == "PartnerWeapon" then
						Achievement:AddCount(me, "HighCangbaotu_4", 1);
					end
				end
			end
		end
	end

	if self.TYPE_NORMAL == nItemType then
		Achievement:AddCount(me, "Cangbaotu_1", 1);							-- 进行一次挖宝
		EverydayTarget:AddCount(me, "CangBaoTu");							-- 挖宝每日目标
		TeacherStudent:TargetAddCount(me, "DigGoods", 1)
	elseif self.TYPE_SENIOR == nItemType then
		Achievement:AddCount(me, "HighCangbaotu_1", 1);						-- 进行一次高级挖宝
	end

	self:RecordPlayerInfo(me,nItemType);

	if (bRet and self.TYPE_NORMAL == nItemType) or nCount <= 1 then
		me.CallClientScript("Ui:CloseWindow", "QuickUseItem");
	else
		self:RandomPos(pItem, me);
		me.CallClientScript("Ui:OpenQuickUseItem", nItemDwId, "使  用");
		if self.TYPE_NORMAL == nItemType then
			me.CallClientScript("CangBaoTu:UseItem", nItemDwId);
		end
	end

	-- LogD(Env.LOGD_ActivityPlay, me.szAccount, me.dwID, me.nLevel, "Cangbaotu", Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_CANBAOTU, nil);
	me.TLogRoundFlow(Env.LogWay_CangBaoTuWaBao, nItemType, 0, 0, Env.LogRound_SUCCESS, 0, 0);

	AssistClient:ReportQQScore(me, Env.QQReport_IsJoinCangBaoTu, 1, 0, 1)
end

function tbItem:Add2PersonAuction(tbAllAward,tbAdd2AuctionIndex)

    local tbAllAuctionAward = {}
    local tbAuctionAward = {}

    tbAllAward,tbAuctionAward = Kin:FormatAuctionItem(tbAllAward,tbAdd2AuctionIndex,tbAuctionAward)
    if tbAuctionAward and next(tbAuctionAward) then
        Kin:AddPersonAuction(me.dwID, tbAuctionAward)
        for _,tbAward in pairs(tbAuctionAward) do
            local tbItem = {"item",tbAward[1],tbAward[2]}
            table.insert(tbAllAuctionAward,tbItem)
        end
    end

    return tbAllAward,tbAllAuctionAward
end

function tbItem:AddImitity()

	if not me.dwTeamID or me.dwTeamID == 0 then
		return ;
	end

	local tbMember = TeamMgr:GetMembers(me.dwTeamID)
    if not next(tbMember) then
        return ;
    end

    for _,dwID in pairs(tbMember) do
    	if dwID ~= me.dwID then
    		local bIsFriend = FriendShip:IsFriend(me.dwID, dwID)
    		if bIsFriend then
    		   FriendShip:AddImitity(me.dwID, dwID, self.SeniorCanBaoTuImitity, Env.LogWay_CangBaoTuWaBao);
    		end
    	end
    end
end

function tbItem:CheckBoss()
	local nHit = MathRandom(self.nBossTotalRate)
	if nHit <= self.nBossRate then
		-- 刷Boss
		local nMapTemplateId, nPosX, nPosY = me.GetWorldPos();
		RandomBoss:CreateAllNpcGroup(self.szBossType)
		local tbOffsetPos = self.BossOffsetPos[1] or {0,0}
		local bRet = RandomBoss:RandomOneBoss(nMapTemplateId, nPosX + tbOffsetPos[1], nPosY + tbOffsetPos[2],self.szBossType)
		if not bRet then
			Log("player random cangbaotuboss fail!!",me.dwID,nMapTemplateId, nPosX, nPosY)
			return
		end
		Achievement:AddCount(me, "HighCangbaotu_5", 1);
		Dialog:SendBlackBoardMsg(me, self.szBossBlackMsg);
		return true
	end
end

-- 发送队友的协助挖宝奖励
function tbItem:SendTeamAssistAward()
	local nTeamID = me.dwTeamID
    if not nTeamID or nTeamID == 0 then
        return
    end

    local tbMember = TeamMgr:GetMembers(nTeamID)
    if not next(tbMember) then
        return
    end

    for _,dwID in pairs(tbMember) do
        if dwID ~= me.dwID then
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer then
                pPlayer.SendAward(self.tbAssistAward, true, nil, Env.LogWay_DaoBaoZaiAward);
            end
        end
    end
end

function tbItem:OnBreakProgress(nItemId)
	me.CallClientScript("Ui:OpenQuickUseItem", nItemId, "使  用");
	self:UpdateHeadState(me, false);
end

function tbItem:Islegal(nItemType,nMapTemplateId, nPosX, nPosY,pPlayer)
	if not self.tbAllPos[nItemType][nMapTemplateId] then
		if pPlayer.tbCangBatoTuInfo and pPlayer.tbCangBatoTuInfo[nItemType] then
			pPlayer.tbCangBatoTuInfo[nItemType] = nil
		end
		return false
	end

	if not self.tbAllPos[nItemType][nMapTemplateId].nLevel or self.tbAllPos[nItemType][nMapTemplateId].nLevel > pPlayer.nLevel then
		return false
	end

	for nIndex,tbPos in ipairs(self.tbAllPos[nItemType][nMapTemplateId]) do
        if tbPos[2] and tbPos[3] and tbPos[2] == nPosX and tbPos[3] == nPosY then
        	return true
        end
    end

    return false
end

function tbItem:OnUse(it)

	if not it.dwTemplateId then
		return
	end

	local nItemType =  KItem.GetItemExtParam(it.dwTemplateId, 2);
	if nItemType == self.TYPE_SENIOR then
		if me.nLevel < nSeniorUseLevel then
			me.CenterMsg(string.format("少侠阅历尚浅，需要等级达到%d级",nSeniorUseLevel))
			return
		end

		local bAllReady,szTips = self:CheckTeamMember(it,true) 				-- 使用前判断
		if not bAllReady then
			me.CenterMsg(szTips);
			return
		end
		    end

	local bRet, szMsg = me.CheckNeedArrangeBag();
	if bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local nMapTemplateId, nPosX, nPosY = self:GetCangBaoTuPos(it);
	if not self:Islegal(nItemType,nMapTemplateId, nPosX, nPosY,me) then
		self:RandomPos(it, me);
		nMapTemplateId, nPosX, nPosY = self:GetCangBaoTuPos(it);
	end

	local bRet, szMsg = self:CheckCanWaBao(me, it.dwId);

	if not bRet then
		-- 有时候道具intvalue 会同步失败，但是只能在手机重现 先临时这样处理掉这个BUG
		it.SetIntValue(self.PARAM_MAPID, nMapTemplateId);
		it.SetIntValue(self.PARAM_POSX, nPosX);
		it.SetIntValue(self.PARAM_POSY, nPosY);
		me.CallClientScript("CangBaoTu:OnUseItem", it.dwId, nMapTemplateId, nPosX, nPosY);
		return;
	end

	local nItemtype= KItem.GetItemExtParam(it.dwTemplateId, 2);

	if nItemtype == self.TYPE_SENIOR then 								-- 读条前判断
		local bAllReady,szTips = self:CheckTeamMember(it)
		if not bAllReady then
			me.CenterMsg(szTips);
			me.CallClientScript("Ui:OpenQuickUseItem", it.dwId, "使  用");
			return
		end
	end
	self:UpdateHeadState(me, true, self.tbSetting[nItemtype].nWaBaoTime);
	GeneralProcess:StartProcessExt(me, self.tbSetting[nItemtype].nWaBaoTime * Env.GAME_FPS, true, 0, 0, "挖宝中", {self.OnEndProgress, self, it.dwId}, {self.OnBreakProgress, self, it.dwId});
	return 0;
end

function tbItem:CheckTeamMember(it,bCheckCommon)

	if not me.dwTeamID or me.dwTeamID == 0 then
		return false,string.format("需%s人以上组队前往挖宝",self.nNeedTeamate);
	end

	local tbMember = TeamMgr:GetMembers(me.dwTeamID)
	if not next(tbMember) then
		return false,"有队友才能挖宝";
	end
	if Lib:CountTB(tbMember) < self.nNeedTeamate then
		return false,string.format("需%s人以上组队前往挖宝",self.nNeedTeamate);
	end

	if bCheckCommon then
		return true
	end

	local nMapTemplateId = self:GetCangBaoTuPos(it);
	local nMapMemberCount = 0
	for _,dwID in pairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer and pPlayer.nMapId == nMapTemplateId then
			nMapMemberCount = nMapMemberCount + 1
		end
	end

	if nMapMemberCount < Lib:CountTB(tbMember) then
		return false,"所有队员到齐后再挖吧"
	end

	return true
end

function tbItem:UpdateHeadState(pPlayer, bAdd, nWaBaoTime)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
    	return;
    end

    if bAdd then
		pNpc.AddSkillState(Player.tbHeadStateBuff.nWaBaoID, 1, FightSkill.STATE_TIME_TYPE.state_time_normal, nWaBaoTime * Env.GAME_FPS, 0, 1);
	else
		pNpc.RemoveSkillState(Player.tbHeadStateBuff.nWaBaoID);
	end

    pPlayer.CallClientScript("Player:UpdateHeadState", bAdd);
end
