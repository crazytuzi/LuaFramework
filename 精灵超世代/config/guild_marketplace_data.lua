
----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--guild_marketplace_data.xml
--------------------------------------

Config = Config or {} 
Config.GuildMarketplaceData = Config.GuildMarketplaceData or {}

LocalizedConfigRequire("config.auto_config.guild_marketplace_data@data_const")
LocalizedConfigRequire("config.auto_config.guild_marketplace_data@data_dic_item_info")
LocalizedConfigRequire("config.auto_config.guild_marketplace_data@data_explain")
LocalizedConfigRequire("config.auto_config.guild_marketplace_data@data_item_info")
LocalizedConfigRequire("config.auto_config.guild_marketplace_data@data_landlady_info")


-- -------------------const_start-------------------
Config.GuildMarketplaceData.data_const_fun = function(key)
	local data=Config.GuildMarketplaceData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildMarketplaceData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------item_info_start-------------------
-- -------------------item_info_end---------------------


-- -------------------dic_item_info_start-------------------
Config.GuildMarketplaceData.data_dic_item_info_fun = function(key)
	local data=Config.GuildMarketplaceData.data_dic_item_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildMarketplaceData.data_dic_item_info['..key..'])not found') return
	end
	return data
end
-- -------------------dic_item_info_end---------------------


-- -------------------explain_start-------------------
Config.GuildMarketplaceData.data_explain_fun = function(key)
	local data=Config.GuildMarketplaceData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.GuildMarketplaceData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------landlady_info_start-------------------
-- -------------------landlady_info_end---------------------
