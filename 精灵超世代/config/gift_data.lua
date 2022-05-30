----------------------------------------------------
-- 此文件由数据工具生成
-- 礼包配置数据--gift_data.xml
--------------------------------------

LocalizedConfigRequire("config.auto_config.gift_data@data_choose_gift")
LocalizedConfigRequire("config.auto_config.gift_data@data_gift_data")
LocalizedConfigRequire("config.auto_config.gift_data@data_week_card_data")

Config = Config or {} 
Config.GiftData = Config.GiftData or {}

-- -------------------gift_data_start-------------------
Config.GiftData.data_gift_data_fun = function(key)
	local data=Config.GiftData.data_gift_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GiftData.data_gift_data['..key..'])not found') return
	end
	return data
end
-- -------------------gift_data_end---------------------


-- -------------------choose_gift_start-------------------

-- -------------------choose_gift_end---------------------


-- -------------------week_card_data_start-------------------
Config.GiftData.data_week_card_data_fun = function(key)
	local data=Config.GiftData.data_week_card_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GiftData.data_week_card_data['..key..'])not found') return
	end
	return data
end
-- -------------------week_card_data_end---------------------
