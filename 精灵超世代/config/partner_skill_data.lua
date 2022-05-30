----------------------------------------------------
-- 此文件由数据工具生成
-- 伙伴装备配置数据--partner_skill_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerSkillData = Config.PartnerSkillData or {}

LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_awakening_skill")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_const")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_item")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_learn")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_level")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_map")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_pos")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_back")
LocalizedConfigRequire("config.auto_config.partner_skill_data@data_partner_skill_view")

-- -------------------partner_skill_const_start-------------------
Config.PartnerSkillData.data_partner_skill_const_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_const['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_const_end---------------------


-- -------------------partner_skill_pos_start-------------------
Config.PartnerSkillData.data_partner_skill_pos_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_pos[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_pos['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_pos_end---------------------


-- -------------------partner_skill_learn_start-------------------
Config.PartnerSkillData.data_partner_skill_learn_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_learn[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_learn['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_learn_end---------------------


-- -------------------partner_commend_skill_start-------------------
Config.PartnerSkillData.data_partner_commend_skill_length = 7
Config.PartnerSkillData.data_partner_commend_skill = {
  [20507] = {700291,750000,700281,700361,700201,700211,700171,700221,750100,700071},
  [40507] = {700291,700371,700281,700361,700201,700211,700171,700221,750100,700071},
  [40509] = {700291,700231,700281,700361,700201,700211,700171,700221,750100,700071},
  [40502] = {750000,700001,700321,700311,700151,700121,700111,700101,700071,700141},
  [40503] = {750000,700001,700311,700401,700131,700121,700111,700101,700071,700051},
  [30511] = {700071,750200,700281,700421,700151,700171,700251,700221,700311},
  [10510] = {750000,700001,700311,700401,700051,700041,700111,700191,700071,700051}
}
-- -------------------partner_commend_skill_end---------------------


-- -------------------partner_skill_level_start-------------------
Config.PartnerSkillData.data_partner_skill_level_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_level[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_level['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_level_end---------------------


-- -------------------partner_skill_map_start-------------------
Config.PartnerSkillData.data_partner_skill_map_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_map[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_map['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_map_end---------------------


-- -------------------partner_skill_back_start-------------------
Config.PartnerSkillData.data_partner_skill_back_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_back[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_back['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_back_end---------------------


-- -------------------partner_skill_view_start-------------------
Config.PartnerSkillData.data_partner_skill_view_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_view[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_view['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_view_end---------------------


-- -------------------partner_skill_item_start-------------------
Config.PartnerSkillData.data_partner_skill_item_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_skill_item[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_skill_item['..key..'])not found') return
	end
	return data
end
-- -------------------partner_skill_item_end---------------------


-- -------------------partner_awakening_skill_start-------------------
Config.PartnerSkillData.data_partner_awakening_skill_fun = function(key)
	local data=Config.PartnerSkillData.data_partner_awakening_skill[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkillData.data_partner_awakening_skill['..key..'])not found') return
	end
	return data
end
-- -------------------partner_awakening_skill_end---------------------
