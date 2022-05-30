----------------------------------------------------
-- 此文件由数据工具生成
-- 录像馆配置数据--video_data.xml
--------------------------------------

Config = Config or {} 
Config.VideoData = Config.VideoData or {}

LocalizedConfigRequire("config.auto_config.video_data@data_const")
LocalizedConfigRequire("config.auto_config.video_data@data_vedio")

-- -------------------const_start-------------------
Config.VideoData.data_const_fun = function(key)
	local data=Config.VideoData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.VideoData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------vedio_start-------------------
Config.VideoData.data_vedio_fun = function(key)
	local data=Config.VideoData.data_vedio[key]
	if DATA_DEBUG and data == nil then
		print('(Config.VideoData.data_vedio['..key..'])not found') return
	end
	return data
end
-- -------------------vedio_end---------------------
