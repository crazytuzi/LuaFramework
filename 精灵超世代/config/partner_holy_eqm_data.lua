----------------------------------------------------
-- 此文件由数据工具生成
-- 神装--partner_holy_eqm_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerHolyEqmData = Config.PartnerHolyEqmData or {}

LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_attr_color_rule")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_attr_max_info")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_base_info")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_const")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_holy_attr_score")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_holy_suit_manage")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_suit_info")
LocalizedConfigRequire("config.auto_config.partner_holy_eqm_data@data_suit_res_prefix")

-- -------------------const_start-------------------
Config.PartnerHolyEqmData.data_const_fun = function(key)
	local data=Config.PartnerHolyEqmData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerHolyEqmData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------suit_info_start-------------------
-- -------------------suit_info_end---------------------


-- -------------------base_info_start-------------------
-- -------------------base_info_end---------------------


-- -------------------suit_res_prefix_start-------------------
Config.PartnerHolyEqmData.data_suit_res_prefix_fun = function(key)
	local data=Config.PartnerHolyEqmData.data_suit_res_prefix[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerHolyEqmData.data_suit_res_prefix['..key..'])not found') return
	end
	return data
end
-- -------------------suit_res_prefix_end---------------------


-- -------------------attr_color_rule_start-------------------
Config.PartnerHolyEqmData.data_attr_color_rule_fun = function(key)
	local data=Config.PartnerHolyEqmData.data_attr_color_rule[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerHolyEqmData.data_attr_color_rule['..key..'])not found') return
	end
	return data
end
-- -------------------attr_color_rule_end---------------------


-- -------------------attr_max_info_start-------------------
Config.PartnerHolyEqmData.data_attr_max_info_fun = function(key)
	local data=Config.PartnerHolyEqmData.data_attr_max_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerHolyEqmData.data_attr_max_info['..key..'])not found') return
	end
	return data
end
-- -------------------attr_max_info_end---------------------


-- -------------------holy_suit_manage_start-------------------
Config.PartnerHolyEqmData.data_holy_suit_manage_fun = function(key)
	local data=Config.PartnerHolyEqmData.data_holy_suit_manage[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerHolyEqmData.data_holy_suit_manage['..key..'])not found') return
	end
	return data
end
-- -------------------holy_suit_manage_end---------------------


-- -------------------holy_attr_score_start-------------------
Config.PartnerHolyEqmData.data_holy_attr_score_fun = function(key)
	local data=Config.PartnerHolyEqmData.data_holy_attr_score[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerHolyEqmData.data_holy_attr_score['..key..'])not found') return
	end
	return data
end
-- -------------------holy_attr_score_end---------------------
