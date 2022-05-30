----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--exchange_data.xml
--------------------------------------

Config = Config or {} 
Config.ExchangeData = Config.ExchangeData or {}

LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_expediton")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_furniture")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_gold")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_guild")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_hero")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_herosoul")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_ladder")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_peakchampion")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_pet")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_seer")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_suit")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_list")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_arena")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_cloth")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_cost")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_crosschampion")
LocalizedConfigRequire("config.auto_config.exchange_data@data_shop_exchage_elite")

-- -------------------shop_exchage_cost_start-------------------
Config.ExchangeData.data_shop_exchage_cost_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_cost['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_cost_end---------------------


-- -------------------shop_list_start-------------------
Config.ExchangeData.data_shop_list_fun = function(key)
	local data=Config.ExchangeData.data_shop_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_list['..key..'])not found') return
	end
	return data
end
-- -------------------shop_list_end---------------------


-- -------------------shop_exchage_gold_start-------------------
Config.ExchangeData.data_shop_exchage_gold_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_gold[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_gold['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_gold_end---------------------


-- -------------------shop_exchage_skin_start-------------------
Config.ExchangeData.data_shop_exchage_skin_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_skin[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_skin['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_skin_end---------------------


-- -------------------shop_exchage_guild_start-------------------
Config.ExchangeData.data_shop_exchage_guild_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_guild[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_guild['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_guild_end---------------------


-- -------------------shop_exchage_arena_start-------------------
Config.ExchangeData.data_shop_exchage_arena_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_arena[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_arena['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_arena_end---------------------


-- -------------------shop_exchage_boss_start-------------------
Config.ExchangeData.data_shop_exchage_boss_length = 0
Config.ExchangeData.data_shop_exchage_boss = {
}
-- -------------------shop_exchage_boss_end---------------------


-- -------------------shop_exchage_friend_start-------------------
Config.ExchangeData.data_shop_exchage_friend_length = 0
Config.ExchangeData.data_shop_exchage_friend = {

}
Config.ExchangeData.data_shop_exchage_friend_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_friend[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_friend['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_friend_end---------------------


-- -------------------shop_exchage_boss_type_start-------------------
Config.ExchangeData.data_shop_exchage_boss_type_length = 0
Config.ExchangeData.data_shop_exchage_boss_type = {

}
-- -------------------shop_exchage_boss_type_end---------------------


-- -------------------shop_star_start-------------------
Config.ExchangeData.data_shop_star_length = 0
Config.ExchangeData.data_shop_star = {
}
-- -------------------shop_star_end---------------------


-- -------------------shop_exchage_ladder_start-------------------
-- -------------------shop_exchage_ladder_end---------------------


-- -------------------shop_exchage_seer_start-------------------
-- -------------------shop_exchage_seer_end---------------------


-- -------------------shop_exchage_expediton_start-------------------
-- -------------------shop_exchage_expediton_end---------------------


-- -------------------shop_exchage_elite_start-------------------
-- -------------------shop_exchage_elite_end---------------------


-- -------------------shop_exchage_suit_start-------------------
-- -------------------shop_exchage_suit_end---------------------


-- -------------------shop_exchage_furniture_start-------------------
Config.ExchangeData.data_shop_exchage_furniture_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_furniture[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_furniture['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_furniture_end---------------------


-- -------------------shop_exchage_pet_start-------------------
Config.ExchangeData.data_shop_exchage_pet_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_pet[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_pet['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_pet_end---------------------


-- -------------------shop_exchage_crosschampion_start-------------------
Config.ExchangeData.data_shop_exchage_crosschampion_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_crosschampion[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_crosschampion['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_crosschampion_end---------------------


-- -------------------shop_exchage_peakchampion_start-------------------
Config.ExchangeData.data_shop_exchage_peakchampion_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_peakchampion[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_peakchampion['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_peakchampion_end---------------------


-- -------------------shop_exchage_herosoul_start-------------------
Config.ExchangeData.data_shop_exchage_herosoul_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_herosoul[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_herosoul['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_herosoul_end---------------------


-- -------------------shop_exchage_hero_start-------------------
Config.ExchangeData.data_shop_exchage_hero_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_hero[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_hero['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_hero_end---------------------


-- -------------------shop_exchage_cloth_start-------------------
Config.ExchangeData.data_shop_exchage_cloth_fun = function(key)
	local data=Config.ExchangeData.data_shop_exchage_cloth[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExchangeData.data_shop_exchage_cloth['..key..'])not found') return
	end
	return data
end
-- -------------------shop_exchage_cloth_end---------------------
