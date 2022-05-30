----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--cross_show_data.xml
--------------------------------------

Config = Config or {} 
Config.CrossShowData = Config.CrossShowData or {}

LocalizedConfigRequire("config.auto_config.cross_show_data@data_base")
LocalizedConfigRequire("config.auto_config.cross_show_data@data_const")

-- -------------------const_start-------------------
Config.CrossShowData.data_const_fun = function(key)
	local data=Config.CrossShowData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CrossShowData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------base_start-------------------
Config.CrossShowData.data_base_fun = function(key)
	local data=Config.CrossShowData.data_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CrossShowData.data_base['..key..'])not found') return
	end
	return data
end
-- -------------------base_end---------------------
