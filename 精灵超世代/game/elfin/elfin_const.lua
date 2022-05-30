ElfinConst = ElfinConst or {}

-- 精灵主界面Tab类型
ElfinConst.Tab_Index = {
	Hatch = 1, -- 孵化
	Rouse = 2, -- 唤醒
	Summon = 3, -- 召唤
	
}

-- 孵化窝的状态
ElfinConst.Hatch_Status = {
	Open = 0,  -- 开启了，但没放入蛋
	Hatch = 1, -- 孵化中
	Over = 2,  -- 孵化完成，待领取
}

-- 物品选择界面类型
ElfinConst.Select_Type = {
	Egg  = 1,  -- 蛋
	Item = 2,  -- 道具
}

-- 特权灵窝id
ElfinConst.Privilege_Hatch_Id = 2

-- 精灵古树固定显示的四个属性值
ElfinConst.Tree_Attrs = {
	[1] = "atk", 	-- 攻击
	[2] = "hp_max", -- 气血
	[3] = "def",	-- 防御
	[4] = "speed",	-- 出手速度
}

-- 精灵获得界面按品质区分资源
ElfinConst.Elfin_Quality_Res = {
	[0] = "elfin_1030",  -- 白
	[1] = "elfin_1034",  -- 绿
	[2] = "elfin_1033",  -- 蓝
	[3] = "elfin_1035",  -- 紫
	[4] = "elfin_1031",  -- 橙
	[5] = "elfin_1032",  -- 红
}

ElfinConst.Elfin_Quality_Outline = {
	[0] = cc.c4b(68,75,67,255),  -- 白
	[1] = cc.c4b(33,102,24,255), -- 绿
	[2] = cc.c4b(49,70,148,255), -- 蓝
	[3] = cc.c4b(88,0,120,255),  -- 紫
	[4] = cc.c4b(153,58,0,255),  -- 橙
	[5] = cc.c4b(151,0,0,255),   -- 红
}

ElfinConst.Elfin_Quality_Name = {
	[0] = TI18N("优良"),  -- 白
	[1] = TI18N("优良"), -- 绿
	[2] = TI18N("优良"), -- 蓝
	[3] = TI18N("稀有"),  -- 紫
	[4] = TI18N("极品"),  -- 橙
	[5] = TI18N("极品"),   -- 红
}

-- 蓝色蛋的bid
ElfinConst.Bule_Egg_Bid = 10601