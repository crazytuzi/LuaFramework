----------------------------------------------------
-- 此文件由数据工具生成
-- 元素神殿--element_temple_data.xml
--------------------------------------

Config = Config or {} 
Config.ElementTempleData = Config.ElementTempleData or {}

LocalizedConfigRequire("config.auto_config.element_temple_data@data_award")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_base")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_buy_count")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_const")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_customs")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_explain")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_monster")
LocalizedConfigRequire("config.auto_config.element_temple_data@data_privilege")

-- -------------------const_start-------------------
Config.ElementTempleData.data_const_fun = function(key)
	local data=Config.ElementTempleData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ElementTempleData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------base_start-------------------
Config.ElementTempleData.data_base_fun = function(key)
	local data=Config.ElementTempleData.data_base[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ElementTempleData.data_base['..key..'])not found') return
	end
	return data
end
-- -------------------base_end---------------------


-- -------------------customs_start-------------------
-- -------------------customs_end---------------------


-- -------------------buy_count_start-------------------
Config.ElementTempleData.data_buy_count_fun = function(key)
	local data=Config.ElementTempleData.data_buy_count[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ElementTempleData.data_buy_count['..key..'])not found') return
	end
	return data
end
-- -------------------buy_count_end---------------------


-- -------------------privilege_start-------------------
Config.ElementTempleData.data_privilege_fun = function(key)
	local data=Config.ElementTempleData.data_privilege[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ElementTempleData.data_privilege['..key..'])not found') return
	end
	return data
end
-- -------------------privilege_end---------------------


-- -------------------award_start-------------------
-- -------------------award_end---------------------


-- -------------------monster_start-------------------
Config.ElementTempleData.data_monster_fun = function(key)
	local data=Config.ElementTempleData.data_monster[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ElementTempleData.data_monster['..key..'])not found') return
	end
	return data
end
-- -------------------monster_end---------------------


-- -------------------explain_start-------------------
Config.ElementTempleData.data_explain_fun = function(key)
	local data=Config.ElementTempleData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ElementTempleData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
