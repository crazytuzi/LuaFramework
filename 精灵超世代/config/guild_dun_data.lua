----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--guild_dun_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildDunData = Config.GuildDunData or {}

LocalizedConfigRequire("config.auto_config.guild_dun_data@data_buff_data")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_buy_count")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_chapter_boss")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_chapter_box")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_chapter_reward")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_const")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_guildboss_list")
LocalizedConfigRequire("config.auto_config.guild_dun_data@data_rank_reward")

-- -------------------const_start-------------------
Config.GuildDunData.data_const_fun = function(key)
	local data=Config.GuildDunData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildDunData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------guildboss_list_start-------------------
Config.GuildDunData.data_guildboss_list_fun = function(key)
	local data=Config.GuildDunData.data_guildboss_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildDunData.data_guildboss_list['..key..'])not found') return
	end
	return data
end
-- -------------------guildboss_list_end---------------------


-- -------------------chapter_boss_start-------------------
-- -------------------chapter_boss_end---------------------


-- -------------------chapter_reward_start-------------------
Config.GuildDunData.data_chapter_reward_fun = function(key)
	local data=Config.GuildDunData.data_chapter_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildDunData.data_chapter_reward['..key..'])not found') return
	end
	return data
end
-- -------------------chapter_reward_end---------------------


-- -------------------chapter_box_start-------------------
Config.GuildDunData.data_chapter_box_fun = function(key)
	local data=Config.GuildDunData.data_chapter_box[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildDunData.data_chapter_box['..key..'])not found') return
	end
	return data
end
-- -------------------chapter_box_end---------------------


-- -------------------buy_count_start-------------------
Config.GuildDunData.data_buy_count_fun = function(key)
	local data=Config.GuildDunData.data_buy_count[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildDunData.data_buy_count['..key..'])not found') return
	end
	return data
end
-- -------------------buy_count_end---------------------


-- -------------------rank_reward_start-------------------
-- -------------------rank_reward_end---------------------


-- -------------------buff_data_start-------------------
Config.GuildDunData.data_buff_data_fun = function(key)
	local data=Config.GuildDunData.data_buff_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildDunData.data_buff_data['..key..'])not found') return
	end
	return data
end
-- -------------------buff_data_end---------------------
