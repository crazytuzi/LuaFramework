----------------------------------------------------
-- 此文件由数据工具生成
-- 无尽试炼--endless_data.xml
--------------------------------------

Config = Config or {} 
Config.EndlessData = Config.EndlessData or {}

LocalizedConfigRequire("config.auto_config.endless_data@data_buff_data")
LocalizedConfigRequire("config.auto_config.endless_data@data_const")
LocalizedConfigRequire("config.auto_config.endless_data@data_explain")
LocalizedConfigRequire("config.auto_config.endless_data@data_first_data")
LocalizedConfigRequire("config.auto_config.endless_data@data_floor_data")
LocalizedConfigRequire("config.auto_config.endless_data@data_new_type")
LocalizedConfigRequire("config.auto_config.endless_data@data_rank_reward_data")

-- -------------------const_start-------------------
Config.EndlessData.data_const_fun = function(key)
	local data=Config.EndlessData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.EndlessData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------buff_data_start-------------------
-- -------------------buff_data_end---------------------


-- -------------------first_data_start-------------------
-- -------------------first_data_end---------------------


-- -------------------floor_data_start-------------------
-- -------------------floor_data_end---------------------


-- -------------------rank_reward_data_start-------------------
-- -------------------rank_reward_data_end---------------------


-- -------------------explain_start-------------------
-- -------------------explain_end---------------------


-- -------------------new_type_start-------------------
Config.EndlessData.data_new_type_fun = function(key)
	local data=Config.EndlessData.data_new_type[key]
	if DATA_DEBUG and data == nil then
		print('(Config.EndlessData.data_new_type['..key..'])not found') return
	end
	return data
end
-- -------------------new_type_end---------------------
