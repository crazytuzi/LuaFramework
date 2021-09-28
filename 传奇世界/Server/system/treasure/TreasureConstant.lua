--TreasureConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  TreasureConstant.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月11日
 -------------------------------------------------------------------*/

--tips
TREASURE_NOT_OPEN = 1	--活动还未开启
TREASURE_NOT_TRAN = 2 	--当前地图不能传送
TREASURE_IN_COPYTEAM = 3 --队伍副本中不能参与该活动
TREASURE_NOT_ENOUGH_LEVEL = 4 --等级不够
TREASURE_NOT_ENOUGH_COUNT = 5 --进入次数不足
TREASURE_NOT_ENOUGH_TIME = 6 --时间不足
TREASURE_NOT_ENOUGH_ACTIVITY = 7 --活跃度不足


TREASURE_TIME = 30 * 60		--一次停留时间
TREASURE_DAILY_COUNT = 10	--每天进入次数
TREASURE_NEED_ACTIVITY = 60 --所需活跃值

TREASURE_EXPERIENCE_TIME = 5 * 60 --体验卡时间

TREASURE_MAP_INFO = {
 	[1] = 7000,
 	[2] = 7001,
 	[3] = 7002,
 	[4] = 7003,
}
