----------------------------------------------------
-- 此文件由数据工具生成
-- 精英赛配置数据--arena_elite_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaEliteData = Config.ArenaEliteData or {}

LocalizedConfigRequire("config.auto_config.arena_elite_data@data_elite_buy")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_elite_const")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_elite_last_level")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_elite_level")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_elite_rank_reward")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_explain")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_explain2")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_face")
LocalizedConfigRequire("config.auto_config.arena_elite_data@data_zone")

-- -------------------elite_const_start-------------------
Config.ArenaEliteData.data_elite_const_fun = function(key)
	local data=Config.ArenaEliteData.data_elite_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_elite_const['..key..'])not found') return
	end
	return data
end
-- -------------------elite_const_end---------------------


-- -------------------elite_level_start-------------------
Config.ArenaEliteData.data_elite_level_fun = function(key)
	local data=Config.ArenaEliteData.data_elite_level[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_elite_level['..key..'])not found') return
	end
	return data
end
-- -------------------elite_level_end---------------------


-- -------------------elite_last_level_start-------------------
Config.ArenaEliteData.data_elite_last_level_fun = function(key)
	local data=Config.ArenaEliteData.data_elite_last_level[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_elite_last_level['..key..'])not found') return
	end
	return data
end
-- -------------------elite_last_level_end---------------------


-- -------------------elite_rank_reward_start-------------------
Config.ArenaEliteData.data_elite_rank_reward_fun = function(key)
	local data=Config.ArenaEliteData.data_elite_rank_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_elite_rank_reward['..key..'])not found') return
	end
	return data
end
-- -------------------elite_rank_reward_end---------------------


-- -------------------elite_buy_start-------------------
Config.ArenaEliteData.data_elite_buy_fun = function(key)
	local data=Config.ArenaEliteData.data_elite_buy[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_elite_buy['..key..'])not found') return
	end
	return data
end
-- -------------------elite_buy_end---------------------


-- -------------------explain_start-------------------
Config.ArenaEliteData.data_explain_fun = function(key)
	local data=Config.ArenaEliteData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------explain2_start-------------------
Config.ArenaEliteData.data_explain2_fun = function(key)
	local data=Config.ArenaEliteData.data_explain2[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_explain2['..key..'])not found') return
	end
	return data
end
-- -------------------explain2_end---------------------


-- -------------------face_start-------------------
Config.ArenaEliteData.data_face_fun = function(key)
	local data=Config.ArenaEliteData.data_face[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_face['..key..'])not found') return
	end
	return data
end
-- -------------------face_end---------------------


-- -------------------zone_start-------------------
Config.ArenaEliteData.data_zone_fun = function(key)
	local data=Config.ArenaEliteData.data_zone[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaEliteData.data_zone['..key..'])not found') return
	end
	return data
end
-- -------------------zone_end---------------------
