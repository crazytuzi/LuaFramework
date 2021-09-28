TradingConst = {}

-- 面板大标签类型
TradingConst.tabType = {
	store = "0", -- 商  店
	stall = "1" -- 寄  售
}
-- 左侧类型 (商店， 寄售购买)
-- 二级类
TradingConst.subType = {
	[1] = {
			{0, "综合"},
			{7, "武器"},
			{8, "法宝"},
			{1, "头盔"},
			{2, "铠甲"},
			{3, "鞋子"},
			{4, "项链"},
			{5, "护腕"},
			{6, "戒指"},
		},
	[2] = {
			{201, "红药"},
			{202, "蓝药"},
			{203, "经验药水"},
			},
	[3] = {
			{300, "通用"},
			{301, "战士"},
			{302, "法师"},
			{303, "暗巫"},
		},
	[4] = {
			{401, "注灵石"},
			{402, "羽毛"},
			{403, "技能书"},
		},
	[5] = {
			{7, "武器"},
			{8, "法宝"},
			{1, "头盔"},
			{2, "铠甲"},
			{3, "鞋子"},
			{4, "项链"},
			{5, "护腕"},
			{6, "戒指"},
		},
	[6] = {
			{601, "其他"},
		},
}
-- 一级类型
TradingConst.bigType = {
	[1] = {1, "装备", TradingConst.subType[1]},
	[2] = {2, "消耗", TradingConst.subType[2]},
	[3] = {3, "印记", TradingConst.subType[3]},
	[4] = {4, "强化", TradingConst.subType[4]},
	[5] = {5, "装备", TradingConst.subType[5]},
	[6] = {6, "其他", TradingConst.subType[6]},
}

-- 商店 分类列表组合
TradingConst.storeTabs = {
	[1] = TradingConst.bigType[2],
	[2] = TradingConst.bigType[5],
	[3] = TradingConst.bigType[4],
	[4] = TradingConst.bigType[3],

}
-- 寄售 分类列表组合
TradingConst.stallTabs = {
	[1] = TradingConst.bigType[1],
	[2] = TradingConst.bigType[3],
	[3] = TradingConst.bigType[4],
	[4] = TradingConst.bigType[6],
}
-- 寄售标签
TradingConst.stallTabType = {
	buy = "0",	
	sell = "1"
}
-- 

-- 开摊位格子价格
TradingConst.OpenStallGridPrice = {4, 100} -- 10个xx
-- 上架出售手续费
TradingConst.Fee = {3, 0.1} -- 10%手续费
-- 交易行货币类型
TradingConst.TradeType = 3
-- 总摊位数量
TradingConst.TotalShelf = 20
-- 默认显示背包数量
TradingConst.PkgNum = 12

-- 商城价格货币类型
TradingConst.storePayType = GoodsVo.GoodType.gold

-- 商品项类型
TradingConst.itemType = {
	none = 0, -- 无
	sysSell = "sysSell", -- 系统上寄售物品类型
	pkgStall = "pkgStall", -- 玩家自己寄售背包物品类型
	shelf = "shelf", -- 玩家货架物品类型
}

-- 寄售购买每次滑动请求个数
TradingConst.Offset = 20

-- 事件
TradingConst.STALL_PKG_CHANGED = "0" -- 背包信息变化
TradingConst.STALL_MY_CHANGED = "1" -- (个人)商品信息变化
TradingConst.STALL_SYS_CHANGED = "2" -- (所有玩家)商品信息变化
TradingConst.STORE_RETURN = "4" -- 商店购买返回

TradingConst.SHELF_NUM_CHANGE = "5" -- 扩展货架


TradingConst.STALL_BUY = "6" -- 寄售购买提示事件
TradingConst.STALL_PUTON = "7" -- 上架提示事件
TradingConst.STALL_PUTOFF = "8" -- 下架提示事件
TradingConst.STALL_RE_PUTON = "9" -- 重新上架