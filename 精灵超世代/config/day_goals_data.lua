----------------------------------------------------
-- 此文件由数据工具生成
-- 章节副本配置数据--day_goals_data.xml
--------------------------------------

Config = Config or {} 
Config.DayGoalsData = Config.DayGoalsData or {}

LocalizedConfigRequire("config.auto_config.day_goals_data@data_growthtarget")
LocalizedConfigRequire("config.auto_config.day_goals_data@data_halfdiscount")
LocalizedConfigRequire("config.auto_config.day_goals_data@data_welfarecollection")
LocalizedConfigRequire("config.auto_config.day_goals_data@data_all_target")
LocalizedConfigRequire("config.auto_config.day_goals_data@data_constant")
LocalizedConfigRequire("config.auto_config.day_goals_data@data_drama_explain")

-- -------------------constant_start-------------------
Config.DayGoalsData.data_constant_fun = function(key)
	local data=Config.DayGoalsData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DayGoalsData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------welfarecollection_start-------------------
-- -------------------welfarecollection_end---------------------


-- -------------------growthtarget_start-------------------
-- -------------------growthtarget_end---------------------


-- -------------------halfdiscount_start-------------------
-- -------------------halfdiscount_end---------------------


-- -------------------all_target_start-------------------
-- -------------------all_target_end---------------------


-- -------------------drama_explain_start-------------------
Config.DayGoalsData.data_drama_explain_fun = function(key)
	local data=Config.DayGoalsData.data_drama_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DayGoalsData.data_drama_explain['..key..'])not found') return
	end
	return data
end
-- -------------------drama_explain_end---------------------
