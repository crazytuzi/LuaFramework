----------------------------------------------------
-- 此文件由数据工具生成
-- 剧情数据--drama_data.xml
--------------------------------------

Config = Config or {} 
Config.DramaData = Config.DramaData or {}

LocalizedConfigRequire("config.auto_config.drama_data@data_get")
LocalizedConfigRequire("config.auto_config.drama_data@data_guide")
LocalizedConfigRequire("config.auto_config.drama_data@data_const")
LocalizedConfigRequire("config.auto_config.drama_data@data_guide_desc")

-- -------------------const_start-------------------
Config.DramaData.data_const_fun = function(key)
	local data=Config.DramaData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DramaData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------get_start-------------------
Config.DramaData.data_get_fun = function(key)
	local data=Config.DramaData.data_get[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DramaData.data_get['..key..'])not found') return
	end
	return data
end
-- -------------------get_end---------------------


-- -------------------guide_start-------------------
Config.DramaData.data_guide_fun = function(key)
	local data=Config.DramaData.data_guide[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DramaData.data_guide['..key..'])not found') return
	end
	return data
end
-- -------------------guide_end---------------------


-- -------------------lev_guide_start-------------------
Config.DramaData.data_lev_guide_length = 0
Config.DramaData.data_lev_guide = {

}
Config.DramaData.data_lev_guide_fun = function(key)
	local data=Config.DramaData.data_lev_guide[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DramaData.data_lev_guide['..key..'])not found') return
	end
	return data
end
-- -------------------lev_guide_end---------------------
