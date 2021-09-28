RechargeConst = {}

RechargeConst.DailyRechargeData = "RechargeConst.DailyRechargeData"
RechargeConst.DailyRechargeGet = "RechargeConst.DailyRechargeGet"
RechargeConst.LQJijinData = "RechargeConst.LQJijinData"
RechargeConst.allRewardData = "RechargeConst.allRewardData"
RechargeConst.SuccessJiJinBuy = "RechargeConst.SuccessJiJinBuy"

RechargeConst.RechargeType = {
	None = 0,
	DailyRecharge = 1,
	GrowUpJijin = 2,
	SevenRecharge = 3,
	TotalRecharge = 4,
	TotalPay = 5, -- 累计消费
	--MonthCard = 6, --月卡
	Turn = 6,	--转盘
	Tomb = 7,	--陵墓
}

-- RechargeConst.RechargeState = {
-- 	None = -1, --默认状态
-- 	CannotGet = 0, --不可领取
-- 	CanGet = 1, --可领取
-- 	HasGet = 2, --已经领取
-- }

-- 探墓
-- 陵墓名称
RechargeConst.TombName = 
{
	[1] = "东皇陵墓",
	[2] = "灵山古墓",
	[3] = "秦王陵",
	[4] = "灰河地宫",
	[5] = "佚名之冢",
	[6] = "罗刹塔",
	[7] = "天罡古墓",
	[8] = "紫藤冢",
	[9] = "先民遗址",
	[10] = "暗灯古道",
	[11] = "葬花陵",
	[12] = "轮回古道",
}

RechargeConst.E_GetTombData = "1"
RechargeConst.E_TombResult  = "2"
RechargeConst.E_ChangeTomb  = "3"

RechargeConst.kMaxCellNum = 9 --最大墓室数量
RechargeConst.TombCellState = 
{
	NotFinish = 1,	-- 未探索
	Finish = 2	-- 已探索
}
RechargeConst.URL_TOMB_CHANGE_COST = "Icon/Goods/diamond"
RechargeConst.TOMB_COST_TAB = {39, 40, 41}
-- 转盘
RechargeConst.KEY_CURLAYER = "CurTombLayer"
RechargeConst.E_GetTurntableData = "11"
RechargeConst.E_TurntableDraw = "12"
RechargeConst.E_GetTurnRecList = "13"
RechargeConst.E_ResetTurnContent = "14"

RechargeConst.TurnCostType = 
{
	Free = 1,
	Item = 2,
	Diamond = 3
}
RechargeConst.TURN_ITEM_COST = 1 --转一次消耗的道具数量
RechargeConst.TURN_GOODS_NUM = 12 --转盘所能显示的物品数量
RechargeConst.TURN_LIST_START_IDX = 1 --历史列表开始下标
RechargeConst.RefreshContentInFrame = "RechargeConst.RefreshContentInFrame"
RechargeConst.KEY_RENDER_TURNING = "RechargeConst.KEY_RENDER_TURNING"
RechargeConst.UNIT_ANGLE = 30

RechargeConst.TombCostColor = 
{
	[36101] = "#348a37",
	[36102] = "#1b72de",
	[36103] = "#8f3eb4",
}
-- 七日累计充值
RechargeConst.E_GetSevenPayData = "21"
RechargeConst.E_GetSevenPayReward = "22"
RechargeConst.SevenState = 
{
	NotOpen = 1,
	Open = 2,
}
RechargeConst.SevenRechargeNum = 
{
	[1] = 30,
	[2] = 60,
	[3] = 100
}
RechargeConst.KEY_SEVEN_RED = "SevenRed"

RechargeConst.TombDescNameColor =
{
	[0] = "#2e3341",
	[1] = "#2e3341",
	[2] = "#348a37",
	[3] = "#1b72de",
	[4] = "#8f3eb4",
	[5] = "#d89401",
}