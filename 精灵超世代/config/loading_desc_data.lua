----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--loading_desc_data.xml
--------------------------------------

Config = Config or {} 
Config.LoadingDescData = Config.LoadingDescData or {}

LocalizedConfigRequire("config.auto_config.loading_desc_data@data_desc")

--add by chenbin:处理多语言,将多语言子table合并进原始子table
--此文件在loading前就会使用
-- setUpLocalizedData("LoadingDescData")
----------------------------------

-- -------------------desc_start-------------------
Config.LoadingDescData.data_desc_fun = function(key)
	local data=Config.LoadingDescData.data_desc[key]
	if DATA_DEBUG and data == nil then
		print('(Config.LoadingDescData.data_desc['..key..'])not found') return
	end
	return data
end
-- -------------------desc_end---------------------
