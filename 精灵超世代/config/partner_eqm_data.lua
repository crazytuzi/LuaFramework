----------------------------------------------------
-- 此文件由数据工具生成
-- 伙伴装备配置数据--partner_eqm_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerEqmData = Config.PartnerEqmData or {}

LocalizedConfigRequire("config.auto_config.partner_eqm_data@data_eqm_compose_id")
LocalizedConfigRequire("config.auto_config.partner_eqm_data@data_eqm_suit")
LocalizedConfigRequire("config.auto_config.partner_eqm_data@data_partner_const")
LocalizedConfigRequire("config.auto_config.partner_eqm_data@data_partner_eqm")
LocalizedConfigRequire("config.auto_config.partner_eqm_data@data_partner_score")

-- -------------------partner_const_start-------------------
Config.PartnerEqmData.data_partner_const_fun = function(key)
	local data=Config.PartnerEqmData.data_partner_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerEqmData.data_partner_const['..key..'])not found') return
	end
	return data
end
-- -------------------partner_const_end---------------------


-- -------------------partner_eqm_start-------------------
-- -------------------partner_eqm_end---------------------


-- -------------------partner_score_start-------------------
Config.PartnerEqmData.data_partner_score_fun = function(key)
	local data=Config.PartnerEqmData.data_partner_score[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerEqmData.data_partner_score['..key..'])not found') return
	end
	return data
end
-- -------------------partner_score_end---------------------


-- -------------------eqm_compose_id_start-------------------
-- -------------------eqm_compose_id_end---------------------


-- -------------------eqm_suit_start-------------------
-- -------------------eqm_suit_end---------------------
