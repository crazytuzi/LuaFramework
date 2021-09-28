TiantiConst = {}
TiantiConst.nextKillNotice = {
	[3] = "玩家{0}已经连杀3人，大杀特杀！",
	[4] = "玩家{0}已经连杀4人，杀人如麻！",
	[5] = "玩家{0}已经连杀5人，无人可挡！",
	[6] = "玩家{0}已经连杀6人，变态杀戮！",
	[7] = "玩家{0}已经连杀7人，妖怪杀戮！",
	[8] = "玩家{0}已经连杀8人，神一般杀戮！",
	[9] = "玩家{0}已经连杀9人，超神杀戮！"
}
TiantiConst.killNotice = {
	[1] = "玩家{0}在{1}地图杀死了{2}！",
	[2] = "玩家{0}在{1}地图杀死了{2}！复仇成功！",
	[3] = "玩家{0}在{1}地图杀死了{2}，成功阻止了{2}疯狂的杀戮！"
}

-- 事件
TiantiConst.INFO_CHANGE = "0"
TiantiConst.Rank_CHANGE = "1"
TiantiConst.GET_RANKDATA = "2"
TiantiConst.GET_INFO = "3"
TiantiConst.E_MATCH_STATE_CHANGE = "4"
TiantiConst.E_PK_ITEM_INIT = "5"
TiantiConst.E_PK_ITEM_CHANGE = "6"
TiantiConst.E_CF_REWARD_UPDATE = "7" --冲锋奖励
TiantiConst.E_MATCH_ENTER = "8"-- 进入匹配状态

-- 每次排行请求数量
TiantiConst.offset = 12

-- 主面板中5个星星位置
TiantiConst.starPos = {
	[1] = {157, 57},
	[2] = {112, 73},
	[3] = {205, 73},
	[4] = {76, 102},
	[5] = {239, 102},
}

TiantiConst.starPosEven2 =
{
	[1] = {127, 63},
	[2] = {172, 63},
}

TiantiConst.starPosEven4 = 
{
	[1] = {86, 88},
	[2] = {127, 63},
	[3] = {172, 63},
	[4] = {215, 88},
}

TiantiConst.OrderFont = {
	[1] = UIPackage.GetItemURL("Common", "num_0"), -- 面板上四名后 -30, 17
	[2] = UIPackage.GetItemURL("Common", "num_1"), -- 自己四名后 9, 45
	[3] = UIPackage.GetItemURL("Common", "num_2"), -- 前三字体 -16, 8	-8, 25
}

-- StringToTable( content ) {类型1装备,2物品,3金币, id, 数量, 绑定}
TiantiConst.AwardDesc = {
	desc = "白银段位本赛季技术后可以领取[color=#ffff00]500元宝[/color],黄金段位本赛季结束后可以领取[color=#ffff00]500元宝[/color]、[color=#ffff00]20级卓越装备[/color]一件",
	award = {{3, {0, 0, 0}, 1, 1}, {1, {1100104, 1100104, 1100104}, 1, 1}, {2, {20021, 20021, 20021}, 1, 1}}
}

TiantiConst.CF_REWARD_STATE = 
{
	CANNOT_GET = 1, --未领取 && 不可领取
	CAN_GET = 2,	--未领取 && 可领取
}

TiantiConst.IconDuanweiTab = { "qingtong", "baiyin", "huangjin", "bojin", "zuanshi", "tianren" }