----------------------------------------------------
-- 此文件由数据工具生成
-- 物品数据--item_data.xml
--------------------------------------

Config = Config or {} 
Config.ItemData = Config.ItemData or {}

LocalizedConfigRequire("config.auto_config.item_data@data_item_sort")
LocalizedConfigRequire("config.auto_config.item_data@data_item_type")
LocalizedConfigRequire("config.auto_config.item_data@data_skill_item_list")
LocalizedConfigRequire("config.auto_config.item_data@data_treasure_info")
LocalizedConfigRequire("config.auto_config.item_data@data_assets_id2label")
LocalizedConfigRequire("config.auto_config.item_data@data_assets_label2id")
LocalizedConfigRequire("config.auto_config.item_data@data_holy_eqm_list")
LocalizedConfigRequire("config.auto_config.item_data@data_item_effect_type")

-- -------------------unit_start-------------------
Config.ItemData.data_get_data = function(key)
	return Config.ItemData1.data_unit(key) or Config.ItemData2.data_unit(key) or Config.ItemData3.data_unit(key) or Config.ItemData4.data_unit(key) or Config.ItemData5.data_unit(key) or Config.ItemData6.data_unit(key) or Config.ItemData7.data_unit(key) or Config.ItemData8.data_unit(key) or Config.ItemData9.data_unit(key) or Config.ItemData10.data_unit(key)
end

-- -------------------treasure_info_start-------------------
-- -------------------treasure_info_end---------------------

-- -------------------assets_id2label_start-------------------
-- -------------------assets_id2label_end---------------------

-- -------------------assets_label2id_start-------------------
-- -------------------assets_label2id_end---------------------


-- -------------------item_sort_start-------------------
Config.ItemData.data_item_sort_fun = function(key)
	local data=Config.ItemData.data_item_sort[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ItemData.data_item_sort['..key..'])not found') return
	end
	return data
end
-- -------------------item_sort_end---------------------

-- -------------------skill_item_list_start-------------------
-- -------------------skill_item_list_end---------------------

-- -------------------holy_eqm_list_start-------------------
-- -------------------holy_eqm_list_end---------------------

