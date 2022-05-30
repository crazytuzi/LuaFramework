----------------------------------------------------
-- 此文件由数据工具生成
-- 精灵配置表--sprite_data.xml
--------------------------------------

Config = Config or {} 
Config.SpriteData = Config.SpriteData or {}

LocalizedConfigRequire("config.auto_config.sprite_data@data_const")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_book")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_com")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_data")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_plan")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_reset")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_skill")
LocalizedConfigRequire("config.auto_config.sprite_data@data_elfin_skill_icon")
LocalizedConfigRequire("config.auto_config.sprite_data@data_hatch_data")
LocalizedConfigRequire("config.auto_config.sprite_data@data_hatch_egg")
LocalizedConfigRequire("config.auto_config.sprite_data@data_hatch_lev")
LocalizedConfigRequire("config.auto_config.sprite_data@data_smash_item")
LocalizedConfigRequire("config.auto_config.sprite_data@data_tree_attr")
LocalizedConfigRequire("config.auto_config.sprite_data@data_tree_limit")
LocalizedConfigRequire("config.auto_config.sprite_data@data_tree_step")
LocalizedConfigRequire("config.auto_config.sprite_data@data_tree_up_lv")

-- -------------------const_start-------------------
Config.SpriteData.data_const_fun = function(key)
	local data=Config.SpriteData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------hatch_data_start-------------------
Config.SpriteData.data_hatch_data_fun = function(key)
	local data=Config.SpriteData.data_hatch_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_hatch_data['..key..'])not found') return
	end
	return data
end
-- -------------------hatch_data_end---------------------


-- -------------------hatch_lev_start-------------------
Config.SpriteData.data_hatch_lev_fun = function(key)
	local data=Config.SpriteData.data_hatch_lev[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_hatch_lev['..key..'])not found') return
	end
	return data
end
-- -------------------hatch_lev_end---------------------


-- -------------------hatch_egg_start-------------------
Config.SpriteData.data_hatch_egg_fun = function(key)
	local data=Config.SpriteData.data_hatch_egg[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_hatch_egg['..key..'])not found') return
	end
	return data
end
-- -------------------hatch_egg_end---------------------


-- -------------------smash_item_start-------------------
Config.SpriteData.data_smash_item_fun = function(key)
	local data=Config.SpriteData.data_smash_item[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_smash_item['..key..'])not found') return
	end
	return data
end
-- -------------------smash_item_end---------------------


-- -------------------elfin_data_start-------------------
-- -------------------elfin_data_end---------------------


-- -------------------elfin_book_start-------------------
-- -------------------elfin_book_end---------------------


-- -------------------elfin_skill_start-------------------
-- -------------------elfin_skill_end---------------------


-- -------------------elfin_skill_icon_start-------------------
-- -------------------elfin_skill_icon_end---------------------


-- -------------------tree_attr_start-------------------
-- -------------------tree_attr_end---------------------


-- -------------------tree_up_lv_start-------------------
-- -------------------tree_up_lv_end---------------------


-- -------------------tree_step_start-------------------
Config.SpriteData.data_tree_step_fun = function(key)
	local data=Config.SpriteData.data_tree_step[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_tree_step['..key..'])not found') return
	end
	return data
end
-- -------------------tree_step_end---------------------


-- -------------------tree_limit_start-------------------
-- -------------------tree_limit_end---------------------


-- -------------------elfin_com_start-------------------
Config.SpriteData.data_elfin_com_fun = function(key)
	local data=Config.SpriteData.data_elfin_com[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_elfin_com['..key..'])not found') return
	end
	return data
end
-- -------------------elfin_com_end---------------------


-- -------------------elfin_reset_start-------------------
-- -------------------elfin_reset_end---------------------


-- -------------------elfin_plan_start-------------------
Config.SpriteData.data_elfin_plan_fun = function(key)
	local data=Config.SpriteData.data_elfin_plan[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SpriteData.data_elfin_plan['..key..'])not found') return
	end
	return data
end
-- -------------------elfin_plan_end---------------------
