----------------------------------------------------
-- 此文件由数据工具生成
-- 我要变强数据配置--stronger_data.xml
--------------------------------------

Config = Config or {} 
Config.StrongerData = Config.StrongerData or {}

LocalizedConfigRequire("config.auto_config.stronger_data@data_problem")
LocalizedConfigRequire("config.auto_config.stronger_data@data_recommand")
LocalizedConfigRequire("config.auto_config.stronger_data@data_resource_one")
LocalizedConfigRequire("config.auto_config.stronger_data@data_resource_two")
LocalizedConfigRequire("config.auto_config.stronger_data@data_stronger_constant")
LocalizedConfigRequire("config.auto_config.stronger_data@data_stronger_two")

-- -------------------stronger_constant_start-------------------
Config.StrongerData.data_stronger_constant_fun = function(key)
	local data=Config.StrongerData.data_stronger_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StrongerData.data_stronger_constant['..key..'])not found') return
	end
	return data
end
-- -------------------stronger_constant_end---------------------


-- -------------------stronger_two_start-------------------
Config.StrongerData.data_stronger_two_fun = function(key)
	local data=Config.StrongerData.data_stronger_two[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StrongerData.data_stronger_two['..key..'])not found') return
	end
	return data
end
-- -------------------stronger_two_end---------------------


-- -------------------resource_one_start-------------------
Config.StrongerData.data_resource_one_fun = function(key)
	local data=Config.StrongerData.data_resource_one[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StrongerData.data_resource_one['..key..'])not found') return
	end
	return data
end
-- -------------------resource_one_end---------------------


-- -------------------resource_two_start-------------------
Config.StrongerData.data_resource_two_fun = function(key)
	local data=Config.StrongerData.data_resource_two[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StrongerData.data_resource_two['..key..'])not found') return
	end
	return data
end
-- -------------------resource_two_end---------------------


-- -------------------recommand_start-------------------
Config.StrongerData.data_recommand_fun = function(key)
	local data=Config.StrongerData.data_recommand[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StrongerData.data_recommand['..key..'])not found') return
	end
	return data
end
-- -------------------recommand_end---------------------


-- -------------------problem_start-------------------
Config.StrongerData.data_problem_fun = function(key)
	local data=Config.StrongerData.data_problem[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StrongerData.data_problem['..key..'])not found') return
	end
	return data
end
-- -------------------problem_end---------------------
