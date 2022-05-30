----------------------------------------------------
-- 此文件由数据工具生成
-- 任务数据--quest_data.xml
--------------------------------------

Config = Config or {} 
Config.QuestData = Config.QuestData or {}

LocalizedConfigRequire("config.auto_config.quest_data@data_get")
LocalizedConfigRequire("config.auto_config.quest_data@data_progress_lable")

-- -------------------get_start-------------------
Config.QuestData.data_get_fun = function(key)
	local data=Config.QuestData.data_get[key]
	if DATA_DEBUG and data == nil then
		print('(Config.QuestData.data_get['..key..'])not found') return
	end
	return data
end
-- -------------------get_end---------------------


-- -------------------progress_lable_start-------------------
-- -------------------progress_lable_end---------------------
