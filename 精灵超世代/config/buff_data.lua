----------------------------------------------------
-- 此文件由数据工具生成
-- buff配置数据--buff_data.xml
--------------------------------------

Config = Config or {} 
Config.BuffData = Config.BuffData or {}

LocalizedConfigRequire("config.auto_config.buff_data@data_get_buff_data")

-- -------------------get_buff_data_start-------------------
Config.BuffData.data_get_buff_data_fun = function(key)
	local data=Config.BuffData.data_get_buff_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.BuffData.data_get_buff_data['..key..'])not found') return
	end
	return data
end
-- -------------------get_buff_data_end---------------------
