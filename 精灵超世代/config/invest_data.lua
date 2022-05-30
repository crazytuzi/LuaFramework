----------------------------------------------------
-- 此文件由数据工具生成
-- 投资配置数据--invest_data.xml
--------------------------------------

Config = Config or {} 
Config.InvestData = Config.InvestData or {}

-- -------------------invest_lev_start-------------------
Config.InvestData.data_invest_lev_length = 11
Config.InvestData.data_invest_lev = {
	[1] = {lev=1, items={{2,888}}},
	[15] = {lev=15, items={{2,388}}},
	[25] = {lev=25, items={{2,488}}},
	[30] = {lev=30, items={{2,588}}},
	[32] = {lev=32, items={{2,688}}},
	[34] = {lev=34, items={{2,688}}},
	[36] = {lev=36, items={{2,888}}},
	[40] = {lev=40, items={{2,888}}},
	[45] = {lev=45, items={{2,988}}},
	[50] = {lev=50, items={{2,988}}},
	[60] = {lev=60, items={{2,1088}}}
}
-- -------------------invest_lev_end---------------------


-- -------------------invest_day_start-------------------
Config.InvestData.data_invest_day_length = 7
Config.InvestData.data_invest_day = {
	[1] = {day=1, items={{2,880},{1,200000}}},
	[2] = {day=2, items={{2,388},{1,200000}}},
	[3] = {day=3, items={{2,488},{1,200000}}},
	[4] = {day=4, items={{2,588},{1,200000}}},
	[5] = {day=5, items={{2,688},{1,200000}}},
	[6] = {day=6, items={{2,888},{1,200000}}},
	[7] = {day=7, items={{2,1088},{1,200000}}}
}
-- -------------------invest_day_end---------------------
