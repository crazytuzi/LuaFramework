----------------------------------------------------
-- 此文件由数据工具生成
-- 星命塔配置数据--star_tower_data.xml
--------------------------------------

Config = Config or {} 
Config.StarTowerData = Config.StarTowerData or {}

LocalizedConfigRequire("config.auto_config.star_tower_data@data_get_floor_award")
LocalizedConfigRequire("config.auto_config.star_tower_data@data_tower_base")
LocalizedConfigRequire("config.auto_config.star_tower_data@data_tower_buy")
LocalizedConfigRequire("config.auto_config.star_tower_data@data_tower_const")
LocalizedConfigRequire("config.auto_config.star_tower_data@data_tower_vip")

-- -------------------tower_const_start-------------------
Config.StarTowerData.data_tower_const_fun = function(key)
	local data=Config.StarTowerData.data_tower_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StarTowerData.data_tower_const['..key..'])not found') return
	end
	return data
end
-- -------------------tower_const_end---------------------


-- -------------------tower_base_start-------------------
Config.StarTowerData.data_tower_base_fun = function(key)
	local data=Config.StarTowerData.data_tower_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StarTowerData.data_tower_base['..key..'])not found') return
	end
	return data
end
-- -------------------tower_base_end---------------------


-- -------------------tower_vip_start-------------------
Config.StarTowerData.data_tower_vip_fun = function(key)
	local data=Config.StarTowerData.data_tower_vip[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StarTowerData.data_tower_vip['..key..'])not found') return
	end
	return data
end
-- -------------------tower_vip_end---------------------


-- -------------------tower_buy_start-------------------
Config.StarTowerData.data_tower_buy_fun = function(key)
	local data=Config.StarTowerData.data_tower_buy[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StarTowerData.data_tower_buy['..key..'])not found') return
	end
	return data
end
-- -------------------tower_buy_end---------------------


-- -------------------award_list_start-------------------
Config.StarTowerData.data_award_list_length = 0
Config.StarTowerData.data_award_list = {

}
Config.StarTowerData.data_award_list_fun = function(key)
	local data=Config.StarTowerData.data_award_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StarTowerData.data_award_list['..key..'])not found') return
	end
	return data
end
-- -------------------award_list_end---------------------


-- -------------------get_floor_award_start-------------------
Config.StarTowerData.data_get_floor_award_fun = function(key)
	local data=Config.StarTowerData.data_get_floor_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.StarTowerData.data_get_floor_award['..key..'])not found') return
	end
	return data
end
-- -------------------get_floor_award_end---------------------
