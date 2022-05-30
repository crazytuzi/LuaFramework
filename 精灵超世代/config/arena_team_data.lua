----------------------------------------------------
-- 此文件由数据工具生成
-- 组队竞技场--arena_team_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaTeamData = Config.ArenaTeamData or {}

LocalizedConfigRequire("config.auto_config.arena_team_data@data_challenge_count_reward_inf")
LocalizedConfigRequire("config.auto_config.arena_team_data@data_const")
LocalizedConfigRequire("config.auto_config.arena_team_data@data_explain")
LocalizedConfigRequire("config.auto_config.arena_team_data@data_level_info")
LocalizedConfigRequire("config.auto_config.arena_team_data@data_power_info")
LocalizedConfigRequire("config.auto_config.arena_team_data@data_rank_reward")


-- -------------------const_start-------------------
Config.ArenaTeamData.data_const_fun = function(key)
	local data=Config.ArenaTeamData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaTeamData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------level_info_start-------------------
-- -------------------level_info_end---------------------


-- -------------------power_info_start-------------------
-- -------------------power_info_end---------------------


-- -------------------challenge_count_reward_info_start-------------------
--子表名字过长，导致xls中被截断
Config.ArenaTeamData.data_challenge_count_reward_info = Config.ArenaTeamData.data_challenge_count_reward_inf
-- -------------------challenge_count_reward_info_end---------------------


-- -------------------rank_reward_start-------------------
Config.ArenaTeamData.data_rank_reward_fun = function(key)
	local data=Config.ArenaTeamData.data_rank_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaTeamData.data_rank_reward['..key..'])not found') return
	end
	return data
end
-- -------------------rank_reward_end---------------------


-- -------------------explain_start-------------------
Config.ArenaTeamData.data_explain_fun = function(key)
	local data=Config.ArenaTeamData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaTeamData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
