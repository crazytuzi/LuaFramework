----------------------------------------------------
-- 此文件由数据工具生成
-- 竞技场--arena_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaData = Config.ArenaData or {}

LocalizedConfigRequire("config.auto_config.arena_data@data_activity")
LocalizedConfigRequire("config.auto_config.arena_data@data_awards")
LocalizedConfigRequire("config.auto_config.arena_data@data_base_awards")
LocalizedConfigRequire("config.auto_config.arena_data@data_const")
LocalizedConfigRequire("config.auto_config.arena_data@data_cup")
LocalizedConfigRequire("config.auto_config.arena_data@data_explain")
LocalizedConfigRequire("config.auto_config.arena_data@data_season_num_reward")

-- -------------------base_awards_start-------------------

Config.ArenaData.data_base_awards_fun = function(key)
	local data=Config.ArenaData.data_base_awards[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaData.data_base_awards['..key..'])not found') return
	end
	return data
end
-- -------------------base_awards_end---------------------


-- -------------------cup_start-------------------
-- -------------------cup_end---------------------


-- -------------------continue_start-------------------
Config.ArenaData.data_continue_length = 0
Config.ArenaData.data_continue = {

}
Config.ArenaData.data_continue_fun = function(key)
	local data=Config.ArenaData.data_continue[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaData.data_continue['..key..'])not found') return
	end
	return data
end
-- -------------------continue_end---------------------


-- -------------------continue_list_start-------------------
Config.ArenaData.data_continue_list_length = 0
Config.ArenaData.data_continue_list = {

}
-- -------------------continue_list_end---------------------


-- -------------------activity_start-------------------
-- -------------------activity_end---------------------


-- -------------------season_num_reward_start-------------------
-- -------------------season_num_reward_end---------------------


-- -------------------awards_start-------------------
-- -------------------awards_end---------------------


-- -------------------explain_start-------------------
Config.ArenaData.data_explain_fun = function(key)
	local data=Config.ArenaData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------const_start-------------------
Config.ArenaData.data_const_fun = function(key)
	local data=Config.ArenaData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------
