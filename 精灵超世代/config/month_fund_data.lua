----------------------------------------------------
-- 此文件由数据工具生成
-- 月基金--month_fund_data.xml
--------------------------------------

Config = Config or {} 
Config.MonthFundData = Config.MonthFundData or {}

LocalizedConfigRequire("config.auto_config.month_fund_data@data_fund_group")
LocalizedConfigRequire("config.auto_config.month_fund_data@data_fund_award")
LocalizedConfigRequire("config.auto_config.month_fund_data@data_fund_data")

-- -------------------const_start-------------------
Config.MonthFundData.data_const_length = 0
Config.MonthFundData.data_const = {

}
Config.MonthFundData.data_const_fun = function(key)
	local data=Config.MonthFundData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonthFundData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------fund_data_start-------------------
Config.MonthFundData.data_fund_data_fun = function(key)
	local data=Config.MonthFundData.data_fund_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonthFundData.data_fund_data['..key..'])not found') return
	end
	return data
end
-- -------------------fund_data_end---------------------


-- -------------------fund_group_start-------------------
Config.MonthFundData.data_fund_group_fun = function(key)
	local data=Config.MonthFundData.data_fund_group[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonthFundData.data_fund_group['..key..'])not found') return
	end
	return data
end
-- -------------------fund_group_end---------------------


-- -------------------fund_award_start-------------------
-- -------------------fund_award_end---------------------
