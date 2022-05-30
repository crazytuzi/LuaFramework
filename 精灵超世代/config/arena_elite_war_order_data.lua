----------------------------------------------------
-- 此文件由数据工具生成
-- 精英赛战令配置数据--arena_elite_war_order_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaEliteWarOrderData = Config.ArenaEliteWarOrderData or {}

LocalizedConfigRequire("config.auto_config.arena_elite_war_order_data@data_advance_card_list")
LocalizedConfigRequire("config.auto_config.arena_elite_war_order_data@data_constant")
LocalizedConfigRequire("config.auto_config.arena_elite_war_order_data@data_lev_reward_list")

-- -------------------constant_start-------------------
Config.ArenaEliteWarOrderData.data_constant_fun = function(key)
	local data=Config.ArenaEliteWarOrderData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteWarOrderData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------lev_reward_list_start-------------------
-- -------------------lev_reward_list_end---------------------


-- -------------------advance_card_list_start-------------------
-- -------------------advance_card_list_end---------------------
