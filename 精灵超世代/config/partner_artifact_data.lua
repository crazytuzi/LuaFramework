----------------------------------------------------
-- 此文件由数据工具生成
-- 伙伴装备配置数据--partner_artifact_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerArtifactData = Config.PartnerArtifactData or {}

LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_attr")
LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_attr_score")
LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_compound")
LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_const")
LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_data")
LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_resolve")
LocalizedConfigRequire("config.auto_config.partner_artifact_data@data_artifact_skill")


-- -------------------artifact_const_start-------------------
Config.PartnerArtifactData.data_artifact_const_fun = function(key)
	local data=Config.PartnerArtifactData.data_artifact_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerArtifactData.data_artifact_const['..key..'])not found') return
	end
	return data
end
-- -------------------artifact_const_end---------------------


-- -------------------artifact_data_start-------------------
Config.PartnerArtifactData.data_artifact_data_fun = function(key)
	local data=Config.PartnerArtifactData.data_artifact_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerArtifactData.data_artifact_data['..key..'])not found') return
	end
	return data
end
-- -------------------artifact_data_end---------------------


-- -------------------artifact_attr_start-------------------
-- -------------------artifact_attr_end---------------------


-- -------------------artifact_attr_score_start-------------------
-- -------------------artifact_attr_score_end---------------------


-- -------------------artifact_compound_start-------------------
-- -------------------artifact_compound_end---------------------


-- -------------------artifact_resolve_start-------------------
Config.PartnerArtifactData.data_artifact_resolve_fun = function(key)
	local data=Config.PartnerArtifactData.data_artifact_resolve[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerArtifactData.data_artifact_resolve['..key..'])not found') return
	end
	return data
end
-- -------------------artifact_resolve_end---------------------


-- -------------------artifact_skill_start-------------------
Config.PartnerArtifactData.data_artifact_skill_fun = function(key)
	local data=Config.PartnerArtifactData.data_artifact_skill[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerArtifactData.data_artifact_skill['..key..'])not found') return
	end
	return data
end
-- -------------------artifact_skill_end---------------------
