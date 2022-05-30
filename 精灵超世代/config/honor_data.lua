----------------------------------------------------
-- 此文件由数据工具生成
-- 称号数据--honor_data.xml
--------------------------------------

Config = Config or {} 
Config.HonorData = Config.HonorData or {}

LocalizedConfigRequire("config.auto_config.honor_data@data_title")

-- -------------------title_start-------------------
Config.HonorData.data_title_fun = function(key)
	local data=Config.HonorData.data_title[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HonorData.data_title['..key..'])not found') return
	end
	return data
end
-- -------------------title_end---------------------
