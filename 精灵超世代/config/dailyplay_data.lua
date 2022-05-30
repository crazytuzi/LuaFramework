----------------------------------------------------
-- 此文件由数据工具生成
-- 活动配置--dailyplay_data.xml
--------------------------------------

Config = Config or {} 
Config.DailyplayData = Config.DailyplayData or {}

LocalizedConfigRequire("config.auto_config.dailyplay_data@data_exerciseactivity")
LocalizedConfigRequire("config.auto_config.dailyplay_data@data_limitactivity")

-- -------------------limitactivity_start-------------------
Config.DailyplayData.data_limitactivity_fun = function(key)
	local data=Config.DailyplayData.data_limitactivity[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DailyplayData.data_limitactivity['..key..'])not found') return
	end
	return data
end
-- -------------------limitactivity_end---------------------


-- -------------------exerciseactivity_start-------------------
Config.DailyplayData.data_exerciseactivity_fun = function(key)
	local data=Config.DailyplayData.data_exerciseactivity[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DailyplayData.data_exerciseactivity['..key..'])not found') return
	end
	return data
end
-- -------------------exerciseactivity_end---------------------
