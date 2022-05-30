----------------------------------------------------
-- 此文件由数据工具生成
-- 活跃度--dungeon_heaven_data.xml
--------------------------------------

Config = Config or {} 
Config.DungeonHeavenData = Config.DungeonHeavenData or {}

LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_chapter")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_const")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_count_buy")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_customs")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_customs_num")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_customs_pos")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_star_award")
LocalizedConfigRequire("config.auto_config.dungeon_heaven_data@data_star_cond")


-- -------------------const_start-------------------
Config.DungeonHeavenData.data_const_fun = function(key)
	local data=Config.DungeonHeavenData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonHeavenData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------customs_start-------------------
-- -------------------customs_end---------------------


-- -------------------customs_num_start-------------------
-- -------------------customs_num_end---------------------


-- -------------------chapter_start-------------------
Config.DungeonHeavenData.data_chapter_fun = function(key)
	local data=Config.DungeonHeavenData.data_chapter[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonHeavenData.data_chapter['..key..'])not found') return
	end
	return data
end
-- -------------------chapter_end---------------------


-- -------------------star_award_start-------------------
-- -------------------star_award_end---------------------


-- -------------------star_cond_start-------------------
Config.DungeonHeavenData.data_star_cond_fun = function(key)
	local data=Config.DungeonHeavenData.data_star_cond[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonHeavenData.data_star_cond['..key..'])not found') return
	end
	return data
end
-- -------------------star_cond_end---------------------


-- -------------------count_buy_start-------------------
Config.DungeonHeavenData.data_count_buy_fun = function(key)
	local data=Config.DungeonHeavenData.data_count_buy[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonHeavenData.data_count_buy['..key..'])not found') return
	end
	return data
end
-- -------------------count_buy_end---------------------


-- -------------------customs_pos_start-------------------
-- -------------------customs_pos_end---------------------
