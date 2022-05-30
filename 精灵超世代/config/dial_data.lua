----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--dial_data.xml
--------------------------------------

Config = Config or {} 
Config.DialData = Config.DialData or {}

LocalizedConfigRequire("config.auto_config.dial_data@data_const")
LocalizedConfigRequire("config.auto_config.dial_data@data_get_limit_open")
LocalizedConfigRequire("config.auto_config.dial_data@data_get_lucky_award")
LocalizedConfigRequire("config.auto_config.dial_data@data_get_rand_list")
LocalizedConfigRequire("config.auto_config.dial_data@data_magnificat_list")

-- -------------------const_start-------------------
Config.DialData.data_const_fun = function(key)
	local data=Config.DialData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DialData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------rewards_start-------------------
Config.DialData.data_rewards_length = 0
Config.DialData.data_rewards = {

}
Config.DialData.data_rewards_fun = function(key)
	local data=Config.DialData.data_rewards[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DialData.data_rewards['..key..'])not found') return
	end
	return data
end
-- -------------------rewards_end---------------------


-- -------------------get_limit_open_start-------------------
-- -------------------get_limit_open_end---------------------


-- -------------------get_lucky_award_start-------------------
-- -------------------get_lucky_award_end---------------------


-- -------------------get_rand_list_start-------------------
-- -------------------get_rand_list_end---------------------


-- -------------------magnificat_list_start-------------------
-- -------------------magnificat_list_end---------------------
