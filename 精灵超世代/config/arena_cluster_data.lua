----------------------------------------------------
-- 此文件由数据工具生成
-- 跨服竞技场--arena_cluster_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaClusterData = Config.ArenaClusterData or {}

LocalizedConfigRequire("config.auto_config.arena_cluster_data@data_const")
LocalizedConfigRequire("config.auto_config.arena_cluster_data@data_daily_award")
LocalizedConfigRequire("config.auto_config.arena_cluster_data@data_rank_award")
LocalizedConfigRequire("config.auto_config.arena_cluster_data@data_explain")

-- -------------------const_start-------------------
Config.ArenaClusterData.data_const_fun = function(key)
	local data=Config.ArenaClusterData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaClusterData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------daily_award_start-------------------
Config.ArenaClusterData.data_daily_award_fun = function(key)
	local data=Config.ArenaClusterData.data_daily_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaClusterData.data_daily_award['..key..'])not found') return
	end
	return data
end
-- -------------------daily_award_end---------------------


-- -------------------rank_award_start-------------------
Config.ArenaClusterData.data_rank_award_fun = function(key)
	local data=Config.ArenaClusterData.data_rank_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaClusterData.data_rank_award['..key..'])not found') return
	end
	return data
end
-- -------------------rank_award_end---------------------


-- -------------------explain_start-------------------
Config.ArenaClusterData.data_explain_fun = function(key)
	local data=Config.ArenaClusterData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaClusterData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
