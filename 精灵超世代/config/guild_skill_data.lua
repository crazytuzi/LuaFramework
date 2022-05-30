----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--guild_skill_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildSkillData = Config.GuildSkillData or {}

LocalizedConfigRequire("config.auto_config.guild_skill_data@data_career_list")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_const")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_group")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_group_sep")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_info")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_info_group")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_pvp_attr_info")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_pvp_attr_max_lev")
LocalizedConfigRequire("config.auto_config.guild_skill_data@data_pvp_skill_info")


-- -------------------const_start-------------------
Config.GuildSkillData.data_const_fun = function(key)
	local data=Config.GuildSkillData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildSkillData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------group_start-------------------
Config.GuildSkillData.data_group_fun = function(key)
	local data=Config.GuildSkillData.data_group[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildSkillData.data_group['..key..'])not found') return
	end
	return data
end
-- -------------------group_end---------------------


-- -------------------group_sep_start-------------------
Config.GuildSkillData.data_group_sep_fun = function(key)
	local data=Config.GuildSkillData.data_group_sep[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildSkillData.data_group_sep['..key..'])not found') return
	end
	return data
end
-- -------------------group_sep_end---------------------


-- -------------------career_list_start-------------------
-- -------------------career_list_end---------------------


-- -------------------info_start-------------------
-- -------------------info_end---------------------


-- -------------------info_group_start-------------------
-- -------------------info_group_end---------------------


-- -------------------pvp_attr_info_start-------------------
-- -------------------pvp_attr_info_end---------------------


-- -------------------pvp_attr_max_lev_start-------------------
-- -------------------pvp_attr_max_lev_end---------------------


-- -------------------pvp_skill_info_start-------------------
-- -------------------pvp_skill_info_end---------------------
