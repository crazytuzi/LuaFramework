----------------------------------------------------
-- 此文件由数据工具生成
-- 共鸣石碑--resonate_data.xml
--------------------------------------

Config = Config or {} 
Config.ResonateData = Config.ResonateData or {}

LocalizedConfigRequire("config.auto_config.resonate_data@data_crystal_cost")
LocalizedConfigRequire("config.auto_config.resonate_data@data_level_up")
LocalizedConfigRequire("config.auto_config.resonate_data@data_pos_info")
LocalizedConfigRequire("config.auto_config.resonate_data@data_star_attr")
LocalizedConfigRequire("config.auto_config.resonate_data@data_star_cost")
LocalizedConfigRequire("config.auto_config.resonate_data@data_cell_cost")
LocalizedConfigRequire("config.auto_config.resonate_data@data_const")

-- -------------------const_start-------------------
Config.ResonateData.data_const_fun = function(key)
	local data=Config.ResonateData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ResonateData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------pos_info_start-------------------
Config.ResonateData.data_pos_info_fun = function(key)
	local data=Config.ResonateData.data_pos_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ResonateData.data_pos_info['..key..'])not found') return
	end
	return data
end
-- -------------------pos_info_end---------------------


-- -------------------level_up_start-------------------
-- -------------------level_up_end---------------------


-- -------------------star_attr_start-------------------
-- -------------------star_attr_end---------------------


-- -------------------star_cost_start-------------------
Config.ResonateData.data_star_cost_fun = function(key)
	local data=Config.ResonateData.data_star_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ResonateData.data_star_cost['..key..'])not found') return
	end
	return data
end
-- -------------------star_cost_end---------------------


-- -------------------cell_cost_start-------------------
Config.ResonateData.data_cell_cost_fun = function(key)
	local data=Config.ResonateData.data_cell_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ResonateData.data_cell_cost['..key..'])not found') return
	end
	return data
end
-- -------------------cell_cost_end---------------------


-- -------------------crystal_cost_start-------------------
Config.ResonateData.data_crystal_cost_fun = function(key)
	local data=Config.ResonateData.data_crystal_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ResonateData.data_crystal_cost['..key..'])not found') return
	end
	return data
end
-- -------------------crystal_cost_end---------------------
