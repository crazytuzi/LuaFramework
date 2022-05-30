----------------------------------------------------
-- 此文件由数据工具生成
-- 弹幕配置数据--subtitle_data.xml
--------------------------------------

Config = Config or {} 
Config.SubtitleData = Config.SubtitleData or {}

LocalizedConfigRequire("config.auto_config.subtitle_data@data_const")
LocalizedConfigRequire("config.auto_config.subtitle_data@data_list")
LocalizedConfigRequire("config.auto_config.subtitle_data@data_system")

-- -------------------list_start-------------------
Config.SubtitleData.data_list_fun = function(key)
	local data=Config.SubtitleData.data_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SubtitleData.data_list['..key..'])not found') return
	end
	return data
end
-- -------------------list_end---------------------


-- -------------------system_start-------------------
-- -------------------system_end---------------------


-- -------------------const_start-------------------
Config.SubtitleData.data_const_fun = function(key)
	local data=Config.SubtitleData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SubtitleData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------
