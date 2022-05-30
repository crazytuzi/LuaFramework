PetardActionConst = PetardActionConst or {}

-- 红包界面tab定义
PetardActionConst.Redbag_Tab = {
	Redbag = 1, -- 抢红包
	Redmsg = 2, -- 红包传闻
}

-- 主界面花火大会红包显示状态
PetardActionConst.Redbag_State = {
	Close = 0, -- 不显示
	Half = 1,  -- 显示一半（没有红包可领）
	All = 2,   -- 全部显示（有红包可领）
}

-- 灯笼状态
PetardActionConst.Lantern_State = {
	Lock = 1,   -- 未开启
	CanGet = 2, -- 可领取
	Got = 3, 	-- 已领取
}