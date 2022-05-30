----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_nian_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayNianData = Config.HolidayNianData or {}

LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_evt_info")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_exchange")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_harm_reward")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_rank_reward")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_redbag_progress")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_board")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_const")
LocalizedConfigRequire("config.auto_config.holiday_nian_data@data_dialogue")

-- -------------------const_start-------------------
Config.HolidayNianData.data_const_fun = function(key)
	local data=Config.HolidayNianData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNianData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------evt_info_start-------------------
Config.HolidayNianData.data_evt_info_fun = function(key)
	local data=Config.HolidayNianData.data_evt_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNianData.data_evt_info['..key..'])not found') return
	end
	return data
end
-- -------------------evt_info_end---------------------


-- -------------------dialogue_start-------------------
Config.HolidayNianData.data_dialogue_fun = function(key)
	local data=Config.HolidayNianData.data_dialogue[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNianData.data_dialogue['..key..'])not found') return
	end
	return data
end
-- -------------------dialogue_end---------------------


-- -------------------drama_start-------------------
Config.HolidayNianData.data_drama_fun = function(key)
	local data=Config.HolidayNianData.data_drama[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNianData.data_drama['..key..'])not found') return
	end
	return data
end
-- -------------------drama_end---------------------


-- -------------------board_start-------------------
Config.HolidayNianData.data_board_fun = function(key)
	local data=Config.HolidayNianData.data_board[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNianData.data_board['..key..'])not found') return
	end
	return data
end
-- -------------------board_end---------------------


-- -------------------redbag_progress_start-------------------
-- -------------------redbag_progress_end---------------------


-- -------------------harm_reward_start-------------------
-- -------------------harm_reward_end---------------------


-- -------------------rank_reward_start-------------------
-- -------------------rank_reward_end---------------------


-- -------------------exchange_start-------------------
Config.HolidayNianData.data_exchange_fun = function(key)
	local data=Config.HolidayNianData.data_exchange[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNianData.data_exchange['..key..'])not found') return
	end
	return data
end
-- -------------------exchange_end---------------------
