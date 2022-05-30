----------------------------------------------------
-- 此文件由数据工具生成
-- 银币市场数据--market_silver_data.xml
--------------------------------------

Config = Config or {} 
Config.MarketSilverData = Config.MarketSilverData or {}

-- -------------------market_sliver_cost_start-------------------
Config.MarketSilverData.data_market_sliver_cost_length = 9
Config.MarketSilverData.data_market_sliver_cost = {
	["silvermarket_time"] = {key="silvermarket_time", val=180, desc="银币市场刷新时间"},
	["silvermarket_cost"] = {key="silvermarket_cost", val=3000, desc="银币市场刷新消耗银币"},
	["silvermarket_tax"] = {key="silvermarket_tax", val=0.05, desc="银币市场税率"},
	["silvermarket_type"] = {key="silvermarket_type", val={1}, desc="银币市场类型显示"},
	["silvermarket_booth"] = {key="silvermarket_booth", val=6, desc="初始摊位开放数"},
	["silvermarket_boothnum"] = {key="silvermarket_boothnum", val=8, desc="摊位总数"},
	["silvermarket_saleplus"] = {key="silvermarket_saleplus", val=95, desc="摆摊价格调整下限"},
	["silvermarket_salereduce"] = {key="silvermarket_salereduce", val=105, desc="摆摊价格调整上限"},
	["silvermarket_salechange"] = {key="silvermarket_salechange", val=5, desc="摆摊价格调整幅度"}
}
-- -------------------market_sliver_cost_end---------------------


-- -------------------antique_list_start-------------------
Config.MarketSilverData.data_antique_list_length = 10
Config.MarketSilverData.data_antique_list = {
	[11000] = {base_id=11000, type=1, is_quest_need=0, gain_label="silver_coin", def_price=600000, min_price=570000, max_price=630000},
	[11001] = {base_id=11001, type=1, is_quest_need=0, gain_label="silver_coin", def_price=600000, min_price=570000, max_price=630000},
	[11002] = {base_id=11002, type=1, is_quest_need=0, gain_label="silver_coin", def_price=300000, min_price=285000, max_price=315000},
	[11003] = {base_id=11003, type=1, is_quest_need=0, gain_label="silver_coin", def_price=300000, min_price=285000, max_price=315000},
	[11004] = {base_id=11004, type=1, is_quest_need=0, gain_label="silver_coin", def_price=300000, min_price=285000, max_price=315000},
	[11005] = {base_id=11005, type=1, is_quest_need=0, gain_label="silver_coin", def_price=300000, min_price=285000, max_price=315000},
	[11006] = {base_id=11006, type=1, is_quest_need=0, gain_label="silver_coin", def_price=100000, min_price=95000, max_price=105000},
	[11007] = {base_id=11007, type=1, is_quest_need=0, gain_label="silver_coin", def_price=100000, min_price=95000, max_price=105000},
	[11008] = {base_id=11008, type=1, is_quest_need=0, gain_label="silver_coin", def_price=100000, min_price=95000, max_price=105000},
	[11009] = {base_id=11009, type=1, is_quest_need=0, gain_label="silver_coin", def_price=100000, min_price=95000, max_price=105000}
}
-- -------------------antique_list_end---------------------


-- -------------------shop_open_start-------------------
Config.MarketSilverData.data_shop_open_length = 6
Config.MarketSilverData.data_shop_open = {
	[7] = {loss={{2,100000}}},
	[8] = {loss={{2,200000}}},
	[9] = {loss={{2,300000}}},
	[10] = {loss={{2,400000}}},
	[11] = {loss={{3,100}}},
	[12] = {loss={{3,200}}}
}
-- -------------------shop_open_end---------------------
