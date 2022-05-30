SeerpalaceConst = SeerpalaceConst or {}

SeerpalaceConst.Tab_Index = {
	Summon = 1,  -- 先知殿(召唤)
	Change = 2,  -- 宝可梦转换
}

SeerpalaceConst.Change_Index_Camp = {
	All = 1, 	-- 全部
	Water = 2,  -- 水
	Fire = 3,   -- 火
	Wind = 4, 	-- 风
}

-- 不同星数时动态X坐标
SeerpalaceConst.Change_Pos_X = {
	[1] = {100},
	[2] = {85, 115},
	[3] = {70, 100, 130},
	[4] = {55, 85, 115, 145},
	[5] = {40, 70, 100, 130, 160},
}

-- 先知殿召唤下标对应的召唤id
SeerpalaceConst.Index_To_GroupId = {
	[1] = 3000,
	[2] = 1000,
	[3] = 2000,
	[4] = 4000,
}

-- 先知殿召唤积分下标对应的召唤id
SeerpalaceConst.Score_Index_To_GroupId = {
	[1] = 30000,
	[2] = 10000,
	[3] = 20000,
	[4] = 40000,
	[5] = 50000,
}

-- 书本特效
SeerpalaceConst.Book_EffectId = {
	[1000] = 634,
	[2000] = 635,
	[3000] = 633,
	[4000] = 636,
}


-- 书本召唤特效
SeerpalaceConst.Effect_Pos = {
	[1000] = cc.p(90, 240),
	[2000] = cc.p(-87, 240),
	[3000] = cc.p(268, 240),
	[4000] = cc.p(-269, 240),
}

--召唤界面的对应的id
SeerpalaceConst.Summon_Index = {
	[2] = 100,
	[3] = 200,
	[4] = 300,
	[5] = 400,
}

-- 先知殿的道具id
SeerpalaceConst.Good_ZhiHui  = 14001  -- 先知水晶
SeerpalaceConst.Good_XianZhi = 14002  -- 先知精华
SeerpalaceConst.Good_JieJing = 24 	  -- 先知结晶
SeerpalaceConst.Good_jifen   = 39 	  -- 积分