MainUIConst = {}

MainUIConst.functionConnItemId = {
	[1] = "Icon/Activity/fun_12",--角色
	[2] = "Icon/Activity/fun_13",--技能
	[3] = "Icon/Activity/fun_14",--神技
	[4] = "Icon/Activity/fun_15",--好友
	[5] = "Icon/Activity/fun_16",--设置
}

MainUIConst.ActivityItemIcon = {
	[FunctionConst.FunEnum.welfare] = "Icon/Activity/fun_9",-- 福利
	[FunctionConst.FunEnum.activity] = "Icon/Activity/fun_8",-- 活动
	[FunctionConst.FunEnum.store] = "Icon/Activity/fun_7",-- 商城
	[FunctionConst.FunEnum.deal] = "Icon/Activity/fun_6",-- 交易
	[FunctionConst.FunEnum.rank] = "Icon/Activity/fun_10",-- 排行
	[FunctionConst.FunEnum.copy] = "Icon/Activity/fun_3",-- 副本
	[FunctionConst.FunEnum.ladder] = "Icon/Activity/fun_2",-- 天梯
	[FunctionConst.FunEnum.shenjing] = "Icon/Activity/fun_4", -- 神镜
	[FunctionConst.FunEnum.carnival] = "Icon/Activity/fun_19", --庆典
	[FunctionConst.FunEnum.firstRecharge] = "Icon/Activity/fun_20", -- 首充
	[FunctionConst.FunEnum.SevenLogin] = "Icon/Activity/fun_22", --七天
	[FunctionConst.FunEnum.OpenGift] = "Icon/Activity/fun_23", -- 特惠
	[FunctionConst.FunEnum.furnace] = "Icon/Activity/fun_17", -- 熔炉
}

--主界面UI Item State
MainUIConst.MainUIItemState = {
	None = 0,
	Open = 1,
	Close = 2,
}


--主界面UI Item状态改变方式
MainUIConst.UIStateChangeWay = {
	None = 0,
	Level = 1,
	Task = 2
}

--主界面TaskTeam控制器
MainUIConst.TaskTeamCtrl = {
	Task = 0,
	Team = 1
}

MainUIConst.UIStateChange = "MainUIConst.UIStateChange" --主界面UI状态改变事件
MainUIConst.E_QuickEquipChange = "MainUIConst.E_QuickEquipChange" --主界面快捷装备列表改变
MainUIConst.E_QuickEquipDelete = "MainUIConst.E_QuickEquipDelete"
MainUIConst.E_QuickGoodsChange = "MainUIConst.E_QuickGoodsChange"--快捷物品变化
MainUIConst.E_ShowPopStateChange = "MainUIConst.E_ShowPopStateChange"

MainUIConst.ActivitesUIState = {
	None = 0,
	Show = 1,
	Hiden = 2
}
--登录弹出状态
MainUIConst.PopCheckState = 
{
	None = 0,
	Showing = 1,
	ShowOver = 2
}
--登录弹出模块枚举
MainUIConst.PopModule = 
{
	FirstRecharge = 1, -- 首充
	OpenGift = 2, -- 神器
	SevenLogin = 3, -- 七天登录
	SevenRecharge = 4, -- 七天奖励
	Sign = 5, -- 签到
	EquipmentStoreTips = 6, --装备行
	Max = 7
}

