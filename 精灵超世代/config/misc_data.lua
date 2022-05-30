----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--misc_data.xml
--------------------------------------

Config = Config or {} 
Config.MiscData = Config.MiscData or {}

LocalizedConfigRequire("config.auto_config.misc_data@data_cycle_gift_info")
LocalizedConfigRequire("config.auto_config.misc_data@data_cycle_gift_reward")
LocalizedConfigRequire("config.auto_config.misc_data@data_get_time_items")
LocalizedConfigRequire("config.auto_config.misc_data@data_const")

-- -------------------const_start-------------------
Config.MiscData.data_const_fun = function(key)
	local data=Config.MiscData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MiscData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------get_time_items_start-------------------
Config.MiscData.data_get_time_items_fun = function(key)
	local data=Config.MiscData.data_get_time_items[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MiscData.data_get_time_items['..key..'])not found') return
	end
	return data
end
-- -------------------get_time_items_end---------------------


-- -------------------cycle_gift_info_start-------------------
-- -------------------cycle_gift_info_end---------------------


-- -------------------cycle_gift_reward_start-------------------
-- -------------------cycle_gift_reward_end---------------------
