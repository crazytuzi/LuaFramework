----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--subscriber_data.xml
--------------------------------------

Config = Config or {} 
Config.SubscriberData = Config.SubscriberData or {}

LocalizedConfigRequire("config.auto_config.subscriber_data@data_constant")
LocalizedConfigRequire("config.auto_config.subscriber_data@data_id_info")
LocalizedConfigRequire("config.auto_config.subscriber_data@data_type_info")

-- -------------------constant_start-------------------
Config.SubscriberData.data_constant_fun = function(key)
	local data=Config.SubscriberData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SubscriberData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------id_info_start-------------------
-- -------------------id_info_end---------------------


-- -------------------type_info_start-------------------
-- -------------------type_info_end---------------------
