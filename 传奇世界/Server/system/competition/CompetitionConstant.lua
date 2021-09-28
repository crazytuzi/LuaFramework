--CompetitionConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  CompetitionConstant.lua
 --* Author:  seezon
 --* Modified: 2015年1月10日
 --* Purpose: 拼战常量定义
 -------------------------------------------------------------------*/

COMPETITION_ONCE_TIME = 10*60		--拼战的持续时间

COMPETITION_NEXT_ACTIVE_TIME = 25*60		--下次拼战激活时间

COMPETITION_MAX_LEVEL = 50		--新手拼战等级分界线
COMPETITION_MIN_LEVEL = 20			--拼战的所需的最低等级

COMPETITION_DAILY_TIME = 4				--每天最大拼战次数

--拼战触发类型
ComepetitionSourceType = {
	Activiness = 1,
	Daily = 2,
	Reward = 3,
	KILLMONSTER= 4,
}
KILLMONSTERCOUNT = 100

COMPETITION_ERR_NO_REWARD = -1  --没有奖励，领取失败

FIRE_COMPETITION = 
{
	15, 35, 65, 100
}