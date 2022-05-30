CrossarenaConst = CrossarenaConst or {}

-- 子页签类型
CrossarenaConst.Sub_Type = {
	Challenge = 1,  -- 跨服竞技场
	Honour = 2, 	-- 赛季荣耀
}

-- 挑战界面宝可梦展示的位置
CrossarenaConst.Challenge_Role_Pos = {
	[1] = cc.p(15, 450),
	[2] = cc.p(15, 450),
	[3] = cc.p(15, 450)
}

-- 布阵中宝可梦图标移动的时间
CrossarenaConst.Form_Act_Time = 0.1

-- 活动状态
CrossarenaConst.Open_Status = {
	Close = 0,  -- 关闭
	Open = 1,   -- 开启
	Stop = 2,   -- 暂停
}

-- 前三名对应的称号资源
CrossarenaConst.Title_Res = {
	[1] = "txt_cn_honor_58",
	[2] = "txt_cn_honor_56",
	[3] = "txt_cn_honor_57",
}

-- 红点
CrossarenaConst.Red_Index = {
	Open = 1,  -- 活动开启（仅上线提示一次）
	Like = 2,  -- 点赞
	Award = 3, -- 宝箱奖励
	Record = 4,-- 挑战记录
}