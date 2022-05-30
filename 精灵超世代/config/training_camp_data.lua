----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--training_camp_data.xml
--------------------------------------

Config = Config or {} 
Config.TrainingCampData = Config.TrainingCampData or {}

LocalizedConfigRequire("config.auto_config.training_camp_data@data_camp_tips")
LocalizedConfigRequire("config.auto_config.training_camp_data@data_city_tips")
LocalizedConfigRequire("config.auto_config.training_camp_data@data_const")
LocalizedConfigRequire("config.auto_config.training_camp_data@data_info")

-- -------------------const_start-------------------
Config.TrainingCampData.data_const_fun = function(key)
	local data=Config.TrainingCampData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.TrainingCampData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------info_start-------------------
Config.TrainingCampData.data_info_fun = function(key)
	local data=Config.TrainingCampData.data_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.TrainingCampData.data_info['..key..'])not found') return
	end
	return data
end
-- -------------------info_end---------------------


-- -------------------city_tips_start-------------------
Config.TrainingCampData.data_city_tips_fun = function(key)
	local data=Config.TrainingCampData.data_city_tips[key]
	if DATA_DEBUG and data == nil then
		print('(Config.TrainingCampData.data_city_tips['..key..'])not found') return
	end
	return data
end
-- -------------------city_tips_end---------------------


-- -------------------camp_tips_start-------------------
Config.TrainingCampData.data_camp_tips_fun = function(key)
	local data=Config.TrainingCampData.data_camp_tips[key]
	if DATA_DEBUG and data == nil then
		print('(Config.TrainingCampData.data_camp_tips['..key..'])not found') return
	end
	return data
end
-- -------------------camp_tips_end---------------------
