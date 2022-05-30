----------------------------------------------------
-- 此文件由数据工具生成
-- 无尽试炼--privilege_data.xml
--------------------------------------

Config = Config or {} 
Config.PrivilegeData = Config.PrivilegeData or {}

LocalizedConfigRequire("config.auto_config.privilege_data@data_fast_combat_cost")
LocalizedConfigRequire("config.auto_config.privilege_data@data_privilege_award")
LocalizedConfigRequire("config.auto_config.privilege_data@data_privilege_data")

-- -------------------const_start-------------------
Config.PrivilegeData.data_const_length = 0
Config.PrivilegeData.data_const = {

}
Config.PrivilegeData.data_const_fun = function(key)
	local data=Config.PrivilegeData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PrivilegeData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------fast_combat_cost_start-------------------
Config.PrivilegeData.data_fast_combat_cost_fun = function(key)
	local data=Config.PrivilegeData.data_fast_combat_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PrivilegeData.data_fast_combat_cost['..key..'])not found') return
	end
	return data
end
-- -------------------fast_combat_cost_end---------------------


-- -------------------privilege_data_start-------------------
Config.PrivilegeData.data_privilege_data_fun = function(key)
	local data=Config.PrivilegeData.data_privilege_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PrivilegeData.data_privilege_data['..key..'])not found') return
	end
	return data
end
-- -------------------privilege_data_end---------------------


-- -------------------privilege_award_start-------------------
-- -------------------privilege_award_end---------------------
