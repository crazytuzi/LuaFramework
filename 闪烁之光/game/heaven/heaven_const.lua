HeavenConst = HeavenConst or {}

-- 章节通关状态
HeavenConst.Chapter_Pass_Status = {
	NotPass = 0, 	-- 未通关
	NormalPass = 1, -- 普通通关（所有关卡都打赢）
	FullPass = 2,   -- 满星通关
}

HeavenConst.Tab_Index = {
	Dungeon = 1,  -- 天界副本
	DialRecord = 2,  -- 天界祈祷
}

-- 每六章的高度
HeavenConst.Chapter_List_Height = 840

-- 距离底部的高度
HeavenConst.Chapter_List_Bottom = 0

-- 章节的位置（类型1）
HeavenConst.Chapter_Pos_1 = {
	[1] = cc.p(165, 110),
	[2] = cc.p(510, 110),
	[3] = cc.p(550, 384),
	[4] = cc.p(248, 384),
	[5] = cc.p(162, 646),
	[6] = cc.p(530, 646),
}

-- 章节的位置（类型2）
HeavenConst.Chapter_Pos_2 = {
	[1] = cc.p(530, 110),
	[2] = cc.p(162, 110),
	[3] = cc.p(162, 384),
	[4] = cc.p(550, 354),
	[5] = cc.p(530, 646),
	[6] = cc.p(162, 646),
}

-- 章节连接线的位置和长度(类型1)
HeavenConst.Chapter_Line_Info_1 = {
	[1] = {cc.p(296, 110), 80, 0},
	[2] = {cc.p(536, 259), 80, 90},
	[3] = {cc.p(421, 384), 80, 0},
	[4] = {cc.p(200, 508), 80, 90},
	[5] = {cc.p(339, 646), 180, 0},
	[6] = {cc.p(530, 822), 80, 90}
}

-- 章节连接线的位置和长度(类型2)
HeavenConst.Chapter_Line_Info_2 = {
	[1] = {cc.p(332, 110), 140, 0},
	[2] = {cc.p(160, 276), 50, 90},
	[3] = {cc.p(360, 384), 220, 0},
	[4] = {cc.p(538, 505), 80, 90},
	[5] = {cc.p(365, 646), 130, 0},
	[6] = {cc.p(156, 792), 80, 90}
}

-- 红点
HeavenConst.Red_Index = {
	Count = 1, -- 挑战次数
	Award = 2, -- 章节奖励
	Dial = 3,  -- 神装转盘免费次数
	DialAward = 4,  -- 神装祈祷奖励
}

-- 神装抽奖的方式
HeavenConst.Dial_Way = {
	Free = 1,  -- 免费抽
	Item = 2,  -- 道具抽
	Gold = 3,  -- 钻石抽
}

--许愿位置
HeavenConst.Dial_Wish_Pos = {
	DialWishPos1 = 1,  
	DialWishPos2 = 2,  
	DialWishPos3 = 3,  
	DialWishPos4 = 4,  
}