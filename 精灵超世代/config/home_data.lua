----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--home_data.xml
--------------------------------------

Config = Config or {} 
Config.HomeData = Config.HomeData or {}

LocalizedConfigRequire("config.auto_config.home_data@data_const")
LocalizedConfigRequire("config.auto_config.home_data@data_figure")
LocalizedConfigRequire("config.auto_config.home_data@data_home_coin")
LocalizedConfigRequire("config.auto_config.home_data@data_home_storey")
LocalizedConfigRequire("config.auto_config.home_data@data_home_unit")
LocalizedConfigRequire("config.auto_config.home_data@data_role_action")
LocalizedConfigRequire("config.auto_config.home_data@data_suit")
LocalizedConfigRequire("config.auto_config.home_data@data_suit_award")
LocalizedConfigRequire("config.auto_config.home_data@data_suit_soft")
LocalizedConfigRequire("config.auto_config.home_data@data_suit_unit")


-- -------------------const_start-------------------
Config.HomeData.data_const_fun = function(key)
	local data=Config.HomeData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomeData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------home_unit_start-------------------
-- -------------------home_unit_end---------------------


-- -------------------suit_start-------------------
Config.HomeData.data_suit_fun = function(key)
	local data=Config.HomeData.data_suit[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomeData.data_suit['..key..'])not found') return
	end
	return data
end
-- -------------------suit_end---------------------


-- -------------------suit_unit_start-------------------
-- -------------------suit_unit_end---------------------


-- -------------------figure_start-------------------
Config.HomeData.data_figure_fun = function(key)
	local data=Config.HomeData.data_figure[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomeData.data_figure['..key..'])not found') return
	end
	return data
end
-- -------------------figure_end---------------------


-- -------------------suit_award_start-------------------
-- -------------------suit_award_end---------------------


-- -------------------home_coin_start-------------------
Config.HomeData.data_home_coin_fun = function(key)
	local data=Config.HomeData.data_home_coin[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomeData.data_home_coin['..key..'])not found') return
	end
	return data
end
-- -------------------home_coin_end---------------------


-- -------------------suit_soft_start-------------------
-- -------------------suit_soft_end---------------------


-- -------------------role_action_start-------------------
Config.HomeData.data_role_action_fun = function(key)
	local data=Config.HomeData.data_role_action[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomeData.data_role_action['..key..'])not found') return
	end
	return data
end
-- -------------------role_action_end---------------------


-- -------------------home_storey_start-------------------
Config.HomeData.data_home_storey_fun = function(key)
	local data=Config.HomeData.data_home_storey[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomeData.data_home_storey['..key..'])not found') return
	end
	return data
end
-- -------------------home_storey_end---------------------
