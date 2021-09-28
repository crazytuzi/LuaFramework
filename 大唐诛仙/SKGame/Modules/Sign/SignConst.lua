SignConst = {}

-- InnerEvent start ==>>

-- 签到数据变化
SignConst.SignMsgChange 		= "SignConst.SignMsgChange"
-- 领取单个连续奖励
SignConst.ConSignGotOne         = "SignConst.ConSignGotOne"

-- InnerEvent end ==<<

SignConst.STR_TITLE 			= "%s月签到奖励"
SignConst.NUM_DAYS 				= 28
SignConst.NUM_PER_LINE 			= 7
SignConst.NUM_LINE 				= 4
SignConst.NUM_REWARD 			= 4
SignConst.STR_YILINGQU 			= "已领取"
SignConst.STR_LINGQU 			= "签 到"
SignConst.URL_BUQIAN_COST		= "Icon/Goods/diamond"
SignConst.BUQIAN_COST_FACTOR    = 10 -- 补签消耗的系数 ( 消耗元宝数 = fac * days )

-- 签到格子状态
SignConst.STATE_GRID = 
{
	YILINGQU = 1,			-- 已领取
	CAN_LINGQU = 2,			-- 未领取 && 可领取
	CAN_BUQIAN = 3,			-- 未领取 && 不可领取 && 可补签
	CANNOT_BUQIAN = 4		-- 未领取 && 不可领取 && 不可补签
}

-- 连续签到奖励状态
SignConst.STATE_REWARD = 
{
	YILINGQU = 1,			-- 已领取
	CAN_LINGQU = 2,			-- 未领取 && 可领取
	CANNOT_LINGQU = 3		-- 未领取 && 不可领取
}