VoyageConst = VoyageConst or {}

-- 订单状态
VoyageConst.Order_Status = {
	Unget = 1,     -- 未接取
	Underway = 2,  -- 进行中
	Finish = 3,    -- 已完成
}

-- 订单稀有度
VoyageConst.Order_Rarity = {
	Normal = 0, 	-- 普通
	Excellent = 1,  -- 精良
	Uncommon = 2,	-- 稀有
	Epic = 3, 		-- 史诗
	Legend = 4, 	-- 传说
	Eternity = 5, 	-- 不朽
}

-- 订单稀有度对应的资源
VoyageConst.Order_Rarity_Res = {
	[VoyageConst.Order_Rarity.Normal] = "txt_cn_voyage_1006",
	[VoyageConst.Order_Rarity.Excellent] = "txt_cn_voyage_1005",
	[VoyageConst.Order_Rarity.Uncommon] = "txt_cn_voyage_1004",
	[VoyageConst.Order_Rarity.Epic] = "txt_cn_voyage_1003",
	[VoyageConst.Order_Rarity.Legend] = "txt_cn_voyage_1002",
	[VoyageConst.Order_Rarity.Eternity] = "txt_cn_voyage_1001",
}

-- 订单稀有度对应的字色
VoyageConst.Order_Rarity_Color = {
	[VoyageConst.Order_Rarity.Normal] = cc.c3b(66,75,84),
	[VoyageConst.Order_Rarity.Excellent] = cc.c3b(35,119,1),
	[VoyageConst.Order_Rarity.Uncommon] = cc.c3b(6,79,147),
	[VoyageConst.Order_Rarity.Epic] = cc.c3b(126,6,147),
	[VoyageConst.Order_Rarity.Legend] = cc.c3b(147,86,6),
	[VoyageConst.Order_Rarity.Eternity] = cc.c3b(161,1,1),
}

-- 订单状态对应按钮的字色
VoyageConst.Order_Status_Color = {
	[VoyageConst.Order_Status.Unget] = cc.c3b(37,85,5),
	[VoyageConst.Order_Status.Underway] = cc.c3b(37,85,5),
	[VoyageConst.Order_Status.Finish] = cc.c3b(113,40,4),
}

-- 选中的英雄头像框位置
VoyageConst.Chose_Hero_PosX = {
	[1] = {319},
	[2] = {255, 383},
	[3] = {191, 319, 447},
	[4] = {127, 255, 383, 511},
	[5] = {63, 191, 319, 447, 575}
}

VoyageConst.Condition_Icon_PosX = {
	[1] = {0},
	[2] = {-38, 38},
	[3] = {-76, 0 , 76},
	[4] = {-114, -38, 38, 114},
	[5] = {-152, -76, 0 , 76, 152}
}