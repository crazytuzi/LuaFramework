----------------------------------------------------
-- 此文件由数据工具生成
-- 圣物配置数据--halidom_data.xml
--------------------------------------

Config = Config or {} 
Config.HalidomData = Config.HalidomData or {}

LocalizedConfigRequire("config.auto_config.halidom_data@data_base")
LocalizedConfigRequire("config.auto_config.halidom_data@data_const")
LocalizedConfigRequire("config.auto_config.halidom_data@data_lvup")
LocalizedConfigRequire("config.auto_config.halidom_data@data_max_lev")
LocalizedConfigRequire("config.auto_config.halidom_data@data_max_step")
LocalizedConfigRequire("config.auto_config.halidom_data@data_skill")
LocalizedConfigRequire("config.auto_config.halidom_data@data_step")


-- -------------------const_start-------------------
Config.HalidomData.data_const_fun = function(key)
	local data=Config.HalidomData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HalidomData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------base_start-------------------
Config.HalidomData.data_base_fun = function(key)
	local data=Config.HalidomData.data_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HalidomData.data_base['..key..'])not found') return
	end
	return data
end
-- -------------------base_end---------------------


-- -------------------max_lev_start-------------------
-- -------------------max_lev_end---------------------


-- -------------------max_step_start-------------------
-- -------------------max_step_end---------------------


-- -------------------lvup_start-------------------
-- -------------------lvup_end---------------------


-- -------------------step_start-------------------
-- -------------------step_end---------------------


-- -------------------skill_start-------------------
Config.HalidomData.data_skill_fun = function(key)
	local data=Config.HalidomData.data_skill[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HalidomData.data_skill['..key..'])not found') return
	end
	return data
end
-- -------------------skill_end---------------------
