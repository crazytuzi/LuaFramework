----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--world_lev_data.xml
--------------------------------------

Config = Config or {} 
Config.WorldLevData = Config.WorldLevData or {}

LocalizedConfigRequire("config.auto_config.world_lev_data@data_const")

-- -------------------const_start-------------------
Config.WorldLevData.data_const_fun = function(key)
	local data=Config.WorldLevData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.WorldLevData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------
