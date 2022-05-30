----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_valentine_boss_data.xml
--------------------------------------

LocalizedConfigRequire("config.auto_config.holiday_valentine_boss_data@data_award_list")
LocalizedConfigRequire("config.auto_config.holiday_valentine_boss_data@data_boss_list")
LocalizedConfigRequire("config.auto_config.holiday_valentine_boss_data@data_constant")

Config = Config or {} 
Config.HolidayValentineBossData = Config.HolidayValentineBossData or {}

-- -------------------constant_start-------------------

Config.HolidayValentineBossData.data_constant_fun = function(key)
	local data=Config.HolidayValentineBossData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayValentineBossData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------boss_list_start-------------------

-- -------------------boss_list_end---------------------


-- -------------------award_list_start-------------------

-- -------------------award_list_end---------------------
