----------------------------------------------------
-- 此文件由数据工具生成
-- 成就数据--feat_data.xml
--------------------------------------

Config = Config or {} 
Config.FeatData = Config.FeatData or {}

LocalizedConfigRequire("config.auto_config.feat_data@data_get")

-- -------------------get_start-------------------
Config.FeatData.data_get_fun = function(key)
	local data=Config.FeatData.data_get[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FeatData.data_get['..key..'])not found') return
	end
	return data
end
-- -------------------get_end---------------------
