--EnvoyConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  EnvoyConstant.lua
 --* Author:  seezon
 --* Modified: 2014年11月27日
 --* Purpose: 重装使者常量定义
 -------------------------------------------------------------------*/

ENVOY_MAP_SENDTIME = 200	--尝试传送随机位置的次数
ENVOY_HOLD_MAT_TIME = 1	--玩家持有物品时间（分钟）
--ENVOY_JOIN_LEVEL = 32	--参加活动的等级限制
--ENVOY_JOIN_MONEY = 50000	--参加活动的金钱限制
--ENVOY_NEXT_FLOOR_NEED_MAT = 6200025	--进入下一层需要的物品
ENVOY_ONE_TIME = 30*60 --一次炼狱时间30分钟

ENVOY_EXPERIENCE_TIME = 5 * 60 --体验卡体验时间

--定义重装使者相关提示
ENVOY_ERR_NOT_SEND_FAIL = -1	    --传送失败，请重试
ENVOY_ERR_MAT_SEND_FAIL = -2	    --当前身上携带“持有物品”，无法进行地图切换
ENVOY_ERR_LEVEL_NOT_ENOUGH = -3	    --对不起，进入重装使者地图需要达到38级
ENVOY_ERR_NOT_OPEN = -4				--活动还没有开启
ENVOY_ERR_MONEY_NOT_ENOUGH = -5		--对不起，您当前金币不足50万，进入重装使者活动失败
ENVOY_ERR_CANNOT_SEND = -6		--重装使者地图不允许使用传送
ENVOY_ERR_IN_COPYTEAM = -7		--多人副本队伍中不允许
ENVOY_ERR_BOSS = -8		--炼狱XX层BOSS已携带大量宝物出现！
--ENVOY_ERR_MAT_NOT_ENOUGH = -9		--您的炼狱凭证不足，无法传送
ENVOY_ERR_CAN_NOT_TRANS = -10  --当前地图无法传送
ENVOY_ERR_MAT_NOT_ENOUGH = {
	[1] = -11,			--初级炼狱凭证不足
	[2] = -12,			--中级炼狱凭证不足
	[3] = -13,			--高级炼狱凭证不足
}


FreshMonsterType = {
	Normal           = 1, --普通怪物
	BOSS           = 2, --BOSS
}

ENVOY_COST_MAT = {
	[1] = 6200029,	--初级炼狱消耗道具id
	[2] = 6200030,	--中级炼狱消耗道具id
	[3] = 6200031,	--高级炼狱消耗道具id
}


ENVOYMAPID = {
	[1] = 6000,
	[2] = 6001,
	[3] = 6002,
	[4] = 6020,
	[5] = 6021,
	[6] = 6022,
	[7] = 6030,
	[8] = 6031,
	[9] = 6032,
}

EnvoyFloorMin = {
	[1] = 1,
	[2] = 4,
	[3] = 7,
}

EnvoyFloorMax = {
	[1] = 3,
	[2] = 6,
	[3] = 9,
}

EnvoyBuffer = {
	[1] = 406,
	[2] = 407,
	[3] = 408,
	[4] = 409,
	[5] = 410,
	[6] = 411,
	[7] = 412,
	[8] = 413,
	[9] = 414,
}