----------------------------------------------------
-- 此文件由数据工具生成
-- 战斗加成配置数据--combat_halo_data.xml
--------------------------------------

Config = Config or {} 
Config.CombatHaloData = Config.CombatHaloData or {}

LocalizedConfigRequire("config.auto_config.combat_halo_data@data_halo_icon")
LocalizedConfigRequire("config.auto_config.combat_halo_data@data_halo_show")
LocalizedConfigRequire("config.auto_config.combat_halo_data@data_halo")

-- -------------------const_start-------------------
Config.CombatHaloData.data_const_length = 0
Config.CombatHaloData.data_const = {

}
Config.CombatHaloData.data_const_fun = function(key)
	local data=Config.CombatHaloData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CombatHaloData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------halo_start-------------------
Config.CombatHaloData.data_halo_fun = function(key)
	local data=Config.CombatHaloData.data_halo[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CombatHaloData.data_halo['..key..'])not found') return
	end
	return data
end
-- -------------------halo_end---------------------


-- -------------------halo_icon_start-------------------
Config.CombatHaloData.data_halo_icon_fun = function(key)
	local data=Config.CombatHaloData.data_halo_icon[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CombatHaloData.data_halo_icon['..key..'])not found') return
	end
	return data
end
-- -------------------halo_icon_end---------------------


-- -------------------halo_show_start-------------------
-- -------------------halo_show_end---------------------
