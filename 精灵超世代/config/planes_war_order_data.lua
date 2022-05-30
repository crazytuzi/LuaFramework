----------------------------------------------------
-- 此文件由数据工具生成
-- 位面战令配置数据--planes_war_order_data.xml
--------------------------------------

Config = Config or {} 
Config.PlanesWarOrderData = Config.PlanesWarOrderData or {}

LocalizedConfigRequire("config.auto_config.planes_war_order_data@data_lev_reward_list")
LocalizedConfigRequire("config.auto_config.planes_war_order_data@data_period_day")
LocalizedConfigRequire("config.auto_config.planes_war_order_data@data_advance_card_list")
LocalizedConfigRequire("config.auto_config.planes_war_order_data@data_constant")

-- -------------------constant_start-------------------
Config.PlanesWarOrderData.data_constant_fun = function(key)
	local data=Config.PlanesWarOrderData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesWarOrderData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------lev_reward_list_start-------------------
-- -------------------lev_reward_list_end---------------------


-- -------------------advance_card_list_start-------------------
-- -------------------advance_card_list_end---------------------


-- -------------------period_day_start-------------------
Config.PlanesWarOrderData.data_period_day_fun = function(key)
	local data=Config.PlanesWarOrderData.data_period_day[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesWarOrderData.data_period_day['..key..'])not found') return
	end
	return data
end
-- -------------------period_day_end---------------------
