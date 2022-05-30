----------------------------------------------------
-- 此文件由数据工具生成
-- 阵法配置数据--formation_data.xml
--------------------------------------

Config = Config or {} 
Config.FormationData = Config.FormationData or {}

LocalizedConfigRequire("config.auto_config.formation_data@data_form_cost")
LocalizedConfigRequire("config.auto_config.formation_data@data_form_data")

-- -------------------form_cost_start-------------------
Config.FormationData.data_form_cost_fun = function(key)
	local data=Config.FormationData.data_form_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FormationData.data_form_cost['..key..'])not found') return
	end
	return data
end
-- -------------------form_cost_end---------------------


-- -------------------form_data_start-------------------
Config.FormationData.data_form_data_fun = function(key)
	local data=Config.FormationData.data_form_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FormationData.data_form_data['..key..'])not found') return
	end
	return data
end
-- -------------------form_data_end---------------------
