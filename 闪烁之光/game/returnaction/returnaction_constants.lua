--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归活动常量
-- @DateTime:    2019-12-12 17:11:29
-- *******************************
ReturnActionConstants = ReturnActionConstants or {}

ReturnActionPanelTypeView = {
	[121] = "ReturnActionPrivilegePanel", --回归礼包
	[122] = "ReturnActionSummonPanel", --回归抽奖
	[123] = "ReturnActionTaskPanel", --回归任务
	[124] = "ReturnActionSigninPanel", --回归签到
}

ReturnActionConstants.ReturnActionType = {
	privilege = 101,	--回归礼包
	summon = 102,	--回归抽奖
	task = 103,	--回归任务
	sign = 104,	--回归签到
}

-- 红包界面tab定义
ReturnActionConstants.Redbag_Tab = {
	Redbag = 1, -- 抢红包
	Redmsg = 2, -- 红包传闻
}

-- 主界面红包显示状态
ReturnActionConstants.Redbag_State = {
	Close = 0, -- 不显示
	Half = 1,  -- 显示一半（没有红包可领）
	All = 2,   -- 全部显示（有红包可领）
}