----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--planes_data.xml
--------------------------------------

Config = Config or {} 
Config.PlanesData = Config.PlanesData or {}

LocalizedConfigRequire("config.auto_config.planes_data@data_buff")
LocalizedConfigRequire("config.auto_config.planes_data@data_const")
LocalizedConfigRequire("config.auto_config.planes_data@data_customs")
LocalizedConfigRequire("config.auto_config.planes_data@data_evt_info")
LocalizedConfigRequire("config.auto_config.planes_data@data_reward_info")
LocalizedConfigRequire("config.auto_config.planes_data@data_shop_info")

-- -------------------const_start-------------------
Config.PlanesData.data_const_fun = function(key)
	local data=Config.PlanesData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------customs_start-------------------
Config.PlanesData.data_customs_fun = function(key)
	local data=Config.PlanesData.data_customs[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesData.data_customs['..key..'])not found') return
	end
	return data
end
-- -------------------customs_end---------------------


-- -------------------evt_info_start-------------------
Config.PlanesData.data_evt_info_fun = function(key)
	local data=Config.PlanesData.data_evt_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesData.data_evt_info['..key..'])not found') return
	end
	return data
end
-- -------------------evt_info_end---------------------


-- -------------------shop_info_start-------------------
Config.PlanesData.data_shop_info_fun = function(key)
	local data=Config.PlanesData.data_shop_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesData.data_shop_info['..key..'])not found') return
	end
	return data
end
-- -------------------shop_info_end---------------------


-- -------------------reward_info_start-------------------
-- -------------------reward_info_end---------------------


-- -------------------buff_start-------------------
Config.PlanesData.data_buff_fun = function(key)
	local data=Config.PlanesData.data_buff[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PlanesData.data_buff['..key..'])not found') return
	end
	return data
end
-- -------------------buff_end---------------------
