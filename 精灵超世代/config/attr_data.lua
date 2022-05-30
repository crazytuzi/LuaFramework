----------------------------------------------------
-- 此文件由数据工具生成
-- attr配置数据--attr_data.xml
--------------------------------------

Config = Config or {} 
Config.AttrData = Config.AttrData or {}

LocalizedConfigRequire("config.auto_config.attr_data@data_id_to_key")
LocalizedConfigRequire("config.auto_config.attr_data@data_id_to_name")
LocalizedConfigRequire("config.auto_config.attr_data@data_is_show")
LocalizedConfigRequire("config.auto_config.attr_data@data_key_to_id")
LocalizedConfigRequire("config.auto_config.attr_data@data_key_to_name")
LocalizedConfigRequire("config.auto_config.attr_data@data_partner_power")
LocalizedConfigRequire("config.auto_config.attr_data@data_power")
LocalizedConfigRequire("config.auto_config.attr_data@data_type")


-- -------------------id_to_key_start-------------------
Config.AttrData.data_id_to_key_fun = function(key)
	local data=Config.AttrData.data_id_to_key[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_id_to_key['..key..'])not found') return
	end
	return data
end
-- -------------------id_to_key_end---------------------


-- -------------------key_to_id_start-------------------
Config.AttrData.data_key_to_id_fun = function(key)
	local data=Config.AttrData.data_key_to_id[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_key_to_id['..key..'])not found') return
	end
	return data
end
-- -------------------key_to_id_end---------------------


-- -------------------id_to_name_start-------------------
Config.AttrData.data_id_to_name_fun = function(key)
	local data=Config.AttrData.data_id_to_name[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_id_to_name['..key..'])not found') return
	end
	return data
end
-- -------------------id_to_name_end---------------------


-- -------------------key_to_name_start-------------------
Config.AttrData.data_key_to_name_fun = function(key)
	local data=Config.AttrData.data_key_to_name[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_key_to_name['..key..'])not found') return
	end
	return data
end
-- -------------------key_to_name_end---------------------


-- -------------------power_start-------------------
Config.AttrData.data_power_fun = function(key)
	local data=Config.AttrData.data_power[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_power['..key..'])not found') return
	end
	return data
end
-- -------------------power_end---------------------


-- -------------------type_start-------------------
Config.AttrData.data_type_fun = function(key)
	local data=Config.AttrData.data_type[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_type['..key..'])not found') return
	end
	return data
end
-- -------------------type_end---------------------


-- -------------------partner_power_start-------------------
Config.AttrData.data_partner_power_fun = function(key)
	local data=Config.AttrData.data_partner_power[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_partner_power['..key..'])not found') return
	end
	return data
end
-- -------------------partner_power_end---------------------


-- -------------------is_show_start-------------------
Config.AttrData.data_is_show_fun = function(key)
	local data=Config.AttrData.data_is_show[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AttrData.data_is_show['..key..'])not found') return
	end
	return data
end
-- -------------------is_show_end---------------------
