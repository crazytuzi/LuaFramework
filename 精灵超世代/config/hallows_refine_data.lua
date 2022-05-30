----------------------------------------------------
-- 此文件由数据工具生成
-- 礼包配置数据--hallows_refine_data.xml
--------------------------------------

Config = Config or {} 
Config.HallowsRefineData = Config.HallowsRefineData or {}

LocalizedConfigRequire("config.auto_config.hallows_refine_data@data_const")
LocalizedConfigRequire("config.auto_config.hallows_refine_data@data_max_lev")
LocalizedConfigRequire("config.auto_config.hallows_refine_data@data_refine")


-- -------------------const_start-------------------
Config.HallowsRefineData.data_const_fun = function(key)
	local data=Config.HallowsRefineData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HallowsRefineData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------refine_start-------------------
-- -------------------refine_end---------------------


-- -------------------max_lev_start-------------------
-- -------------------max_lev_end---------------------
