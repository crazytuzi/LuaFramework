----------------------------------------------------
-- 此文件由数据工具生成
-- 新七日目标配置数据--day_goals_new_data.xml
--------------------------------------

Config = Config or {} 
Config.DayGoalsNewData = Config.DayGoalsNewData or {}

LocalizedConfigRequire("config.auto_config.day_goals_new_data@data_circle_exp_item")
LocalizedConfigRequire("config.auto_config.day_goals_new_data@data_constant")
LocalizedConfigRequire("config.auto_config.day_goals_new_data@data_group_list")
LocalizedConfigRequire("config.auto_config.day_goals_new_data@data_make_lev_list")
LocalizedConfigRequire("config.auto_config.day_goals_new_data@data_charge_list")

-- -------------------constant_start-------------------
Config.DayGoalsNewData.data_constant_fun = function(key)
	local data=Config.DayGoalsNewData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DayGoalsNewData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------make_lev_list_start-------------------
-- -------------------make_lev_list_end---------------------


-- -------------------circle_exp_item_start-------------------
-- -------------------circle_exp_item_end---------------------


-- -------------------group_list_start-------------------
-- -------------------group_list_end---------------------


-- -------------------charge_list_start-------------------
-- -------------------charge_list_end---------------------
