----------------------------------------------------
-- 此文件由数据工具生成
-- 联盟远航配置数据--shipping_data.xml
--------------------------------------

Config = Config or {} 
Config.ShippingData = Config.ShippingData or {}

LocalizedConfigRequire("config.auto_config.shipping_data@data_condition")
LocalizedConfigRequire("config.auto_config.shipping_data@data_const")
LocalizedConfigRequire("config.auto_config.shipping_data@data_explain")
LocalizedConfigRequire("config.auto_config.shipping_data@data_order")
LocalizedConfigRequire("config.auto_config.shipping_data@data_quick_cost")
LocalizedConfigRequire("config.auto_config.shipping_data@data_refresh")

-- -------------------const_start-------------------
Config.ShippingData.data_const_fun = function(key)
	local data=Config.ShippingData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ShippingData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------order_start-------------------
Config.ShippingData.data_order_fun = function(key)
	local data=Config.ShippingData.data_order[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ShippingData.data_order['..key..'])not found') return
	end
	return data
end
-- -------------------order_end---------------------


-- -------------------condition_start-------------------
Config.ShippingData.data_condition_fun = function(key)
	local data=Config.ShippingData.data_condition[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ShippingData.data_condition['..key..'])not found') return
	end
	return data
end
-- -------------------condition_end---------------------


-- -------------------quick_cost_start-------------------
Config.ShippingData.data_quick_cost_fun = function(key)
	local data=Config.ShippingData.data_quick_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ShippingData.data_quick_cost['..key..'])not found') return
	end
	return data
end
-- -------------------quick_cost_end---------------------


-- -------------------refresh_start-------------------
Config.ShippingData.data_refresh_fun = function(key)
	local data=Config.ShippingData.data_refresh[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ShippingData.data_refresh['..key..'])not found') return
	end
	return data
end
-- -------------------refresh_end---------------------


-- -------------------explain_start-------------------
Config.ShippingData.data_explain_fun = function(key)
	local data=Config.ShippingData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ShippingData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
