--KnightConst.lua


local KnightConst = {
	
	KNIGHT_TYPE = {
		KNIGHT_STRENGTHEN = 1,
		KNIGHT_JINGJIE = 2,
		KNIGHT_GUANGHUAN = 3,
		KNIGHT_TRAINING = 4,
		KNIGHT_JUEXING = 5,
		KNIGHT_GOD = 6, -- 化神
	},

	KNIGHT_GOD_TUPO_LEVEL = 8, -- 化神的最低突破等级限制
	KNIGHT_GOD_POTENTIAL = 20, -- 化神的最低潜力限制
	KNIGHT_GOD_MAIN_POTENTIAL = 23, -- 猪脚化神的最低潜力限制
	KNIGHT_GOD_RED_POTENTIAL = 23, -- 红将的潜力值
	KNIGHT_GOD_RED_MAX_LEVEL = 15, -- 红将化神的最大等级
	KNIGHT_GOD_CHENG_MAX_LEVEL = 30, -- 橙色武将化神的最大等级
	KNIGHT_GOD_ZHENGJIE = 5, -- 一个完整的阶段由4个小阶和1个大阶组成
	KNIGHT_GOD_MAX_LEVEL = 3, -- 每种潜力的武将最大的阶数是3


	KNIGHT_QUALITY_DIFF = {
		WRITE         = 1, -- 白将
		BLUE          = 2, -- 蓝将
		PURPLE        = 3, -- 紫将
		BASE_ORANGE   = 4, -- 橙将和橙升红的武将
		RED           = 5, -- 红将
	},
}


return KnightConst