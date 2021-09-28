--LuoxiaConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  LuoxiaConstant.lua
 --* Author:  seezon
 --* Modified: 2015年6月24日
 --* Purpose: 落霞夺宝常量定义
 -------------------------------------------------------------------*/

LUOXIA_MAP_SENDTIME = 200	--尝试传送随机位置的次数
LUOXIA_JOIN_LEVEL = 30	--参加活动的等级限制
LUOXIA_JOIN_MONEY = 10000	--参加活动的金钱限制
LUOXIA_MAP_ID = 6003	--罗霞地图ID

--配置到代码里
LUOXIA_CONFIG_BOSSID = "5999"	--怪物id
LUOXIA_CONFIG_BOSSFRESHID = 522	--怪物刷新表ID
LUOXIA_CONFIG_PLAYERLOGINPOS= {{25,20},{23,71},{89,71},{87,19}}	--玩家进入地图坐标集
LUOXIA_BOX_ID = 10001	--宝盒ID
LUOXIA_CONFIG_TOTLETIME = 30 * 60	--活动配置时间
LUOXIA_TOTAL_TOTLETIME = 60 * 60	--活动总时间

--定义落霞夺宝相关提示
LUOXIA_ERR_NOT_SEND_FAIL = -1	    --传送失败，请重试
LUOXIA_ERR_MAT_SEND_FAIL = -2	    --当前身上携带“持有物品”，无法进行地图切换
LUOXIA_ERR_LEVEL_NOT_ENOUGH = -3	     --对不起，进入落霞夺宝地图需要达到30级
LUOXIA_ERR_NOT_OPEN = -10				--活动还没有开启
LUOXIA_ERR_MONEY_NOT_ENOUGH = -5		--对不起，您当前金币不足50万，进入落霞夺宝活动失败
LUOXIA_ERR_CANNOT_SEND = -6		--落霞夺宝地图不允许使用传送
LUOXIA_ERR_IN_COPYTEAM = -7		--多人副本队伍中不允许
LUOXIA_ERR_CAN_NOT_TRANS = -9	--当前地图无法传送
