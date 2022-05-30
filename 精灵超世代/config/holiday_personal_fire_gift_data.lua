----------------------------------------------------
-- 此文件由数据工具生成
-- 触发礼包配置数据--holiday_personal_fire_gift_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayPersonalFireGiftData = Config.HolidayPersonalFireGiftData or {}
LocalizedConfigRequire("config.auto_config.holiday_personal_fire_gift_data@data_gift_info.lua")
-- -------------------gift_info_start-------------------

Config.HolidayPersonalFireGiftData.data_gift_info_fun = function(key)
	local data=Config.HolidayPersonalFireGiftData.data_gift_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPersonalFireGiftData.data_gift_info['..key..'])not found') return
	end
	return data
end
-- -------------------gift_info_end---------------------
