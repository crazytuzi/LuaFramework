----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--looks_data.xml
--------------------------------------

Config = Config or {} 
Config.LooksData = Config.LooksData or {}

LocalizedConfigRequire("config.auto_config.looks_data@data_data")
LocalizedConfigRequire("config.auto_config.looks_data@data_head_data")

-- -------------------data_start-------------------
Config.LooksData.data_data_fun = function(key)
	local data=Config.LooksData.data_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.LooksData.data_data['..key..'])not found') return
	end
	return data
end
-- -------------------data_end---------------------


-- -------------------head_data_start-------------------
Config.LooksData.data_head_data_fun = function(key)
	local data=Config.LooksData.data_head_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.LooksData.data_head_data['..key..'])not found') return
	end
	return data
end
-- -------------------head_data_end---------------------
