----------------------------------------------------
-- 此文件由数据工具生成
-- 充值配置数据--charge_data.xml
--------------------------------------

Config = Config or {} 
Config.ChargeData = Config.ChargeData or {}

LocalizedConfigRequire("config.auto_config.charge_data@data_supre_reward_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_charge_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_charge_reward_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_constant")
LocalizedConfigRequire("config.auto_config.charge_data@data_daily_gift_award")
LocalizedConfigRequire("config.auto_config.charge_data@data_daily_gift_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_daily_reward")
LocalizedConfigRequire("config.auto_config.charge_data@data_first_charge_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_first_charge_lwt_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_first_reward_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_new_first_charge_data")
LocalizedConfigRequire("config.auto_config.charge_data@data_new_first_charge_data3")

-- -------------------constant_start-------------------
Config.ChargeData.data_constant_fun = function(key)
	local data=Config.ChargeData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------charge_data_start-------------------
Config.ChargeData.data_charge_data_fun = function(key)
	local data=Config.ChargeData.data_charge_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_charge_data['..key..'])not found') return
	end
	return data
end
-- -------------------charge_data_end---------------------


-- -------------------charge_reward_data_start-------------------
Config.ChargeData.data_charge_reward_data_fun = function(key)
	local data=Config.ChargeData.data_charge_reward_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_charge_reward_data['..key..'])not found') return
	end
	return data
end
-- -------------------charge_reward_data_end---------------------


-- -------------------first_reward_data_start-------------------
Config.ChargeData.data_first_reward_data_fun = function(key)
	local data=Config.ChargeData.data_first_reward_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_first_reward_data['..key..'])not found') return
	end
	return data
end
-- -------------------first_reward_data_end---------------------


-- -------------------first_charge_data_start-------------------
Config.ChargeData.data_first_charge_data_fun = function(key)
	local data=Config.ChargeData.data_first_charge_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_first_charge_data['..key..'])not found') return
	end
	return data
end
-- -------------------first_charge_data_end---------------------


-- -------------------daily_gift_data_start-------------------
Config.ChargeData.data_daily_gift_data_fun = function(key)
	local data=Config.ChargeData.data_daily_gift_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_daily_gift_data['..key..'])not found') return
	end
	return data
end
-- -------------------daily_gift_data_end---------------------


-- -------------------daily_gift_award_start-------------------
-- -------------------daily_gift_award_end---------------------


-- -------------------supre_reward_data_start-------------------
Config.ChargeData.data_supre_reward_data_fun = function(key)
	local data=Config.ChargeData.data_supre_reward_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_supre_reward_data['..key..'])not found') return
	end
	return data
end
-- -------------------supre_reward_data_end---------------------


-- -------------------daily_reward_start-------------------
-- -------------------daily_reward_end---------------------


-- -------------------new_first_charge_data_start-------------------
Config.ChargeData.data_new_first_charge_data_fun = function(key)
	local data=Config.ChargeData.data_new_first_charge_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_new_first_charge_data['..key..'])not found') return
	end
	return data
end
-- -------------------new_first_charge_data_end---------------------


-- -------------------first_charge_lwt_data_start-------------------
Config.ChargeData.data_first_charge_lwt_data_fun = function(key)
	local data=Config.ChargeData.data_first_charge_lwt_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_first_charge_lwt_data['..key..'])not found') return
	end
	return data
end
-- -------------------first_charge_lwt_data_end---------------------


-- -------------------new_first_charge_data3_start-------------------
Config.ChargeData.data_new_first_charge_data3_fun = function(key)
	local data=Config.ChargeData.data_new_first_charge_data3[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeData.data_new_first_charge_data3['..key..'])not found') return
	end
	return data
end
-- -------------------new_first_charge_data3_end---------------------
