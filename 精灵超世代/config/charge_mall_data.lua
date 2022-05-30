----------------------------------------------------
-- 此文件由数据工具生成
-- 充值商城配置数据--charge_mall_data.xml
--------------------------------------

Config = Config or {} 
Config.ChargeMallData = Config.ChargeMallData or {}

LocalizedConfigRequire("config.auto_config.charge_mall_data@data_const")
LocalizedConfigRequire("config.auto_config.charge_mall_data@data_skin_mall")
LocalizedConfigRequire("config.auto_config.charge_mall_data@data_charge_shop")

-- -------------------const_start-------------------
Config.ChargeMallData.data_const_fun = function(key)
	local data=Config.ChargeMallData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeMallData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------charge_shop_start-------------------
Config.ChargeMallData.data_charge_shop_fun = function(key)
	local data=Config.ChargeMallData.data_charge_shop[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeMallData.data_charge_shop['..key..'])not found') return
	end
	return data
end
-- -------------------charge_shop_end---------------------


-- -------------------skin_mall_start-------------------
Config.ChargeMallData.data_skin_mall_fun = function(key)
	local data=Config.ChargeMallData.data_skin_mall[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ChargeMallData.data_skin_mall['..key..'])not found') return
	end
	return data
end
-- -------------------skin_mall_end---------------------
