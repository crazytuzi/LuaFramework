----------------------------------------------------
-- 此文件由数据工具生成
-- 聊天框数据--say_data.xml
--------------------------------------

Config = Config or {} 
Config.SayData = Config.SayData or {}
LocalizedConfigRequire("config.auto_config.say_data@data_const")
LocalizedConfigRequire("config.auto_config.say_data@data_say_frame")

-- -------------------say_frame_start-------------------
Config.SayData.data_say_frame_fun = function(key)
	local data=Config.SayData.data_say_frame[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SayData.data_say_frame['..key..'])not found') return
	end
	return data
end
-- -------------------say_frame_end---------------------


-- -------------------const_start-------------------
Config.SayData.data_const_fun = function(key)
	local data=Config.SayData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SayData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------
