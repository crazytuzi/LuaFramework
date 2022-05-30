----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_exchange_data.xml
--------------------------------------

LocalizedConfigRequire("config.auto_config.holiday_exchange_data@data_constant")
LocalizedConfigRequire("config.auto_config.holiday_exchange_data@data_get_config_const")

Config = Config or {} 
Config.HolidayExchangeData = Config.HolidayExchangeData or {}

-- -------------------constant_start-------------------
Config.HolidayExchangeData.data_constant_fun = function(key)
	local data=Config.HolidayExchangeData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayExchangeData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------get_config_const_start-------------------
Config.HolidayExchangeData.data_get_config_const_fun = function(key)
	local data=Config.HolidayExchangeData.data_get_config_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayExchangeData.data_get_config_const['..key..'])not found') return
	end
	return data
end
-- -------------------get_config_const_end---------------------
