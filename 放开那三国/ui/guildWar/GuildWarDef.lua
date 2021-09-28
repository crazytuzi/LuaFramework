-- FileName: GuildWarDef.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarDef 跨服军团战常量定义


module("GuildWarDef", package.seeall)

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
END 		  = 110

--战斗结果
VICTORY		  = 2 	--战斗胜利
FAILED		  = 0	--战斗失败
DRAW		  = 1 	--平局

--前后端阶段开启时间偏移量
OFFSET_TIME   = 3

--每个大阶段的分组数
GROUP_NUM	  = 5

--默认连胜次数
DEFAULT_WIN_NUM = 2

--海选赛被淘汰失败场次
AUDITION_LOST_NUM = 3
--淘汰赛被淘汰失败场次
PLAYOFF_LOST_NUM = 1

--报名后需要多长时间才可拉战斗信息
SIGNUP_CD_TIME = 300

--各阶段描述
StageDesInfo = {
	[INVALID]     = GetLocalizeStringBy("key_10040"),
	[SIGNUP]      = GetLocalizeStringBy("key_10041"),
	[AUDITION]    = GetLocalizeStringBy("key_10041"),
	[ADVANCED_16] = GetLocalizeStringBy("key_10042"),
	[ADVANCED_8]  = GetLocalizeStringBy("key_10043"),
	[ADVANCED_4]  = GetLocalizeStringBy("key_10044"),
	[ADVANCED_2]  = GetLocalizeStringBy("key_10045"),
}
