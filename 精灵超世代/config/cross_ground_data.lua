----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--cross_ground_data.xml
--------------------------------------

Config = Config or {} 
Config.CrossGroundData = Config.CrossGroundData or {}

LocalizedConfigRequire("config.auto_config.cross_ground_data@data_adventure_activity")
LocalizedConfigRequire("config.auto_config.cross_ground_data@data_base")

-- -------------------base_start-------------------
-- -------------------base_end---------------------


-- -------------------adventure_activity_start-------------------
Config.CrossGroundData.data_adventure_activity_fun = function(key)
	local data=Config.CrossGroundData.data_adventure_activity[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CrossGroundData.data_adventure_activity['..key..'])not found') return
	end
	return data
end
-- -------------------adventure_activity_end---------------------
