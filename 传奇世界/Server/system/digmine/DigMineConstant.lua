DIGMINE_MAP_ID = 2127			--挖矿地图ID
DIGMINE_SIMULATION_MAP_ID = 5008--模拟挖矿地图ID
--进入坐标
DIGMINE_ENTER_POSITION = {
	x = 70,
	y = 70,
}
DIGMINE_OPEN_LEVEL = 20			--在线挖矿开启等级
DIGMINE_OFFMINE_LEVEL = 21		--离线挖矿开启等级
DIGMINE_INMINE = 64				--正在挖矿
DIGMINE_BUFFID = 31				--挖矿所加的BUFFID
DIGMINE_MINE_ID = 6200032		--矿石结晶道具ID
DIGMINE_MAX_REWARD = 50			--挖矿数量限制
DIGMINE_EXCHANGE_COUNT = 3		--每天可以兑换的次数
DIGMINE_DROP_ID = {
	[1]	= {dropID = 2028, count = 5},	--兑换奖励次数获得奖励对应的掉落ID及需要消耗材料的数量
	[2] = {dropID = 2029, count = 15},
	[3] = {dropID = 2030, count = 30},
}
--矿堆随机坐标
DEGMINE_MINE_POSITION = {
	{x = 19, y = 50}, {x = 30, y = 43}, {x = 39, y = 46}, {x = 50, y = 45}, {x = 45, y = 54},
	{x = 54, y = 59}, {x = 61, y = 65}, {x = 56, y = 77}, {x = 48, y = 87}, {x = 68, y = 70},
	{x = 79, y = 58}, {x = 82, y = 75}, {x = 89, y = 65}, {x = 89, y = 77},	{x = 96, y = 88}, 
	{x = 102, y = 93}, {x = 122, y = 97}, {x = 107, y = 57}, {x = 93, y = 55}, {x = 86, y = 49},
	{x = 106, y = 47}, {x = 95, y = 43}, {x = 106, y = 36}, {x = 92, y = 31}, {x = 88, y = 37}, 
	{x = 83, y = 34}, {x = 76, y = 33}, {x = 63, y = 31}, {x = 52, y = 36}, {x = 45, y = 42}, 
	{x = 37, y = 53}, {x = 56, y = 87}, {x = 76, y = 81}, {x = 96, y = 95}, {x = 118, y = 100}, 
	{x = 111, y = 95}, {x = 103, y = 64}, {x = 95, y = 63}, {x = 83, y = 67}, {x = 87, y = 55},
	{x = 54, y = 52}, {x = 32, y = 50}, {x = 62, y = 74}, {x = 69, y = 60}, {x = 55, y = 46},
}
DEGMINE_EMAIL_ID = 48			--发送在线挖矿奖励邮件ID
DEGMINE_OFF_EMAIL_ID = 49		--发送离线挖矿奖励邮件ID

DIGMINE_PERIOD = 15 * 60 		--离线挖矿收获周期
DIGMINE_MAX_TIME = 48 * 3600	--离线挖矿最大时间
DIGMINE_GOAL_LIMIT = 2 * 60 * 60--黄金宝箱掉落时间限制
DIGMINE_SILVER_LIMIT = 60 * 60	--白银宝箱掉落时间限制
DIGMINE_COPPER_LIMIT = 15 * 60	--青铜宝箱掉落时间限制
DIGMINE_NEW_DROPID = 1003		--离线挖矿首次掉落必掉ID
DIGMINE_GOAL_MAX_BOX = 15		--黄金宝箱掉落的最多个数

DIGMINE_MONSTER_MINE_ID = {21, 23, 31}	--模拟挖矿矿堆ID
DIGMINE_SIMULATION_TIME = 2 * 60		--模拟挖矿总时间
--模拟挖矿副本退出时间
DIGMINE_SIMULATION_DEL_TIME = DIGMINE_SIMULATION_TIME + 15
DIGMINE_SIMULATION_NUM = 8				--模拟挖矿总个数


DIGMINE_ERR_MAX_EXCHANGE = 1 	--今日兑换的次数已用完
DIGMINE_ERR_NO_TIMES = 2 		--今日兑换的次数已用完,不可再进入地图
DIGMINE_ERR_KILL_OTHER = 3 		--当前矿堆已有玩家在采集,请换个地方或者将其击杀后再采集！
DIGMINE_ERR_GET_MINE = 4		--头顶满后道具直接进背包
DIGMINE_ERR_LESS_ITEM = 5		--矿石结晶数量不足,兑换失败
DIGMINE_ERR_EXCHANGE_SUCCESS = 6--兑换成功
DIGMINE_ERR_LESS_LEVEL = 12		--挖矿等级不足
DIGMINE_ERR_LESS_LEVEL2 = 13	--挖矿等级不足