----------------------------------------------------
-- 此文件由数据工具生成
-- 帮会任务配置数据--guild_quest_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildQuestData = Config.GuildQuestData or {}

LocalizedConfigRequire("config.auto_config.guild_quest_data@data_lev_data")
LocalizedConfigRequire("config.auto_config.guild_quest_data@data_max_lev")
LocalizedConfigRequire("config.auto_config.guild_quest_data@data_task_data")
LocalizedConfigRequire("config.auto_config.guild_quest_data@data_guild_action_data")


-- -------------------guild_action_data_start-------------------
Config.GuildQuestData.data_guild_action_data_fun = function(key)
	local data=Config.GuildQuestData.data_guild_action_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildQuestData.data_guild_action_data['..key..'])not found') return
	end
	return data
end
-- -------------------guild_action_data_end---------------------


-- -------------------lev_data_start-------------------
Config.GuildQuestData.data_lev_data_fun = function(key)
	local data=Config.GuildQuestData.data_lev_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildQuestData.data_lev_data['..key..'])not found') return
	end
	return data
end
-- -------------------lev_data_end---------------------


-- -------------------task_data_start-------------------
Config.GuildQuestData.data_task_data_fun = function(key)
	local data=Config.GuildQuestData.data_task_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildQuestData.data_task_data['..key..'])not found') return
	end
	return data
end
-- -------------------task_data_end---------------------


-- -------------------max_lev_start-------------------
-- -------------------max_lev_end---------------------
