----------------------------------------------------
-- 此文件由数据工具生成
-- 砸蛋--break_egg_data.xml
--------------------------------------

Config = Config or {} 
Config.BreakEggData = Config.BreakEggData or {}

LocalizedConfigRequire("config.auto_config.break_egg_data@data_award")
LocalizedConfigRequire("config.auto_config.break_egg_data@data_const")

-- -------------------const_start-------------------
Config.BreakEggData.data_const_fun = function(key)
	local data=Config.BreakEggData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.BreakEggData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------award_start-------------------
Config.BreakEggData.data_award_fun = function(key)
	local data=Config.BreakEggData.data_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.BreakEggData.data_award['..key..'])not found') return
	end
	return data
end
-- -------------------award_end---------------------
