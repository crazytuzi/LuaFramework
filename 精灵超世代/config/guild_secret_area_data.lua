----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--guild_secret_area_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildSecretAreaData = Config.GuildSecretAreaData or {}

LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_boss_info")
LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_box_reward")
LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_chapter_reward")
LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_const")
LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_cost_info")
LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_explain")
LocalizedConfigRequire("config.auto_config.guild_secret_area_data@data_rank_reward")

-- -------------------const_start-------------------
Config.GuildSecretAreaData.data_const_fun = function(key)
	local data=Config.GuildSecretAreaData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildSecretAreaData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------boss_info_start-------------------
-- -------------------boss_info_end---------------------


-- -------------------cost_info_start-------------------
Config.GuildSecretAreaData.data_cost_info_fun = function(key)
	local data=Config.GuildSecretAreaData.data_cost_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildSecretAreaData.data_cost_info['..key..'])not found') return
	end
	return data
end
-- -------------------cost_info_end---------------------


-- -------------------box_reward_start-------------------
-- -------------------box_reward_end---------------------


-- -------------------chapter_reward_start-------------------
-- -------------------chapter_reward_end---------------------


-- -------------------rank_reward_start-------------------
-- -------------------rank_reward_end---------------------


-- -------------------explain_start-------------------
Config.GuildSecretAreaData.data_explain_fun = function(key)
	local data=Config.GuildSecretAreaData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildSecretAreaData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
