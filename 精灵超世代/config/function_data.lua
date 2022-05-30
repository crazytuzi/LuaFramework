----------------------------------------------------
-- 此文件由数据工具生成
-- 图标配置数据--function_data.xml
--------------------------------------

Config = Config or {} 
Config.FunctionData = Config.FunctionData or {}

LocalizedConfigRequire("config.auto_config.function_data@data_info")
LocalizedConfigRequire("config.auto_config.function_data@data_limit_action")
LocalizedConfigRequire("config.auto_config.function_data@data_limit_change_const")
LocalizedConfigRequire("config.auto_config.function_data@data_limit_little_recharge")
LocalizedConfigRequire("config.auto_config.function_data@data_special_bubble")
LocalizedConfigRequire("config.auto_config.function_data@data_three_gear_gift_const")
LocalizedConfigRequire("config.auto_config.function_data@data_base")
LocalizedConfigRequire("config.auto_config.function_data@data_bubble")
LocalizedConfigRequire("config.auto_config.function_data@data_convert_icon")
LocalizedConfigRequire("config.auto_config.function_data@data_festval_const")

-- -------------------info_start-------------------
Config.FunctionData.data_info_fun = function(key)
	local data=Config.FunctionData.data_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_info['..key..'])not found') return
	end
	return data
end
-- -------------------info_end---------------------


-- -------------------base_start-------------------
Config.FunctionData.data_base_fun = function(key)
	local data=Config.FunctionData.data_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_base['..key..'])not found') return
	end
	return data
end
-- -------------------base_end---------------------


-- -------------------bubble_start-------------------
-- -------------------bubble_end---------------------


-- -------------------special_bubble_start-------------------
-- -------------------special_bubble_end---------------------


-- -------------------limit_action_start-------------------
Config.FunctionData.data_limit_action_fun = function(key)
	local data=Config.FunctionData.data_limit_action[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_limit_action['..key..'])not found') return
	end
	return data
end
-- -------------------limit_action_end---------------------


-- -------------------festval_const_start-------------------
Config.FunctionData.data_festval_const_fun = function(key)
	local data=Config.FunctionData.data_festval_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_festval_const['..key..'])not found') return
	end
	return data
end
-- -------------------festval_const_end---------------------


-- -------------------limit_change_const_start-------------------
Config.FunctionData.data_limit_change_const_fun = function(key)
	local data=Config.FunctionData.data_limit_change_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_limit_change_const['..key..'])not found') return
	end
	return data
end
-- -------------------limit_change_const_end---------------------


-- -------------------limit_little_recharge_start-------------------
Config.FunctionData.data_limit_little_recharge_fun = function(key)
	local data=Config.FunctionData.data_limit_little_recharge[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_limit_little_recharge['..key..'])not found') return
	end
	return data
end
-- -------------------limit_little_recharge_end---------------------


-- -------------------convert_icon_start-------------------
-- -------------------convert_icon_end---------------------


-- -------------------three_gear_gift_const_start-------------------
Config.FunctionData.data_three_gear_gift_const_fun = function(key)
	local data=Config.FunctionData.data_three_gear_gift_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.FunctionData.data_three_gear_gift_const['..key..'])not found') return
	end
	return data
end
-- -------------------three_gear_gift_const_end---------------------
