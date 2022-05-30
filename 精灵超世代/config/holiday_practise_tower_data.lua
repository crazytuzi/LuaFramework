----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_practise_tower_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayPractiseTowerData = Config.HolidayPractiseTowerData or {}

LocalizedConfigRequire("config.auto_config.holiday_practise_tower_data@data_tower")
LocalizedConfigRequire("config.auto_config.holiday_practise_tower_data@data_const")
LocalizedConfigRequire("config.auto_config.holiday_practise_tower_data@data_rank_reward")

-- -------------------const_start-------------------
Config.HolidayPractiseTowerData.data_const_fun = function(key)
	local data=Config.HolidayPractiseTowerData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPractiseTowerData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------tower_start-------------------
Config.HolidayPractiseTowerData.data_tower_fun = function(key)
	local data=Config.HolidayPractiseTowerData.data_tower[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPractiseTowerData.data_tower['..key..'])not found') return
	end
	return data
end
-- -------------------tower_end---------------------


-- -------------------rank_reward_start-------------------
Config.HolidayPractiseTowerData.data_rank_reward_fun = function(key)
	local data=Config.HolidayPractiseTowerData.data_rank_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPractiseTowerData.data_rank_reward['..key..'])not found') return
	end
	return data
end
-- -------------------rank_reward_end---------------------
