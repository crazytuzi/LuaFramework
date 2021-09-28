-- FightTeam3v3DB.lua

local Item = 
{
	season = 1,			-- 第几赛季
	seasonName = "第二赛季",	-- 赛季名称
	mapID = 6019,		-- 战场地图id
	posLiveA = {x = 10, y = 33},		-- a队出生点
	posLiveB = {x = 35, y = 13},		-- b队出生点
	posWatch = {x = 24, y = 21},		-- 观战出生点
	battleZhanshiBuff = 399,			-- 战场战士buff
	battleFashiBuff = 400,				-- 战场法师buff
	battleDaoshiBuff = 401,				-- 战场道士buff
	zhanshiBuff = 333,					-- 战士职业buff
	fashiBuff = 334,						-- 法师职业buff
	daoshiBuff = 332,						-- 道士职业buff
	luoleiBuff = 402,					-- 落雷buff
	watchBuff = 403,					-- 观战buff

	auditionStartDate = 20160906,		-- 海选赛开始日期
	auditionEndDate = 20160910,			-- 海选赛结束日期
	auditionGameStartTime = 			-- 海选赛一天三场的比赛时间
	{
		130000,
		133000,
		140000,
	},
	enterTime = 240;				        -- 进入时间（秒）
	prepareTime = 30;					-- 准备时间（秒）
	fightTime = 300;	                                -- 战斗时间（秒）

	quarterDate = 20160911,				        -- 四分之一决赛的日期
	quarterGameStartTime = 130000,		                -- 四分之一决赛的比赛时间
	semifinalDate = 20160912,			        -- 半决赛的日期
	semifinalGameStartTime = 130000,	                -- 半决赛的比赛时间
	finalDate = 20160913,				        -- 决赛的日期
	finalGameStartTime = 130000,		                -- 决赛的比赛时间

	needLevel = 40,						-- 需要的等级
	clearWaitTime = 30,					-- 清理比赛需要的时间
	watchPlayerCount = 100,				        -- 观战限制
	regulationReward = 					-- 决赛奖励
	{
		[1] = 30001,
		[2] = 30002,
		[3] = 30003,
                [4] = 30004,
		[5] = 30005,
		[6] = 30006,
		[7] = 30007,
		[8] = 30008,
    },
	regulationEmail = 82,				        -- 决赛email

	rankReward = 						-- 排名奖励
	{
		[1] = {startRank = 1, endRank = 8, dropID = 30101},
		[2] = {startRank = 9, endRank = 15, dropID = 30102},
		[3] = {startRank = 16, endRank = 25, dropID = 30103},
                [4] = {startRank = 26, endRank = 35, dropID = 30104},
                [5] = {startRank = 36, endRank = 45, dropID = 30105},
                [6] = {startRank = 46, endRank = 55, dropID = 30106},
                [7] = {startRank = 56, endRank = 65, dropID = 30107},
                [8] = {startRank = 66, endRank = 75, dropID = 30108},
                [9] = {startRank = 76, endRank = 100, dropID = 30109},
	},
	rankEmail = 83,						-- 排名奖励email

	auditionReward =30200 ,				        -- 海选赛每日奖励
	autidionRewardEmail = 84,			        -- 海选赛每日奖励email

	consolationReward = 30110,				-- 安慰奖励
	consolationRewardEmail = 86,			-- 安慰奖励邮件

	rewardChampionText = "冠军";			-- 冠军文字
	rewardNormalText = "决赛";			-- 普通奖励文字
}


return Item

