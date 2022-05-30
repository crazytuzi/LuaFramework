----------------------------------------------------
-- 此文件由数据工具生成
-- 炼金场配置--trade_data.xml
--------------------------------------

Config = Config or {} 
Config.TradeData = Config.TradeData or {}

-- -------------------trade_cost_start-------------------
Config.TradeData.data_trade_cost_length = 3
Config.TradeData.data_trade_cost = {
	["open_lev"] = {label='open_lev', val=14, desc="开启等级"},
	["cost_item1"] = {label='cost_item1', val=10401, desc="大瓶体力（购买体力显示物品，优先级高）"},
	["cost_item2"] = {label='cost_item2', val=10400, desc="小瓶体力（购买体力显示物品，优先级低）"}
}
-- -------------------trade_cost_end---------------------


-- -------------------trade_base_start-------------------
Config.TradeData.data_trade_base_length = 3
Config.TradeData.data_trade_base = {
	[1] = {type=1, name="金币", assets="coin", make_speed={30,40}, make_max=50000, ui_desc="4800金币/时"},
	[2] = {type=2, name="英雄经验", assets="partner_exp_all", make_speed={30,4}, make_max=5000, ui_desc="480经验/时"},
	[3] = {type=3, name="体力", assets="energy", make_speed={}, make_max=100, ui_desc=""}
}
-- -------------------trade_base_end---------------------


-- -------------------trade_count_start-------------------
Config.TradeData.data_trade_count_length = 3
Config.TradeData.data_trade_count = {
	[1] = {
		[0] = {type=1, vip_lev=0, max=2},
		[1] = {type=1, vip_lev=1, max=3},
		[2] = {type=1, vip_lev=2, max=5},
		[3] = {type=1, vip_lev=3, max=7},
		[4] = {type=1, vip_lev=4, max=9},
		[5] = {type=1, vip_lev=5, max=11},
		[6] = {type=1, vip_lev=6, max=13},
		[7] = {type=1, vip_lev=7, max=15},
		[8] = {type=1, vip_lev=8, max=17},
		[9] = {type=1, vip_lev=9, max=19},
		[10] = {type=1, vip_lev=10, max=21},
		[11] = {type=1, vip_lev=11, max=23},
		[12] = {type=1, vip_lev=12, max=25},
		[13] = {type=1, vip_lev=13, max=27},
		[14] = {type=1, vip_lev=14, max=29},
		[15] = {type=1, vip_lev=15, max=31},
	},
	[2] = {
		[0] = {type=2, vip_lev=0, max=2},
		[1] = {type=2, vip_lev=1, max=3},
		[2] = {type=2, vip_lev=2, max=4},
		[3] = {type=2, vip_lev=3, max=5},
		[4] = {type=2, vip_lev=4, max=6},
		[5] = {type=2, vip_lev=5, max=7},
		[6] = {type=2, vip_lev=6, max=8},
		[7] = {type=2, vip_lev=7, max=9},
		[8] = {type=2, vip_lev=8, max=10},
		[9] = {type=2, vip_lev=9, max=11},
		[10] = {type=2, vip_lev=10, max=12},
		[11] = {type=2, vip_lev=11, max=13},
		[12] = {type=2, vip_lev=12, max=14},
		[13] = {type=2, vip_lev=13, max=15},
		[14] = {type=2, vip_lev=14, max=16},
		[15] = {type=2, vip_lev=15, max=17},
	},
	[3] = {
		[0] = {type=3, vip_lev=0, max=2},
		[1] = {type=3, vip_lev=1, max=3},
		[2] = {type=3, vip_lev=2, max=4},
		[3] = {type=3, vip_lev=3, max=5},
		[4] = {type=3, vip_lev=4, max=6},
		[5] = {type=3, vip_lev=5, max=7},
		[6] = {type=3, vip_lev=6, max=8},
		[7] = {type=3, vip_lev=7, max=9},
		[8] = {type=3, vip_lev=8, max=10},
		[9] = {type=3, vip_lev=9, max=11},
		[10] = {type=3, vip_lev=10, max=12},
		[11] = {type=3, vip_lev=11, max=13},
		[12] = {type=3, vip_lev=12, max=14},
		[13] = {type=3, vip_lev=13, max=15},
		[14] = {type=3, vip_lev=14, max=16},
		[15] = {type=3, vip_lev=15, max=17},
	},
}
-- -------------------trade_count_end---------------------


-- -------------------trade_use_start-------------------
Config.TradeData.data_trade_use_length = 3
Config.TradeData.data_trade_use = {
	[1] = {
		[1] = {count=1, type=1, loss=20},
		[2] = {count=2, type=1, loss=20},
		[3] = {count=3, type=1, loss=30},
		[4] = {count=4, type=1, loss=30},
		[5] = {count=5, type=1, loss=30},
		[6] = {count=6, type=1, loss=30},
		[7] = {count=7, type=1, loss=30},
		[8] = {count=8, type=1, loss=30},
		[9] = {count=9, type=1, loss=40},
		[10] = {count=10, type=1, loss=40},
		[11] = {count=11, type=1, loss=40},
		[12] = {count=12, type=1, loss=40},
		[13] = {count=13, type=1, loss=40},
		[14] = {count=14, type=1, loss=40},
		[15] = {count=15, type=1, loss=40},
		[16] = {count=16, type=1, loss=50},
		[17] = {count=17, type=1, loss=50},
		[18] = {count=18, type=1, loss=50},
		[19] = {count=19, type=1, loss=50},
		[20] = {count=20, type=1, loss=50},
		[21] = {count=21, type=1, loss=50},
		[22] = {count=22, type=1, loss=50},
		[23] = {count=23, type=1, loss=50},
		[24] = {count=24, type=1, loss=50},
		[25] = {count=25, type=1, loss=50},
		[26] = {count=26, type=1, loss=60},
		[27] = {count=27, type=1, loss=60},
		[28] = {count=28, type=1, loss=60},
		[29] = {count=29, type=1, loss=60},
		[30] = {count=30, type=1, loss=60},
		[31] = {count=31, type=1, loss=60},
		[32] = {count=32, type=1, loss=60},
		[33] = {count=33, type=1, loss=60},
		[34] = {count=34, type=1, loss=60},
		[35] = {count=35, type=1, loss=60},
	},
	[2] = {
		[1] = {count=1, type=2, loss=20},
		[2] = {count=2, type=2, loss=20},
		[3] = {count=3, type=2, loss=30},
		[4] = {count=4, type=2, loss=30},
		[5] = {count=5, type=2, loss=30},
		[6] = {count=6, type=2, loss=30},
		[7] = {count=7, type=2, loss=30},
		[8] = {count=8, type=2, loss=30},
		[9] = {count=9, type=2, loss=40},
		[10] = {count=10, type=2, loss=40},
		[11] = {count=11, type=2, loss=40},
		[12] = {count=12, type=2, loss=40},
		[13] = {count=13, type=2, loss=40},
		[14] = {count=14, type=2, loss=40},
		[15] = {count=15, type=2, loss=40},
		[16] = {count=16, type=2, loss=60},
		[17] = {count=17, type=2, loss=60},
		[18] = {count=18, type=2, loss=60},
		[19] = {count=19, type=2, loss=60},
		[20] = {count=20, type=2, loss=60},
		[21] = {count=21, type=2, loss=60},
		[22] = {count=22, type=2, loss=60},
		[23] = {count=23, type=2, loss=60},
		[24] = {count=24, type=2, loss=60},
		[25] = {count=25, type=2, loss=60},
	},
	[3] = {
		[1] = {count=1, type=3, loss=50},
		[2] = {count=2, type=3, loss=50},
		[3] = {count=3, type=3, loss=100},
		[4] = {count=4, type=3, loss=100},
		[5] = {count=5, type=3, loss=150},
		[6] = {count=6, type=3, loss=150},
		[7] = {count=7, type=3, loss=200},
		[8] = {count=8, type=3, loss=200},
		[9] = {count=9, type=3, loss=250},
		[10] = {count=10, type=3, loss=300},
		[11] = {count=11, type=3, loss=350},
		[12] = {count=12, type=3, loss=400},
		[13] = {count=13, type=3, loss=450},
		[14] = {count=14, type=3, loss=500},
		[15] = {count=15, type=3, loss=550},
		[16] = {count=16, type=3, loss=600},
		[17] = {count=17, type=3, loss=650},
		[18] = {count=18, type=3, loss=700},
		[19] = {count=19, type=3, loss=750},
		[20] = {count=20, type=3, loss=800},
		[21] = {count=21, type=3, loss=850},
		[22] = {count=22, type=3, loss=900},
		[23] = {count=23, type=3, loss=950},
		[24] = {count=24, type=3, loss=1000},
		[25] = {count=25, type=3, loss=1050},
	},
}
-- -------------------trade_use_end---------------------


-- -------------------trade_event_start-------------------
Config.TradeData.data_trade_event_length = 2
Config.TradeData.data_trade_event = {
	[1] = {
		[1] = {id=1, type=1, res="E51105", action="action1"},
		[2] = {id=2, type=1, res="E51105", action="action2"},
		[3] = {id=3, type=1, res="E51105", action="action3"},
		[4] = {id=4, type=1, res="E51105", action="action4"},
		[5] = {id=5, type=1, res="E51105", action="action5"},
	},
	[2] = {
		[1] = {id=1, type=2, res="E51105", action="action1"},
		[2] = {id=2, type=2, res="E51105", action="action2"},
		[3] = {id=3, type=2, res="E51105", action="action3"},
		[4] = {id=4, type=2, res="E51105", action="action4"},
		[5] = {id=5, type=2, res="E51105", action="action5"},
	},
}
-- -------------------trade_event_end---------------------
