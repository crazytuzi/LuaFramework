MissionAward = MissionAward or {};

MissionAward.MAX_RECORD_COUNT = 5;			-- 最多记录事后奖励次数

MissionAward.MAX_FREE_COUNT = 1;			-- 免费抽奖次数
MissionAward.MAX_REAL_ITEM_COUNT = 5;		-- 真道具数量，也就是最大抽奖次数
MissionAward.MAX_ITEM_COUNT = 16;			-- 总格子数

MissionAward.emType_TeamFuben = 1;
MissionAward.emType_RandomFuben = 2;

-- 付费次数消耗道具和元宝数量
MissionAward.tbConsumeInfo =
{
	[MissionAward.emType_TeamFuben] = {10, 20, 30, 40},
	[MissionAward.emType_RandomFuben] = {10, 20, 30, 40},
};

MissionAward.tbGradeInfo =
{
	[1] = "SSS",
	[2] = "SS",
	[3] = "S",
	[4] = "A",
	[5] = "B",
	[6] = "C",
	[7] = "D",
}

MissionAward.tbGradeDesc =
{
	["SSS"] = "卓越";
	["SS"] = "杰出";
	["S"] = "优秀";
	["A"] = "良好";
	["B"] = "平庸";
	["C"] = "略逊";
	["D"] = "见绌";
};

MissionAward.tbMissionName =
{
	[MissionAward.emType_TeamFuben] = "组队秘境";
	[MissionAward.emType_RandomFuben] = "随机秘境";
};

MissionAward.tbAllGradeInfo =
{
	[MissionAward.emType_TeamFuben] = {
		[1] = 120,			-- SSS
		[2] = 110,			-- SS
		[3] = 100,			-- S
		[4] = 80,			-- A
		[5] = 40,			-- B
		[6] = 0,			-- C
	},
	[MissionAward.emType_RandomFuben] = {
		[1] = 120,			-- SSS
		[2] = 110,			-- SS
		[3] = 100,			-- S
		[4] = 80,			-- A
		[5] = 40,			-- B
		[6] = 0,			-- C
	},
};

MissionAward.tbAllRandomCount = {
	[MissionAward.emType_RandomFuben] = {
		[1] = 5,
		[2] = 4,
		[3] = 3,
		[4] = 2,
		[5] = 1,
		[6] = 1,
		[7] = 1,
	},
};

--亲密度
MissionAward.tbAddFriendImityInfo = {
	[MissionAward.emType_RandomFuben] = {
		[1] = 70,
		[2] = 60,
		[3] = 50,
		[4] = 40,
		[5] = 30,
		[6] = 20,
	},

	[MissionAward.emType_TeamFuben] = {
		[1] = 70,
		[2] = 60,
		[3] = 50,
		[4] = 40,
		[5] = 30,
		[6] = 20,
	},
}

MissionAward.tbAwardFile =
{
	[MissionAward.emType_RandomFuben] = "Setting/MissionAward/RandomFuben.tab",
}

function MissionAward:GetConsumeInfo(nType, nAwardIdx)
	if not self.tbConsumeInfo[nType] then
		Log("[MissionAward] GetConsumeInfo ERR ?? unknow nType " .. nType);
		return;
	end

	return self.tbConsumeInfo[nType][nAwardIdx - self.MAX_FREE_COUNT];
end

function MissionAward:GetOtherRandomCount(nType, nGrade)
	local tbInfo = self.tbAllRandomCount[nType];
	if not tbInfo then
		return 0;
	end

	return tbInfo[nGrade] or 0;
end

function MissionAward:GetGrade(nType, nScroe)
	local tbInfo = self.tbAllGradeInfo[nType];
	if not tbInfo then
		Log("[MissionAward] GetGrade ERR ?? unknow type " .. nType);
		return;
	end

	for nGrade, nMinScroe in ipairs(tbInfo) do
		if nScroe >= nMinScroe then
			return nGrade, MissionAward.tbGradeInfo[nGrade] or "NULL", tbInfo[nGrade - 1], tbInfo[nGrade];
		end
	end
	return 6, MissionAward.tbGradeInfo[#tbInfo], tbInfo[#tbInfo - 1], tbInfo[1];
end

function MissionAward:GetAwardFile(nType)
	if MissionAward.tbAwardFile[nType] then
		return MissionAward.tbAwardFile[nType];
	end
end

function MissionAward:GetAddImity(nType, nGrade)
	local tbImityInfo = self.tbAddFriendImityInfo[nType];
	if not tbImityInfo then
		return 0;
	end

	return tbImityInfo[nGrade] or 0;
end

function MissionAward:GetMaxAwardTimes(pPlayer)
	return MissionAward.MAX_REAL_ITEM_COUNT;
end

function MissionAward:OnGetRecordList(tbList)
	local szUiName = "MissionAwardList";
	if Ui:WindowVisible(szUiName) ~= 1 then
		return;
	end

	Ui(szUiName):Update(tbList);
end

function MissionAward:OnGetResult(bResult, nValue)
	UiNotify.OnNotify(UiNotify.emNOTIFY_MISSION_AWARD_ONRESULT, bResult, nValue);
end

function MissionAward:OnMissionUpdate(nType, nRecordId, tbAwardPos)
	UiNotify.OnNotify(UiNotify.emNOTIFY_MISSION_AWARD_UPDATE, nType, nRecordId, tbAwardPos);
end