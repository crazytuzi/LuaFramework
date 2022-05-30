----------------------------------------------------
-- 此文件由数据工具生成
-- 活动指定英雄置换--holiday_convert_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayConvertData = Config.HolidayConvertData or {}

LocalizedConfigRequire("config.auto_config.holiday_convert_data@data_hero_list")
LocalizedConfigRequire("config.auto_config.holiday_convert_data@data_target_hero_list")
LocalizedConfigRequire("config.auto_config.holiday_convert_data@data_const")
LocalizedConfigRequire("config.auto_config.holiday_convert_data@data_convert_info")

-- -------------------const_start-------------------
Config.HolidayConvertData.data_const_fun = function(key)
	local data=Config.HolidayConvertData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayConvertData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------convert_info_start-------------------
-- -------------------convert_info_end---------------------


-- -------------------hero_list_start-------------------
-- -------------------hero_list_end---------------------


-- -------------------target_hero_list_start-------------------
-- -------------------target_hero_list_end---------------------
