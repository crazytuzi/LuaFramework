----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_client_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayClientData = Config.HolidayClientData or {}

LocalizedConfigRequire("config.auto_config.holiday_client_data@data_constant")
LocalizedConfigRequire("config.auto_config.holiday_client_data@data_info")

-- -------------------info_start-------------------
Config.HolidayClientData.data_info_fun = function(key)
	local data=Config.HolidayClientData.data_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayClientData.data_info['..key..'])not found') return
	end
	return data
end
-- -------------------info_end---------------------


-- -------------------constant_start-------------------
Config.HolidayClientData.data_constant_fun = function(key)
	local data=Config.HolidayClientData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayClientData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------
