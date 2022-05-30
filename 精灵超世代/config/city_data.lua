----------------------------------------------------
-- 此文件由数据工具生成
-- 城市配置数据--city_data.xml
--------------------------------------

Config = Config or {} 
Config.CityData = Config.CityData or {}

LocalizedConfigRequire("config.auto_config.city_data@data_base")
LocalizedConfigRequire("config.auto_config.city_data@data_const")

-- -------------------base_start-------------------
Config.CityData.data_base_fun = function(key)
	local data=Config.CityData.data_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CityData.data_base['..key..'])not found') return
	end
	return data
end
-- -------------------base_end---------------------


-- -------------------const_start-------------------
Config.CityData.data_const_fun = function(key)
	local data=Config.CityData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CityData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------
