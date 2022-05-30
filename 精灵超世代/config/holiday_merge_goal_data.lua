----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_merge_goal_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayMergeGoalData = Config.HolidayMergeGoalData or {}

LocalizedConfigRequire("config.auto_config.holiday_merge_goal_data@data_interval")
LocalizedConfigRequire("config.auto_config.holiday_merge_goal_data@data_score_award")
LocalizedConfigRequire("config.auto_config.holiday_merge_goal_data@data_all_interval")
LocalizedConfigRequire("config.auto_config.holiday_merge_goal_data@data_const")

-- -------------------const_start-------------------
Config.HolidayMergeGoalData.data_const_fun = function(key)
	local data=Config.HolidayMergeGoalData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayMergeGoalData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------score_award_start-------------------
Config.HolidayMergeGoalData.data_score_award_fun = function(key)
	local data=Config.HolidayMergeGoalData.data_score_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayMergeGoalData.data_score_award['..key..'])not found') return
	end
	return data
end
-- -------------------score_award_end---------------------


-- -------------------interval_start-------------------
Config.HolidayMergeGoalData.data_interval_fun = function(key)
	local data=Config.HolidayMergeGoalData.data_interval[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayMergeGoalData.data_interval['..key..'])not found') return
	end
	return data
end
-- -------------------interval_end---------------------


-- -------------------all_interval_start-------------------
Config.HolidayMergeGoalData.data_all_interval_fun = function(key)
	local data=Config.HolidayMergeGoalData.data_all_interval[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayMergeGoalData.data_all_interval['..key..'])not found') return
	end
	return data
end
-- -------------------all_interval_end---------------------
