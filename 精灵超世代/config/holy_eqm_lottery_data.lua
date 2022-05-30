----------------------------------------------------
-- 此文件由数据工具生成
-- 神装抽奖--holy_eqm_lottery_data.xml
--------------------------------------

Config = Config or {} 
Config.HolyEqmLotteryData = Config.HolyEqmLotteryData or {}

LocalizedConfigRequire("config.auto_config.holy_eqm_lottery_data@data_award")
LocalizedConfigRequire("config.auto_config.holy_eqm_lottery_data@data_const")
LocalizedConfigRequire("config.auto_config.holy_eqm_lottery_data@data_group")
LocalizedConfigRequire("config.auto_config.holy_eqm_lottery_data@data_wish_id")
LocalizedConfigRequire("config.auto_config.holy_eqm_lottery_data@data_wish_show")

-- -------------------const_start-------------------
Config.HolyEqmLotteryData.data_const_fun = function(key)
	local data=Config.HolyEqmLotteryData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolyEqmLotteryData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------group_start-------------------
Config.HolyEqmLotteryData.data_group_fun = function(key)
	local data=Config.HolyEqmLotteryData.data_group[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolyEqmLotteryData.data_group['..key..'])not found') return
	end
	return data
end
-- -------------------group_end---------------------


-- -------------------wish_show_start-------------------
Config.HolyEqmLotteryData.data_wish_show_fun = function(key)
	local data=Config.HolyEqmLotteryData.data_wish_show[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolyEqmLotteryData.data_wish_show['..key..'])not found') return
	end
	return data
end
-- -------------------wish_show_end---------------------


-- -------------------wish_id_start-------------------
-- -------------------wish_id_end---------------------


-- -------------------award_start-------------------
-- -------------------award_end---------------------
