----------------------------------------------------
-- 此文件由数据工具生成
-- 头像框数据--avatar_data.xml
--------------------------------------

Config = Config or {} 
Config.AvatarData = Config.AvatarData or {}

LocalizedConfigRequire("config.auto_config.avatar_data@data_avatar")
LocalizedConfigRequire("config.auto_config.avatar_data@data_avatar_effect")

-- -------------------avatar_start-------------------
Config.AvatarData.data_avatar_fun = function(key)
	local data=Config.AvatarData.data_avatar[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AvatarData.data_avatar['..key..'])not found') return
	end
	return data
end
-- -------------------avatar_end---------------------


-- -------------------avatar_effect_start-------------------
Config.AvatarData.data_avatar_effect_fun = function(key)
	local data=Config.AvatarData.data_avatar_effect[key]
	if DATA_DEBUG and data == nil then
		print('(Config.AvatarData.data_avatar_effect['..key..'])not found') return
	end
	return data
end
-- -------------------avatar_effect_end---------------------
