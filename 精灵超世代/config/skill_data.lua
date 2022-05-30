----------------------------------------------------
-- 此文件由数据工具生成
-- skill配置数据--skill_other_part_data.xml
--------------------------------------

Config = Config or {} 
Config.SkillData = Config.SkillData or {}

LocalizedConfigRequire("config.auto_config.skill_data@data_get_buff")
LocalizedConfigRequire("config.auto_config.skill_data@data_get_effect_data")
LocalizedConfigRequire("config.auto_config.skill_data@data_get_model_data")
LocalizedConfigRequire("config.auto_config.skill_data@data_get_act_data")
LocalizedConfigRequire("config.auto_config.skill_data@data_get_shake_data")

-- -------------------unit_start-------------------
Config.SkillData.data_get_effect = function(key)
	return Config.SkillData1.data_get_effect(key) or Config.SkillData2.data_get_effect(key) or Config.SkillData3.data_get_effect(key) or Config.SkillData4.data_get_effect(key) or Config.SkillData5.data_get_effect(key) or Config.SkillData6.data_get_effect(key)
end

Config.SkillData.data_get_skill = function(key)
	return Config.SkillData1.data_get_skill(key) or Config.SkillData2.data_get_skill(key) or Config.SkillData3.data_get_skill(key) or Config.SkillData4.data_get_skill(key) or Config.SkillData5.data_get_skill(key) or Config.SkillData6.data_get_skill(key)
end

Config.SkillData.data_get_skill_group = function(key)
	return Config.SkillData1.data_get_skill_group(key) or Config.SkillData2.data_get_skill_group(key) or Config.SkillData3.data_get_skill_group(key) or Config.SkillData4.data_get_skill_group(key) or Config.SkillData5.data_get_skill_group(key) or Config.SkillData6.data_get_skill_group(key)
end

-- -------------------get_act_data_start-------------------
Config.SkillData.data_get_act_data_fun = function(key)
	local data=Config.SkillData.data_get_act_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkillData.data_get_act_data['..key..'])not found') return
	end
	return data
end
-- -------------------get_act_data_end---------------------

-- -------------------get_effect_data_start-------------------
Config.SkillData.data_get_effect_data_fun = function(key)
	local data=Config.SkillData.data_get_effect_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkillData.data_get_effect_data['..key..'])not found') return
	end
	return data
end
-- -------------------get_effect_data_end---------------------

-- -------------------get_buff_start-------------------
Config.SkillData.data_get_buff_fun = function(key)
	local data=Config.SkillData.data_get_buff[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkillData.data_get_buff['..key..'])not found') return
	end
	return data
end
-- -------------------get_buff_end---------------------

-- -------------------get_shake_data_start-------------------
Config.SkillData.data_get_shake_data_fun = function(key)
	local data=Config.SkillData.data_get_shake_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkillData.data_get_shake_data['..key..'])not found') return
	end
	return data
end
-- -------------------get_shake_data_end---------------------

-- -------------------get_model_data_start-------------------
Config.SkillData.data_get_model_data_fun = function(key)
	local data=Config.SkillData.data_get_model_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkillData.data_get_model_data['..key..'])not found') return
	end
	return data
end
-- -------------------get_model_data_end---------------------


