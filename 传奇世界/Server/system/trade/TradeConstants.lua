Item_BagIndex_Bag = 1 
Item_BagIndex_Bank = 2 
Item_BagIndex_EquipmentBar = 3	
Item_BagIndex_Back = 4 

Item_BagIndex_Back_Size = 30

TRADE_FREE = 0
TRADE_ON = 1

TRADE_INGOT = -1

TRADE_TAX_RATE = 0			--20150819 从0.07改为0.03  0.03又改为0
TRADE_ITEM_ONCE = 10 		--每交易一次收10元宝税  单个物品不再收税
TRADE_ITEM_TAX = 0 			--物品扣税 暂时改为0
TRADE_TAX_MAX = 200 		--最大扣税值 	黄的 最新需求去掉
TRADE_INGOT_MAX = 3000 		--每天交易(不管交易出 还是 收到)元宝的最大限制
TRADE_INGOT_ONCE = 1000 	--每次交易元宝的最大限制
TRADE_LEVEL_LIMIT = 30 		--30级才能交易
TRADE_BLACK_MALL_LEVEL_LIMIT = 35  --黑市商人35级才开放


BAG_INDEX_BAG = 1 			--背包类型

--日志原因
LOG_SOURCE_INGOT_SHOP = 23			--元宝商城购买道具
LOG_SOURCE_BOOK_SHOP = 218 			--书店系统
LOG_SOURCE_BLACK_MALL = 220 		--黑市商人

LOG_SOURCE_SHORTCUT_1 = 214 		--快捷购买 运镖符
LOG_SOURCE_SHORTCUT_2 = 215 		--快捷购买 悬赏
LOG_SOURCE_SHORTCUT_3 = 216 		--快捷购买 金条
LOG_SOURCE_SHORTCUT_4 = 217 		--快捷购买 小飞鞋


MONEY_TYPE_GOLD			= 1
MONEY_TYPE_INGOT		= 2
MONEY_TYPE_GOLD_BIND	= 3
MONEY_TYPE_INGOT_BIND	= 4
MONEY_TYPE_FACTION		= 5
MONEY_TYPE_HONOR		= 6
MONEY_TYPE_JF			= 7
MONEY_TYPE_MERITORIOUS	= 8
MONEY_TYPE_VIP_GOLD		= 9

LIMIT_TABLE_SERVER		= 1
LIMIT_TABLE_USER		= 2
VIP_SHOP				= 3
PurpleScroll_ID			= 1
HighStrengthStone_ID	= 2

OK = 0

MAX_TRADE_INGOT = 1000
VIP_TRADE_INGOT = {
	[0] = 0,
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 1,
	[5] = 3,
	[6] = 3,
	[7] = 3,
	[8] = 8,
	[9] = 8,
	[10] = 8,
}

MALL_REQ_SERVER = 1
MALL_REQ_USER	= 2

--MSG
TRADE_MALL_SUCCEED = 1		--物品购买成功
TRADE_SELL = 2				--出售成功
TRADE_SEND = 3				--交易请求已发送
TRADE_REJECT = 4			--交易请求被拒绝
--ERROR
TRADE_ERR_ITEM_SELL = -1	--物品不足
TRADE_ERR_MONEY = -2		--金币不足
TRADE_ERR_BAG_NOSLOT = -3	--背包空间不足
TRADE_ERR_NOT_SELL = -4		--不能出售
TRADE_ERR_BIND_MONEY = -5	--绑定金币不足
TRADE_ERR_INGOT = -6		--元宝不足
TRADE_ERR_BIND_INGOT = -7	--绑定元宝不足
TRADE_MALL_FAIL = -8		--购买失败
--TRADE
TRADE_ERR_BAG_NOTENOUGH = -9    --背包空间不足四格
TRADE_ERR_NO_TRADE_SLOT = -10   --交易栏位置不足
TRADE_ERR_NO_TRADE_ITEM = -11   --交易栏物品不足
TRADE_ERR_ON_TRADING = -12      --玩家正在交易
TRADE_ERR_BLOCK_TRADE = -13     --对方屏蔽交易
TRADE_MALL_DOWN = -14			--商品已下架
TRADE_ERR_NO_FACTION = -15		--帮派帮贡不足
TRADE_ERR_NO_HONOUR = -16		--荣誉不足
TRADE_ERR_SPACE = -17			--不同服
TRADE_ERR_FAILED = -18			--交易失败
TRADE_ERR_NO_JF = -19			--积分不足
TRADE_ERR_OFFLINE = -20 		--对方不在线交易失败
TRADE_REQ_SEND = -31			--交易请求已发送
TRADE_ERR_TIMES_OUT = -33		--交易交易次数用完了
TRADE_ERR_SUCCEED = -34			--交易成功
TRADE_ERR_INGOT_ERR = -35		--元宝交易数量错误
TRADE_ERR_SOUL_SCORE = -36		--魂值不足
TRADE_ERR_MERITORIOUS = -37		--功勋不足
TRADE_ERR_OVER_LIMIT = -38 		--物品购买超过限制
TRADE_ERR_BUSY = -39			--对方忙于交易
TRADE_ERR_NOACTIVE = -40		--交易信息已过期
TRADE_ERR_SENCE = -41			--不在同一场景
TRADE_ERR_ITEM_CHANGED = -42 	--商品信息已更新
TRADE_ERR_UNLOCK_SOUL = -43 	--熔炼值解锁
TRADE_ERR_UNLOCK_INGOT = -44 	--元宝解锁
TRADE_ERR_A_LEVEL_LIMIT = -45  	--A等级不足30级无法交易
TRADE_ERR_B_LEVEL_LIMIT = -46   --B等级不足30级无法交易
TRADE_ERR_OPERATE_LEVEL_LIMIT = -47  	--等级不足无法操作
TRADE_ERR_STRENG_EQUIP = -48 	--强化过的装备不能交易
TRADE_ERR_VALUABLE_ITEM = -49 	--贵重物品不能交易
TRADE_ERR_COMMISSION = -50 		--手续费不足
TRADE_ERR_INGOT_MAX = -51 		--元宝达到上限
TRADE_ERR_OTHER_INGOT_MAX = -52 --对方元宝达到上限
TRADE_ERR_ITEM_NUM_MAX = -53 	--物品交易数量超出限制
TRADE_ERR_EMPTY_TRADE = -54 	--A B双方都未放物品和元宝
TRADE_ERR_UNABLE_TRADE = -55 	--没有配置的物品不能交易


TRADE_PUBLIC_SPACE = 2
APPLY_TRADE_TICK = 20  			--规定时间内必须处理其他玩家的  交易请求
MYSTERYSHOP_2_ITEM_NUM = 6 		--魂值神秘商城展示的商品数量
MYSTERYSHOP_3_INGOT_ITEM_NUM = 0--vip神秘商城展示的元宝商品数量 4暂时改为0
MYSTERYSHOP_3_SOUL_ITEM_NUM = 8 --vip神秘商城展示的魂值商品数量 4暂时改为8
MYSTERYSHOP_LEVLE = 34 			--神秘商店开启等级
MYSTERYSHOP_BUY_COUNT = 5       --神秘商店每天可以购买多少次
MYSTERYSHOP_4_INGOT_ITEM_NUM = 8 --黑市商人展示的商品数量


--商城类型
MALL_TYPE_INGOT = 0
MALL_TYPE_BINDINGOT = 1
MALL_TYPE_MONEY = 14
MALL_TYPE_JIFEN = 12
MALL_TYPE_MERITORIOUS = 13
MALL_TYPE_FACTION_MIN = 5 		--1级行会商店
MALL_TYPE_FACTION_MAX = 9 		--5级行会商店
MALL_TYPE_FACTION_MIN2 = 15 	--6级行会商店
MALL_TYPE_FACTION_MAX2 = 18 	--9级行会商店
MALL_TYPE_BOOK_SHOP = 19 		--书店商人


--神秘商店类型
MYSTERYSHOP_SMELTER = 3 		--熔炼神秘商城
MYSTERYSHOP_BLACK 	= 4 		--黑市神秘商店
MYSTERYSHOP_BOOK 	= 5 		--书店神秘商店


ITEM_UNICOM_ID = 1510 			--炽焰麒麟