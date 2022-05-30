----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--artifact_exchange_data.xml
--------------------------------------

Config = Config or {} 
Config.ArtifactExchangeData = Config.ArtifactExchangeData or {}

-- -------------------artifact_exchange_const_start-------------------
Config.ArtifactExchangeData.data_artifact_exchange_const_length = 6
Config.ArtifactExchangeData.data_artifact_exchange_const = {
	["open_lev"] = {key="open_lev", val=35, desc="解锁神器商城等级"},
	["cost_gold"] = {key="cost_gold", val=10, desc="刷新神秘商店的钻石数"},
	["mall_def"] = {key="mall_def", val=6, desc="初始格子数"},
	["mall_max"] = {key="mall_max", val=6, desc="最大格子数"},
	["ref_time"] = {key="ref_time", val={21,0,0}, desc="商城刷新时间"},
	["ref_cost"] = {key="ref_cost", val={20,50}, desc="刷新商城消耗资产"}
}
-- -------------------artifact_exchange_const_end---------------------


-- -------------------vip_lev_start-------------------
Config.ArtifactExchangeData.data_vip_lev_length = 16
Config.ArtifactExchangeData.data_vip_lev = {
	[0] = {vip_lev=0, free=1, max=10},
	[1] = {vip_lev=1, free=2, max=15},
	[2] = {vip_lev=2, free=3, max=20},
	[3] = {vip_lev=3, free=4, max=25},
	[4] = {vip_lev=4, free=5, max=30},
	[5] = {vip_lev=5, free=6, max=35},
	[6] = {vip_lev=6, free=7, max=40},
	[7] = {vip_lev=7, free=8, max=45},
	[8] = {vip_lev=8, free=9, max=50},
	[9] = {vip_lev=9, free=10, max=55},
	[10] = {vip_lev=10, free=11, max=60},
	[11] = {vip_lev=11, free=12, max=65},
	[12] = {vip_lev=12, free=13, max=70},
	[13] = {vip_lev=13, free=14, max=75},
	[14] = {vip_lev=14, free=15, max=80},
	[15] = {vip_lev=15, free=16, max=90}
}
-- -------------------vip_lev_end---------------------
