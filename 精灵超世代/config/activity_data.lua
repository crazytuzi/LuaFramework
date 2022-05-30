----------------------------------------------------
-- 此文件由数据工具生成
-- 活跃度--activity_data.xml
--------------------------------------

Config = Config or {} 
Config.ActivityData = Config.ActivityData or {}

LocalizedConfigRequire("config.auto_config.activity_data@data_get")
LocalizedConfigRequire("config.auto_config.activity_data@data_sign_info")

-- -------------------get_start-------------------
Config.ActivityData.data_get_fun = function(key)
	local data=Config.ActivityData.data_get[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ActivityData.data_get['..key..'])not found') return
	end
	return data
end
-- -------------------get_end---------------------


-- -------------------sign_info_start-------------------
Config.ActivityData.data_sign_info_fun = function(key)
	local data=Config.ActivityData.data_sign_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ActivityData.data_sign_info['..key..'])not found') return
	end
	return data
end
-- -------------------sign_info_end---------------------
