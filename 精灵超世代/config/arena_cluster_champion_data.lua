----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--arena_cluster_champion_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaClusterChampionData = Config.ArenaClusterChampionData or {}

LocalizedConfigRequire("config.auto_config.arena_cluster_champion_data@data_const")
LocalizedConfigRequire("config.auto_config.arena_cluster_champion_data@data_awards")
LocalizedConfigRequire("config.auto_config.arena_cluster_champion_data@data_explain")

-- -------------------const_start-------------------
Config.ArenaClusterChampionData.data_const_fun = function(key)
	local data=Config.ArenaClusterChampionData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaClusterChampionData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------

-- -------------------awards_start-------------------
-- -------------------awards_end---------------------

-- -------------------explain_start-------------------
Config.ArenaClusterChampionData.data_explain_fun = function(key)
	local data=Config.ArenaClusterChampionData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaClusterChampionData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
