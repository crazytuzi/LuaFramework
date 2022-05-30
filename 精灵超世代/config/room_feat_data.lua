----------------------------------------------------
-- 此文件由数据工具生成
-- 个人空间成就数据--room_feat_data.xml
--------------------------------------

Config = Config or {} 
Config.RoomFeatData = Config.RoomFeatData or {}

LocalizedConfigRequire("config.auto_config.room_feat_data@data_const")
LocalizedConfigRequire("config.auto_config.room_feat_data@data_exp_info")
LocalizedConfigRequire("config.auto_config.room_feat_data@data_honor_icon_info")
LocalizedConfigRequire("config.auto_config.room_feat_data@data_honor_title_info")
LocalizedConfigRequire("config.auto_config.room_feat_data@data_show_list")
LocalizedConfigRequire("config.auto_config.room_feat_data@data_type_list")


-- -------------------const_start-------------------
Config.RoomFeatData.data_const_fun = function(key)
	local data=Config.RoomFeatData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoomFeatData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------exp_info_start-------------------
Config.RoomFeatData.data_exp_info_fun = function(key)
	local data=Config.RoomFeatData.data_exp_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoomFeatData.data_exp_info['..key..'])not found') return
	end
	return data
end
-- -------------------exp_info_end---------------------


-- -------------------honor_icon_info_start-------------------
Config.RoomFeatData.data_honor_icon_info_fun = function(key)
	local data=Config.RoomFeatData.data_honor_icon_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoomFeatData.data_honor_icon_info['..key..'])not found') return
	end
	return data
end
-- -------------------honor_icon_info_end---------------------


-- -------------------honor_title_info_start-------------------
-- -------------------honor_title_info_end---------------------


-- -------------------type_list_start-------------------
-- -------------------type_list_end---------------------


-- -------------------show_list_start-------------------
-- -------------------show_list_end---------------------
