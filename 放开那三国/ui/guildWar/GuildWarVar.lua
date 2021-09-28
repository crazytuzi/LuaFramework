-- FileName: GuildWarVar.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarVar 跨服军团战常量定义


module("GuildWarVar", package.seeall)

kGuildInitial      	= 2 -- 初始状态 
kGuildFail 			= 1 -- 淘汰状态
kGuildWin 			= 0 -- 晋级状态

--军团跨服赛阶段
INVALID       = 0			-- 无效阶段
SIGNUP        = 1			-- 报名阶段
AUDITION      = 2			-- 海选阶段
ADVANCED_16   = 3			-- 16进8阶段
ADVANCED_8    = 4			-- 8进4阶段
ADVANCED_4    = 5			-- 4进2阶段
ADVANCED_2    = 6			-- 2进1阶段
WORSHIP		  = 7			-- 膜拜冠军阶段
--军团跨服赛状态
NO            = 0
PREPARE       = 10
WAIT_TIME_END = 11
FIGHTING      = 20
FIGHTEND      = 30
REWARDEND     = 40
DONE          = 100

GROUP_NUM	  = 5

--各阶段描述
StageDesInfo = {
	[INVALID]     = "报名时间",
	[SIGNUP]      = "海选赛",
	[AUDITION]    = "海选赛",
	[ADVANCED_16] = "8强晋级赛",
	[ADVANCED_8]  = "4强晋级赛",
	[ADVANCED_4]  = "半决赛",
	[ADVANCED_2]  = "冠军赛",
}
