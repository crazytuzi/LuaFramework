----------------------------------------------------
-- 此文件由数据工具生成
-- 战力飞升0.1元礼包活动配置数据--holiday_dime_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayDimeData = Config.HolidayDimeData or {}

-- -------------------constant_start-------------------
Config.HolidayDimeData.data_constant_length = 1
Config.HolidayDimeData.data_constant = {
	["original_price"] = {label='original_price', val=648, desc="原价"}
}
Config.HolidayDimeData.data_constant_fun = function(key)
	local data=Config.HolidayDimeData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayDimeData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------period_list_start-------------------
Config.HolidayDimeData.data_period_list_length = 2
Config.HolidayDimeData.data_period_list = {
	[1] = {period=1, change_id=1705, is_cheap=1},
	[2] = {period=2, change_id=1706, is_cheap=0},
}
-- -------------------period_list_end---------------------


-- -------------------award_list_start-------------------
Config.HolidayDimeData.data_award_list_length = 2
Config.HolidayDimeData.data_award_list = {
	[1] = {
		[1] = {period=1, id=1, power_limit=0, award={{3,200}}, is_show_effect=0},
		[2] = {period=1, id=2, power_limit=50000, award={{10403,1}}, is_show_effect=0},
		[3] = {period=1, id=3, power_limit=150000, award={{10001,200}}, is_show_effect=0},
		[4] = {period=1, id=4, power_limit=300000, award={{29905,50}}, is_show_effect=1},
	},
	[2] = {
		[5] = {period=2, id=5, power_limit=0, award={{3,200}}, is_show_effect=0},
		[6] = {period=2, id=6, power_limit=50000, award={{10403,1}}, is_show_effect=0},
		[7] = {period=2, id=7, power_limit=150000, award={{10001,200}}, is_show_effect=0},
		[8] = {period=2, id=8, power_limit=300000, award={{29905,50}}, is_show_effect=1},
	},
}
-- -------------------award_list_end---------------------
