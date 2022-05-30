----------------------------------------------------
-- 此文件由数据工具生成
-- 战斗类型配置数据--combat_type_data.xml
--------------------------------------

Config = Config or {} 
Config.CombatTypeData = Config.CombatTypeData or {}

LocalizedConfigRequire("config.auto_config.combat_type_data@data_const")
LocalizedConfigRequire("config.auto_config.combat_type_data@data_fight_list")
LocalizedConfigRequire("config.auto_config.combat_type_data@data_blance_fight_mode")
LocalizedConfigRequire("config.auto_config.combat_type_data@data_combat_speed")

-- -------------------fight_list_start-------------------
Config.CombatTypeData.data_fight_list_fun = function(key)
	local data=Config.CombatTypeData.data_fight_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CombatTypeData.data_fight_list['..key..'])not found') return
	end
	return data
end
-- -------------------fight_list_end---------------------


-- -------------------blance_fight_mode_start-------------------
-- -------------------blance_fight_mode_end---------------------


-- -------------------const_start-------------------
Config.CombatTypeData.data_const_fun = function(key)
	local data=Config.CombatTypeData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CombatTypeData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------combat_speed_start-------------------
Config.CombatTypeData.data_combat_speed_fun = function(key)
	local data=Config.CombatTypeData.data_combat_speed[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CombatTypeData.data_combat_speed['..key..'])not found') return
	end
	return data
end
-- -------------------combat_speed_end---------------------
