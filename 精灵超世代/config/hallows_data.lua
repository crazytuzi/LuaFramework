----------------------------------------------------
-- 此文件由数据工具生成
-- 圣器配置数据--hallows_data.xml
--------------------------------------

Config = Config or {} 
Config.HallowsData = Config.HallowsData or {}

LocalizedConfigRequire("config.auto_config.hallows_data@data_attr_radio")
LocalizedConfigRequire("config.auto_config.hallows_data@data_base")
LocalizedConfigRequire("config.auto_config.hallows_data@data_const")
LocalizedConfigRequire("config.auto_config.hallows_data@data_info")
LocalizedConfigRequire("config.auto_config.hallows_data@data_magic")
LocalizedConfigRequire("config.auto_config.hallows_data@data_magic_task")
LocalizedConfigRequire("config.auto_config.hallows_data@data_max_lev")
LocalizedConfigRequire("config.auto_config.hallows_data@data_skill_attr")
LocalizedConfigRequire("config.auto_config.hallows_data@data_skill_max_lev")
LocalizedConfigRequire("config.auto_config.hallows_data@data_skill_up")
LocalizedConfigRequire("config.auto_config.hallows_data@data_task")
LocalizedConfigRequire("config.auto_config.hallows_data@data_task_info")
LocalizedConfigRequire("config.auto_config.hallows_data@data_trace_cost")

-- -------------------const_start-------------------
Config.HallowsData.data_const_fun = function(key)
	local data=Config.HallowsData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HallowsData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------max_lev_start-------------------
-- -------------------max_lev_end---------------------


-- -------------------base_start-------------------
-- -------------------base_end---------------------


-- -------------------info_start-------------------
-- -------------------info_end---------------------


-- -------------------skill_up_start-------------------
-- -------------------skill_up_end---------------------


-- -------------------skill_max_lev_start-------------------
-- -------------------skill_max_lev_end---------------------


-- -------------------trace_cost_start-------------------
-- -------------------trace_cost_end---------------------


-- -------------------attr_radio_start-------------------
Config.HallowsData.data_attr_radio_fun = function(key)
	local data=Config.HallowsData.data_attr_radio[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HallowsData.data_attr_radio['..key..'])not found') return
	end
	return data
end
-- -------------------attr_radio_end---------------------


-- -------------------task_start-------------------
Config.HallowsData.data_task_fun = function(key)
	local data=Config.HallowsData.data_task[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HallowsData.data_task['..key..'])not found') return
	end
	return data
end
-- -------------------task_end---------------------


-- -------------------task_info_start-------------------
-- -------------------task_info_end---------------------


-- -------------------skill_attr_start-------------------
-- -------------------skill_attr_end---------------------


-- -------------------magic_start-------------------
Config.HallowsData.data_magic_fun = function(key)
	local data=Config.HallowsData.data_magic[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HallowsData.data_magic['..key..'])not found') return
	end
	return data
end
-- -------------------magic_end---------------------


-- -------------------magic_task_start-------------------
Config.HallowsData.data_magic_task_fun = function(key)
	local data=Config.HallowsData.data_magic_task[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HallowsData.data_magic_task['..key..'])not found') return
	end
	return data
end
-- -------------------magic_task_end---------------------
