----------------------------------------------------
-- 此文件由数据工具生成
-- 公会配置数据--guild_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildData = Config.GuildData or {}

LocalizedConfigRequire("config.auto_config.guild_data@data_const")
LocalizedConfigRequire("config.auto_config.guild_data@data_donate")
LocalizedConfigRequire("config.auto_config.guild_data@data_donate_box")
LocalizedConfigRequire("config.auto_config.guild_data@data_guild_lev")
LocalizedConfigRequire("config.auto_config.guild_data@data_guild_red_bag")
LocalizedConfigRequire("config.auto_config.guild_data@data_guild_scene_icon")
LocalizedConfigRequire("config.auto_config.guild_data@data_position")
LocalizedConfigRequire("config.auto_config.guild_data@data_post")
LocalizedConfigRequire("config.auto_config.guild_data@data_sign")

-- -------------------position_start-------------------
Config.GuildData.data_position_fun = function(key)
	local data=Config.GuildData.data_position[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_position['..key..'])not found') return
	end
	return data
end
-- -------------------position_end---------------------


-- -------------------donate_start-------------------
Config.GuildData.data_donate_fun = function(key)
	local data=Config.GuildData.data_donate[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_donate['..key..'])not found') return
	end
	return data
end
-- -------------------donate_end---------------------


-- -------------------post_start-------------------
Config.GuildData.data_post_fun = function(key)
	local data=Config.GuildData.data_post[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_post['..key..'])not found') return
	end
	return data
end
-- -------------------post_end---------------------


-- -------------------guild_lev_start-------------------
Config.GuildData.data_guild_lev_fun = function(key)
	local data=Config.GuildData.data_guild_lev[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_guild_lev['..key..'])not found') return
	end
	return data
end
-- -------------------guild_lev_end---------------------


-- -------------------sign_start-------------------
-- -------------------sign_end---------------------


-- -------------------const_start-------------------
Config.GuildData.data_const_fun = function(key)
	local data=Config.GuildData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------donate_box_start-------------------
Config.GuildData.data_donate_box_fun = function(key)
	local data=Config.GuildData.data_donate_box[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_donate_box['..key..'])not found') return
	end
	return data
end
-- -------------------donate_box_end---------------------


-- -------------------guild_red_bag_start-------------------
Config.GuildData.data_guild_red_bag_fun = function(key)
	local data=Config.GuildData.data_guild_red_bag[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_guild_red_bag['..key..'])not found') return
	end
	return data
end
-- -------------------guild_red_bag_end---------------------


-- -------------------guild_scene_icon_start-------------------
Config.GuildData.data_guild_scene_icon_fun = function(key)
	local data=Config.GuildData.data_guild_scene_icon[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildData.data_guild_scene_icon['..key..'])not found') return
	end
	return data
end
-- -------------------guild_scene_icon_end---------------------
