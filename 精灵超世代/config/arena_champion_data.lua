----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--arena_champion_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaChampionData = Config.ArenaChampionData or {}

LocalizedConfigRequire("config.auto_config.arena_champion_data@data_const")
LocalizedConfigRequire("config.auto_config.arena_champion_data@data_awards")
LocalizedConfigRequire("config.auto_config.arena_champion_data@data_explain")

-- -------------------const_start-------------------
Config.ArenaChampionData.data_const_fun = function(key)
	local data=Config.ArenaChampionData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaChampionData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------awards_start-------------------
-- -------------------awards_end---------------------


-- -------------------explain_start-------------------
Config.ArenaChampionData.data_explain_fun = function(key)
	local data=Config.ArenaChampionData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaChampionData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
