----------------------------------------------------
-- 此文件由数据工具生成
-- 联盟战配置数据--guild_war_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildWarData = Config.GuildWarData or {}

LocalizedConfigRequire("config.auto_config.guild_war_data@data_award")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_box_award")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_buff")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_const")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_explain")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_guard_power")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_marketplace_reward")
LocalizedConfigRequire("config.auto_config.guild_war_data@data_position")

-- -------------------const_start-------------------
Config.GuildWarData.data_const_fun = function(key)
	local data=Config.GuildWarData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------award_start-------------------
Config.GuildWarData.data_award_fun = function(key)
	local data=Config.GuildWarData.data_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_award['..key..'])not found') return
	end
	return data
end
-- -------------------award_end---------------------


-- -------------------position_start-------------------
Config.GuildWarData.data_position_fun = function(key)
	local data=Config.GuildWarData.data_position[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_position['..key..'])not found') return
	end
	return data
end
-- -------------------position_end---------------------


-- -------------------buff_start-------------------
Config.GuildWarData.data_buff_fun = function(key)
	local data=Config.GuildWarData.data_buff[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_buff['..key..'])not found') return
	end
	return data
end
-- -------------------buff_end---------------------


-- -------------------explain_start-------------------
Config.GuildWarData.data_explain_fun = function(key)
	local data=Config.GuildWarData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------guard_power_start-------------------
Config.GuildWarData.data_guard_power_fun = function(key)
	local data=Config.GuildWarData.data_guard_power[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_guard_power['..key..'])not found') return
	end
	return data
end
-- -------------------guard_power_end---------------------


-- -------------------box_award_start-------------------
Config.GuildWarData.data_box_award_fun = function(key)
	local data=Config.GuildWarData.data_box_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildWarData.data_box_award['..key..'])not found') return
	end
	return data
end
-- -------------------box_award_end---------------------


-- -------------------marketplace_reward_start-------------------
-- -------------------marketplace_reward_end---------------------
