----------------------------------------------------
-- 此文件由数据工具生成
-- 存储空间配置数据--package_data.xml
--------------------------------------

Config = Config or {} 
Config.PackageData = Config.PackageData or {}

LocalizedConfigRequire("config.auto_config.package_data@data_backpack_cost")
LocalizedConfigRequire("config.auto_config.package_data@data_backpack_use")

-- -------------------backpack_cost_start-------------------
Config.PackageData.data_backpack_cost_fun = function(key)
	local data=Config.PackageData.data_backpack_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PackageData.data_backpack_cost['..key..'])not found') return
	end
	return data
end
-- -------------------backpack_cost_end---------------------


-- -------------------backpack_use_start-------------------
-- -------------------backpack_use_end---------------------
