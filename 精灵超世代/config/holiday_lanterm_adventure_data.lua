----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_lanterm_adventure_data.xml
--------------------------------------

LocalizedConfigRequire("config.auto_config.holiday_lanterm_adventure_data@data_lanterm_adventure")
LocalizedConfigRequire("config.auto_config.holiday_lanterm_adventure_data@data_lanterm_adventure_task_lis")

Config = Config or {} 
Config.HolidayLantermAdventureData = Config.HolidayLantermAdventureData or {}

-- -------------------lanterm_adventure_start-------------------

Config.HolidayLantermAdventureData.data_lanterm_adventure_fun = function(key)
	local data=Config.HolidayLantermAdventureData.data_lanterm_adventure[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayLantermAdventureData.data_lanterm_adventure['..key..'])not found') return
	end
	return data
end
-- -------------------lanterm_adventure_end---------------------


-- -------------------lanterm_adventure_task_list_start-------------------
-- -------------------lanterm_adventure_task_list_end---------------------
