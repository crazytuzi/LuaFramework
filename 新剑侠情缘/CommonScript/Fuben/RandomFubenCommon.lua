
Fuben.RandomFuben = Fuben.RandomFuben or {};
local RandomFuben = Fuben.RandomFuben;

-- 最多随机次数
RandomFuben.RANDOM_COUNT = 5;

-- 每场结束后等待传送时间
RandomFuben.AFTER_END_TIME = 10;

-- 副本结束后，自动踢出玩家时间
RandomFuben.MAX_DEALY_TIME = 180;

-- 每次死亡自动复活增加时间
RandomFuben.nReviveAddTime = 5;

-- 重伤状态
RandomFuben.DEATH_SKILLID = 1501;
-- 气绝状态
RandomFuben.DEATH_SKILLID2 = 1502
-- 最少进入玩家数量
RandomFuben.MIN_PLAYER_COUNT = 2;
-- 最多进入人数
RandomFuben.MAX_PLAYER_COUNT = 4;

RandomFuben.SAME_KIN_SCROE = 2;		-- 同家族加分

RandomFuben.KIN_NEWER_SCROE = 6;	-- 队伍有同家族见习成员加分

RandomFuben.MAX_FUBEN_LEVEL = 3;				-- 最大副本难度级数

RandomFuben.tbFriendLevelScroe =
{
-- 亲密度等级		增加积分
	{9, 			2},
	{99, 			4},
};

RandomFuben.tbTimeScroe =
{
	{460, 20},
	{480, 19},
	{500, 18},
	{520, 17},
	{540, 16},
	{560, 15},
	{580, 14},
	{600, 13},
	{620, 12},
	{640, 11},
	{660, 10},
}

RandomFuben.tbTeamLeaderExtAward = {
	[1] = 150;
	[2] = 120;
	[3] = 100;
	[4] = 80;
	[5] = 80;
	[6] = 80;
}

RandomFuben.tbExtMissAwardInfo =
{
	-- 普通模式通关奖励
	[1] = {
		[1] = {
			{"BasicExp", 120},
		},
		[2] = {
			{"BasicExp", 105},
		},
		[3] = {
			{"BasicExp", 90},
		},
		[4] = {
			{"BasicExp", 80},
		},
		[5] = {
			{"BasicExp", 70},
		},
		[6] = {
			{"BasicExp", 60},
		},
	};

	-- 噩梦模式通关奖励
	[2] = {
		[1] = {
			{"BasicExp", 120},
		},
		[2] = {
			{"BasicExp", 105},
		},
		[3] = {
			{"BasicExp", 90},
		},
		[4] = {
			{"BasicExp", 80},
		},
		[5] = {
			{"BasicExp", 70},
		},
		[6] = {
			{"BasicExp", 60},
		},
	};

	-- 苦痛模式通关奖励
	[3] = {
		[1] = {
			{"BasicExp", 120},
		},
		[2] = {
			{"BasicExp", 105},
		},
		[3] = {
			{"BasicExp", 90},
		},
		[4] = {
			{"BasicExp", 80},
		},
		[5] = {
			{"BasicExp", 70},
		},
		[6] = {
			{"BasicExp", 60},
		},
	};
}

function RandomFuben:LoadSettingInfo()
	local tbFile = LoadTabFile("Setting/Fuben/RandomFuben/FubenSetting.tab", "dssdd", nil, {"nFubenLevel", "szName", "szOpenTimeFrame", "nMinPlayerLevel", "nMinRoomLevel"});
	assert(tbFile);

	self.tbSetting = {};
	for _, tbRow in pairs(tbFile) do
		assert(not self.tbSetting[tbRow.nFubenLevel]);
		self.tbSetting[tbRow.nFubenLevel] = {
			szName = tbRow.szName;
			szOpenTimeFrame = tbRow.szOpenTimeFrame;
			nMinPlayerLevel = tbRow.nMinPlayerLevel;
			nMinRoomLevel = tbRow.nMinRoomLevel;
		};
	end

	local szType = "s";
	local tbType = {"szNumType"};
	for i = 1, RandomFuben.MAX_FUBEN_LEVEL do
		szType = szType .. "d";
		table.insert(tbType, tostring(i));
	end

	tbFile = LoadTabFile("Setting/Fuben/RandomFuben/NumSetting.tab", szType, nil, tbType);
	assert(tbFile);

	self.tbNumSetting = {};
	for _, tbRow in pairs(tbFile) do
		if tbRow.szNumType ~= "" then
			assert(not self.tbNumSetting[tbRow.szNumType]);
			self.tbNumSetting[tbRow.szNumType] = {};
			for i = 1, RandomFuben.MAX_FUBEN_LEVEL do
				self.tbNumSetting[tbRow.szNumType][i] = tbRow[tostring(i)];
			end
		end
	end
end
RandomFuben:LoadSettingInfo();

function RandomFuben:GetNumber(szType, nFubenLevel)
	local tbInfo = self.tbNumSetting[szType];
	assert(tbInfo and tbInfo[nFubenLevel], "" .. (szType or "nil") .. "  " .. (nFubenLevel or "nil"));
	return tbInfo[nFubenLevel];
end

function RandomFuben:GetFriendLevelScroe(nImityLevel)
	nImityLevel = nImityLevel or 0;
	if nImityLevel <= 0 then
		return 0;
	end

	local nScore = 0;
	for _, tbInfo in ipairs(self.tbFriendLevelScroe or {}) do
		nScore = tbInfo[2] or 0;
		if nImityLevel <= tbInfo[1] then
			break;
		end
	end

	return nScore;
end

function RandomFuben:CanEnterFubenCommon(pPlayer, nFubenLevel)
	local tbSetting = self.tbSetting[nFubenLevel];
	if not tbSetting then
		return false, "无此难度副本";
	end

	local szTimeFrame = tbSetting.szOpenTimeFrame;
	if GetTimeFrameState(szTimeFrame) ~= 1 then
		return false, "当前暂未开放";
	end

	if pPlayer.nLevel < tbSetting.nMinPlayerLevel then
		return false, string.format("等级不足%d，无法参加凌绝峰", tbSetting.nMinPlayerLevel);
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_RandomFuben) then
		return false, "当前状态不允许参加该活动";
	end

	return true;
end

function RandomFuben:CheckPlayerCanEnterFuben(pPlayer, nFubenLevel)
	local bResult, szMsg = self:CanEnterFubenCommon(pPlayer, nFubenLevel);
	if not bResult then
		return false, szMsg;
	end

	if DegreeCtrl:GetDegree(pPlayer, "RandomFuben") < 1 then
		return false, "凌绝峰次数不足";
	end

	local bRet, szMsg = pPlayer.CheckNeedArrangeBag();
	if bRet then
		return false, szMsg
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
		return false, "所在地图不允许进入";
	end

	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
		return false, "不在安全区，不允许进入";
	end

	return true;
end

function RandomFuben:CheckCanCreateFuben(pPlayer, nFubenLevel)
	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	if not tbMember or #tbMember <= 0 then
		tbMember = { pPlayer.dwID };
	end

	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if teamData and teamData.nCaptainID ~= pPlayer.dwID then
		return false, "只有队长才可以开启副本！";
	end

	if #tbMember < self.MIN_PLAYER_COUNT then
		return false, string.format("队伍人数不足 %d，无法开启副本！", self.MIN_PLAYER_COUNT), tbMember;
	end

	if #tbMember > self.MAX_PLAYER_COUNT then
		return false, string.format("队伍人数超过 %d，无法开启副本！", self.MAX_PLAYER_COUNT), tbMember;
	end

	for _, nPlayerId in pairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false, "未知队伍成员，无法开启副本！", tbMember;
		end

		local bRet, szMsg = self:CheckPlayerCanEnterFuben(pPlayer, nFubenLevel);
		if not bRet then
			return false, "「" .. pPlayer.szName .. "」" .. szMsg, tbMember;
		end
	end

	return true, "", tbMember
end

function RandomFuben:SaveLevel(nLevel)
	local tbInfo = Client:GetUserInfo("RandomFubenLevel", me.dwID);
	tbInfo.nLevel = nLevel;
	Client:SaveUserInfo();
end