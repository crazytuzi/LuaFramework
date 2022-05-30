----------------------------------------------------
-- 此文件由数据工具生成
-- 个人空间成长之路数据--room_grow_data.xml
--------------------------------------

Config = Config or {} 
Config.RoomGrowData = Config.RoomGrowData or {}

LocalizedConfigRequire("config.auto_config.room_grow_data@data_carnival")
LocalizedConfigRequire("config.auto_config.room_grow_data@data_const")
LocalizedConfigRequire("config.auto_config.room_grow_data@data_growth_way_desc")

-- -------------------const_start-------------------
Config.RoomGrowData.data_const_fun = function(key)
	local data=Config.RoomGrowData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoomGrowData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------growth_way_desc_start-------------------
-- -------------------growth_way_desc_end---------------------


-- -------------------carnival_start-------------------
Config.RoomGrowData.data_carnival_fun = function(key)
	local data=Config.RoomGrowData.data_carnival[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RoomGrowData.data_carnival['..key..'])not found') return
	end
	return data
end
-- -------------------carnival_end---------------------
