local FuCommon = {
	
	--活动ID：奇门八卦  巡游探宝  幸运转盘
	TRIGRAMS_TYPE_ID = 0,   --奇门八卦
	WHEEL_TYPE_ID = 1,    	--幸运转盘
	RICH_TYPE_ID = 2,    	--巡游探宝
	RECHARGE_TYPE_ID = 3,    	--充值翻牌

	TYPE_ID_MAX = 4,    	--活动个数

	RANK_TYPE_PT = 1,   --普通榜
	RANK_TYPE_JY = 2,   --精英榜

	RANK_LIST_LENGTH = 20, --排行榜列表显示数目

	STATE_OPEN = 1,     --活动开启状态
	STATE_AWARD = 2,    --活动领奖状态
	STATE_CLOSE = 3,    --活动关闭状态

	--对应wheel_prize_info表中event_type
	WHEEL_PRIZE_TYPE = 1,   	--幸运转盘
	RICH_PRIZE_TYPE = 2,   		--巡游探宝
	TRIGRAMS_PRIZE_TYPE = 4,   	--奇门八卦	  --与配表一致

	ICON_TEST = "icon/item/41045.png",
	ICON_LEFT_WHEEL = "ui/dafuweng/icon_bagua_zuo.png",
	ICON_RIGHT_WHEEL = "ui/dafuweng/icon_bagua_you.png",

	--奇门八卦三种等级边框
	TRIGRAMS_BORDER_1 = "ui/dafuweng/iconkuang_lan.png", 
	TRIGRAMS_BORDER_2 = "ui/dafuweng/iconkuang_zi.png", 
	TRIGRAMS_BORDER_3 = "ui/dafuweng/iconkuang_cheng.png", 

	TRIGRAMS_BORDER_MAX = 3,   --三种品质

	MOVE_TIME = 0.5,  --八卦打开关闭时间
	ITEM_MAX_NUM = 8,   		--奇门八卦和转盘上道具个数

	REFRESH_COST_GOLD = 20,   		--刷新花费元宝数

	TRIGRAMS_ID_IN_SHOP_PRIZE_INFO = 29,   	--奇门八卦开奖次数花费对应ID

	TRIGRAMS_PAGE_STATE_DEFAULT  = 1,  --奇门八卦默认界面
	TRIGRAMS_PAGE_STATE_PLAY     = 2,  --奇门八卦我要抽取界面

	TRIGRAMS_REWARD_LEVEL_1  = 3,  --奇门八卦高级奖励物品
	TRIGRAMS_REWARD_LEVEL_2  = 2,  --奇门八卦中等奖励物品
	TRIGRAMS_REWARD_LEVEL_3  = 1,  --奇门八卦普通奖励物品
}

return FuCommon