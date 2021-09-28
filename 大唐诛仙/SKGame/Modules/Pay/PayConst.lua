PayConst = {}

PayConst.PayType = {
	NormalCard = 0, -- 普通充值
	MonthCard = 1, --月卡充值
	Growup = 2, -- 成长基金
	Vip = 3,
}

-- 需要获取的数值类型
PayConst.GetType = {
	Id = "id", 
	Price = "price", -- 金额
	Gold = "gold", -- 元宝
	Premium = "premium", -- 赠送
	TypeValue = "type", -- 充值类型
	Lefttag = "lefttag", -- 左标志
	Righttag = "righttag", -- 右标志
}