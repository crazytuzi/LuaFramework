RankActivity.MAX_RANK_LEVEL_COUNT = 100 									-- 前N个玩家达到等级有奖励
RankActivity.LEVEL_RANK_REWARD_LEVEL    = 49 							-- 需达到的等级
RankActivity.tbRankLevelReward = { 										-- 等级排名奖励
	[1] = {1, {{"Item", 997003, 5}, {"Item", 4687, 50}, {"AddTimeTitle", 5060, 30*24*60*60}}}, 		-- N名以下（包括N名）的奖励
	[2] = {10,  {{"Item", 997003, 1}, {"Item", 4687, 5}, {"AddTimeTitle", 5061, 30*24*60*60}}},
	[3] = {100, {{"Item", 997002, 1}, {"Item", 4687, 1},  {"AddTimeTitle", 5062, 30*24*60*60}}},
}

RankActivity.RANK_LEVEL_INVALID_TIME = 2*24*60*60 						-- 等级排名最新消息过期时间
RankActivity.OPEN_SERVER_RANK_LEVEL_INVALID_TIME = 30*24*60*60 			-- 开服推送等级排名最新消息过期时间

RankActivity.MAX_NEW_INFO_COUNT = 10 									-- 需要在界面中展示的名次


RankActivity.tbRankPowerCommonReward = {{"Item", 1126, 1}} 				-- 战力排名各门派通用奖励

RankActivity.tbRankPowerReward =  										-- 战力排名各门派奖励
{
	[1] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},	 		-- 排名N以下（包括N）的奖励,奖励配到N名则前N名发奖励
	},																	--1 = 天王
	[2] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--2 = 峨嵋
	[3] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--3 = 桃花
	[4] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--4 = 逍遥
	[5] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--5 = 武当
	[6] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--6 = 天忍
	[7] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--7 = 少林
	[8] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--8 = 翠烟
	[9] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--9 = 唐门
	[10] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--10 = 昆仑
	[11] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--11 = 丐帮
	[12] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--12 = 五毒
	[13] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--13 = 藏剑
	[14] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--14 = 长歌
	[15] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--15 = 天山
	[16] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--16 = 霸刀
	[17] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--17 = 华山
	[18] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--18 = 明教
	[19] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--19 = 段氏
	[20] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--20 = 万花
	[21] = {
		{1,{{"Item", 9859, 1}, {"Item", 998143, 1}}},
	},																	--21 = 杨门
}

RankActivity.RANK_POWER_INVALID_TIME = 9*24*60*60 						-- 战力排名最新消息过期时间
RankActivity.OPEN_SERVER_RANK_POWER_INVALID_TIME = 10*24*60*60 			-- 开服推送战力排名最新消息过期时间

----------------show reward------------------
RankActivity.tbLevelRankShowReward = 									-- 等级排名界面显示奖励
{
	[1] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[2] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[3] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[4] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[5] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[6] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[7] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[8] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[9] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[10] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[11] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[12] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[13] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[14] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[15] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[16] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[17] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
		  },
	[18] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
	  	  },
	[19] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
	  	  },
	[20] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
	  	  },
	[21] = {
			{{"Item", 997003, 5}, {"Item", 4687, 50}}, 					-- 上面奖励
			{{"Item", 997003, 1}, {"Item", 4687, 5}}, 						-- 下面奖励（后面增加奖励以此类推）
			{{"Item", 997002, 1}, {"Item", 4687, 1}},
	  	  },
}

RankActivity.tbPowerRankShowReward = 						 			-- 战力排名界面显示奖励
{
	[1] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--天王
	[2] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--峨嵋
	[3] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--桃花
	[4] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--逍遥
	[5] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--武当
	[6] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--天忍
	[7] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--少林
	[8] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--翠烟
	[9] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--唐门
	[10] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--昆仑
	[11] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--丐帮
	[12] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--五毒
	[13] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--藏剑
	[14] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--长歌
	[15] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--天山
	[16] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--霸刀
	[17] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--华山
	[18] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--明教
	[19] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },
	[20] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },
	[21] = {
			{{"Item", 9859, 1}, {"Item", 998143, 1}},
		  },															--杨门
}

RankActivity.nPowerRankOpenDay = 10
RankActivity.nPowerRankTime = 0

function RankActivity:PowerRank(nFaction)
	local nRank = 0

	local tbFactionReward = RankActivity.tbRankPowerReward[nFaction]
	if not tbFactionReward then
		return nRank
	end

	for _,tbInfo in ipairs(tbFactionReward) do
		if tbInfo[1] > nRank then
			nRank = tbInfo[1]
		end
	end

	return nRank
end


function RankActivity:LevelRankReward(nRank)
	local tbAllReward = {}

	for _,tbInfo in ipairs(RankActivity.tbRankLevelReward) do
		if nRank <= tbInfo[1] and tbInfo[2] then
			tbAllReward = Lib:CopyTB(tbInfo[2])
			break
		end
	end

	return self:FormatReward(tbAllReward)
end

function RankActivity:GetPowerRankReward(nFaction,nRank)
	local tbAllReward = {}

	local tbFactionReward = RankActivity.tbRankPowerReward[nFaction]

	if not tbFactionReward then
		return tbAllReward
	end

	for _,tbInfo in ipairs(tbFactionReward) do
		if nRank <= tbInfo[1] and tbInfo[2] then
			tbAllReward = Lib:CopyTB(tbInfo[2])
			break
		end
	end

	return tbAllReward

end

function RankActivity:PowerRankReward(nFaction,nRank)
	local tbAllReward = {}

	local tbFactionReward = self:GetPowerRankReward(nFaction,nRank)
	if not tbFactionReward or not next(tbFactionReward) then
		return tbAllReward
	end

	for _,tbReward in pairs(RankActivity.tbRankPowerCommonReward) do
		table.insert(tbAllReward,tbReward)
	end

	local tbFormatFactionReward = Lib:CopyTB(tbFactionReward)
	tbFormatFactionReward = self:FormatReward(tbFormatFactionReward)
	for _,tbReward in pairs(tbFormatFactionReward) do
		table.insert(tbAllReward,tbReward)
	end

	return tbAllReward
end

function RankActivity:FormatReward(tbAllReward)
	tbAllReward = tbAllReward or {}

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end