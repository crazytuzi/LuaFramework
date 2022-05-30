----------------------------------------------------
-- 此文件由数据工具生成
-- 宠物出行--home_pet_data.xml
--------------------------------------

Config = Config or {} 
Config.HomePetData = Config.HomePetData or {}

LocalizedConfigRequire("config.auto_config.home_pet_data@data_const")
LocalizedConfigRequire("config.auto_config.home_pet_data@data_event_info")
LocalizedConfigRequire("config.auto_config.home_pet_data@data_interaction_info")


-- -------------------const_start-------------------
Config.HomePetData.data_const_fun = function(key)
	local data=Config.HomePetData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomePetData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------event_info_start-------------------
Config.HomePetData.data_event_info_fun = function(key)
	local data=Config.HomePetData.data_event_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomePetData.data_event_info['..key..'])not found') return
	end
	return data
end
-- -------------------event_info_end---------------------


-- -------------------interaction_info_start-------------------
Config.HomePetData.data_interaction_info_fun = function(key)
	local data=Config.HomePetData.data_interaction_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HomePetData.data_interaction_info['..key..'])not found') return
	end
	return data
end
-- -------------------interaction_info_end---------------------
