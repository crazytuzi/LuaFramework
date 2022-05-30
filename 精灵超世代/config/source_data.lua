----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--source_data.xml
--------------------------------------

Config = Config or {} 
Config.SourceData = Config.SourceData or {}

LocalizedConfigRequire("config.auto_config.source_data@data_source_data")

-- -------------------source_data_start-------------------
Config.SourceData.data_source_data_fun = function(key)
	local data=Config.SourceData.data_source_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SourceData.data_source_data['..key..'])not found') return
	end
	return data
end
-- -------------------source_data_end---------------------
