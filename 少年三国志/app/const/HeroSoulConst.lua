local HeroSoulConst =
{
	MAX_SOUL_PER_CHART = 5,	-- 每个阵图最多由5个将灵组成
	MAX_ATTR_PER_CHART = 3, -- 每个阵图最多有3种属性加成

	RANK_LOCAL	= 1, -- 本服排行
	RANK_CROSS	= 2, -- 全服排行

	EXTRACT_TYPE = {
		ONCE = 1,	-- 点将一次
		FIVE = 2,	-- 战将五次
	},

	SUMMOM_TYPE = {
		FREE = 1,   -- 免费
		ONCE = 2,	-- 点将一次
		FIVE = 3,	-- 战将五次
	},

	ONCE_COST = 200,
	FIVE_COST = 888,

	-- 子界面名称
	MAIN = "HeroSoulMainLayer",
	TERRACE = "HeroSoulTerraceLayer",
	TRIAL = "HeroSoulTrialLayer",
	BAG = "HeroSoulBagLayer",
}

return HeroSoulConst