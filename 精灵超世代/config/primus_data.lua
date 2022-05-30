----------------------------------------------------
-- 此文件由数据工具生成
-- 最强仙尊-神殿--primus_data.xml
--------------------------------------

Config = Config or {} 
Config.PrimusData = Config.PrimusData or {}

LocalizedConfigRequire("config.auto_config.primus_data@data_const")
LocalizedConfigRequire("config.auto_config.primus_data@data_unitdata")
LocalizedConfigRequire("config.auto_config.primus_data@data_upgrade")


-- -------------------const_start-------------------
Config.PrimusData.data_const_fun = function(key)
	local data=Config.PrimusData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PrimusData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------upgrade_start-------------------
Config.PrimusData.data_upgrade_fun = function(key)
	local data=Config.PrimusData.data_upgrade[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PrimusData.data_upgrade['..key..'])not found') return
	end
	return data
end
-- -------------------upgrade_end---------------------


-- -------------------unitdata_start-------------------
Config.PrimusData.data_unitdata_fun = function(key)
	local data=Config.PrimusData.data_unitdata[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PrimusData.data_unitdata['..key..'])not found') return
	end
	return data
end
-- -------------------unitdata_end---------------------
