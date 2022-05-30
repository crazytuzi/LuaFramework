----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--dungeon_stone_data.xml
--------------------------------------

Config = Config or {} 
Config.DungeonStoneData = Config.DungeonStoneData or {}

LocalizedConfigRequire("config.auto_config.dungeon_stone_data@data_award_list")
LocalizedConfigRequire("config.auto_config.dungeon_stone_data@data_buy")
LocalizedConfigRequire("config.auto_config.dungeon_stone_data@data_const")
LocalizedConfigRequire("config.auto_config.dungeon_stone_data@data_type_open")

-- -------------------const_start-------------------
Config.DungeonStoneData.data_const_fun = function(key)
	local data=Config.DungeonStoneData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonStoneData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------award_list_start-------------------
-- -------------------award_list_end---------------------


-- -------------------buy_start-------------------
-- -------------------buy_end---------------------


-- -------------------type_open_start-------------------
Config.DungeonStoneData.data_type_open_fun = function(key)
	local data=Config.DungeonStoneData.data_type_open[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonStoneData.data_type_open['..key..'])not found') return
	end
	return data
end
-- -------------------type_open_end---------------------
