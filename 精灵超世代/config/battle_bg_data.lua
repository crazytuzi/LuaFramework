----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--battle_bg_data.xml
--------------------------------------

Config = Config or {} 
Config.BattleBgData = Config.BattleBgData or {}

LocalizedConfigRequire("config.auto_config.battle_bg_data@data_info2")
LocalizedConfigRequire("config.auto_config.battle_bg_data@data_back_limit")
LocalizedConfigRequire("config.auto_config.battle_bg_data@data_fight_name")
LocalizedConfigRequire("config.auto_config.battle_bg_data@data_info")

-- -------------------info_start-------------------
-- -------------------info_end---------------------


-- -------------------info2_start-------------------
-- -------------------info2_end---------------------


-- -------------------fight_name_start-------------------
Config.BattleBgData.data_fight_name_fun = function(key)
	local data=Config.BattleBgData.data_fight_name[key]
	if DATA_DEBUG and data == nil then
		print('(Config.BattleBgData.data_fight_name['..key..'])not found') return
	end
	return data
end
-- -------------------fight_name_end---------------------


-- -------------------back_limit_start-------------------
-- -------------------back_limit_end---------------------
