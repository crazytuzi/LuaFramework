----------------------------------------------------
-- 此文件由数据工具生成
-- 跨服天梯--sky_ladder_data.xml
--------------------------------------

Config = Config or {} 
Config.SkyLadderData = Config.SkyLadderData or {}

LocalizedConfigRequire("config.auto_config.sky_ladder_data@data_award")
LocalizedConfigRequire("config.auto_config.sky_ladder_data@data_buy_num")
LocalizedConfigRequire("config.auto_config.sky_ladder_data@data_const")
LocalizedConfigRequire("config.auto_config.sky_ladder_data@data_explain")

-- -------------------const_start-------------------
Config.SkyLadderData.data_const_fun = function(key)
	local data=Config.SkyLadderData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkyLadderData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------award_start-------------------
Config.SkyLadderData.data_award_fun = function(key)
	local data=Config.SkyLadderData.data_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkyLadderData.data_award['..key..'])not found') return
	end
	return data
end
-- -------------------award_end---------------------


-- -------------------buy_num_start-------------------
Config.SkyLadderData.data_buy_num_fun = function(key)
	local data=Config.SkyLadderData.data_buy_num[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkyLadderData.data_buy_num['..key..'])not found') return
	end
	return data
end
-- -------------------buy_num_end---------------------


-- -------------------explain_start-------------------
Config.SkyLadderData.data_explain_fun = function(key)
	local data=Config.SkyLadderData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.SkyLadderData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
