----------------------------------------------------
-- 此文件由数据工具生成
-- 角色配置数据--role_data.xml
--------------------------------------

Config = Config or {} 
Config.RoleData = Config.RoleData or {}

LocalizedConfigRequire("config.auto_config.role_data@data_city_id_to_province_id")
LocalizedConfigRequire("config.auto_config.role_data@data_city_list")
LocalizedConfigRequire("config.auto_config.role_data@data_province_list")
LocalizedConfigRequire("config.auto_config.role_data@data_role_attr")
LocalizedConfigRequire("config.auto_config.role_data@data_role_const")

if CHARGE_CONFIG_TYPE and CHARGE_CONFIG_TYPE == "zh" then
LocalizedConfigRequire("config.auto_config.role_data_zh@data_city_id_to_province_id")
Config.RoleData.data_city_id_to_province_id_key_depth = Config.RoleDataZh.data_city_id_to_province_id_key_depth
Config.RoleData.data_city_id_to_province_id_length = Config.RoleDataZh.data_city_id_to_province_id_length
Config.RoleData.data_city_id_to_province_id_cache = Config.RoleDataZh.data_city_id_to_province_id_cache
Config.RoleData.data_city_id_to_province_id = Config.RoleDataZh.data_city_id_to_province_id
Config.RoleData.data_city_id_to_province_id_table = Config.RoleDataZh.data_city_id_to_province_id_table

LocalizedConfigRequire("config.auto_config.role_data_zh@data_city_list")
Config.RoleData.data_city_list_key_depth = Config.RoleDataZh.data_city_list_key_depth
Config.RoleData.data_city_list_length = Config.RoleDataZh.data_city_list_length
Config.RoleData.data_city_list = Config.RoleDataZh.data_city_list

LocalizedConfigRequire("config.auto_config.role_data_zh@data_province_list")
Config.RoleData.data_province_list_key_depth = Config.RoleDataZh.data_province_list_key_depth
Config.RoleData.data_province_list_length = Config.RoleDataZh.data_province_list_length
Config.RoleData.data_province_list = Config.RoleDataZh.data_province_list
end
-- -------------------role_const_start-------------------
Config.RoleData.data_role_const_fun = function(key)
	local data=Config.RoleData.data_role_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoleData.data_role_const['..key..'])not found') return
	end
	return data
end
-- -------------------role_const_end---------------------


-- -------------------role_attr_start-------------------
Config.RoleData.data_role_attr_fun = function(key)
	local data=Config.RoleData.data_role_attr[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoleData.data_role_attr['..key..'])not found') return
	end
	return data
end
-- -------------------role_attr_end---------------------


-- -------------------role_career_start-------------------
Config.RoleData.data_role_career_length = 0
Config.RoleData.data_role_career = {

}
Config.RoleData.data_role_career_fun = function(key)
	local data=Config.RoleData.data_role_career[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoleData.data_role_career['..key..'])not found') return
	end
	return data
end
-- -------------------role_career_end---------------------


-- -------------------province_list_start-------------------
-- -------------------province_list_end---------------------


-- -------------------city_list_start-------------------
-- -------------------city_list_end---------------------


-- -------------------city_id_to_province_id_start-------------------
-- -------------------city_id_to_province_id_end---------------------
