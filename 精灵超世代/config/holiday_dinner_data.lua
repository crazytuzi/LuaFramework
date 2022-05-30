----------------------------------------------------
-- 此文件由数据工具生成
-- 年夜饭活动数据配置--holiday_dinner_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayDinnerData = Config.HolidayDinnerData or {}

-- -------------------const_data_start-------------------
Config.HolidayDinnerData.data_const_data_length = 1
Config.HolidayDinnerData.data_const_data = {
	["cost_item"] = {key="cost_item", val=14804, desc="消耗道具"}
}
-- -------------------const_data_end---------------------


-- -------------------item_data_start-------------------
Config.HolidayDinnerData.data_item_data_length = 1
Config.HolidayDinnerData.data_item_data = {
	[14804] = {base_id=14804, happy_val=1}
}
-- -------------------item_data_end---------------------


-- -------------------happy_list_start-------------------
Config.HolidayDinnerData.data_happy_list_length = 4
Config.HolidayDinnerData.data_happy_list = {
	[6000] = {happy_val=6000, rewards={{81141,1}}},
	[12000] = {happy_val=12000, rewards={{81141,1}}},
	[18000] = {happy_val=18000, rewards={{81141,1}}},
	[25000] = {happy_val=25000, rewards={{81140,1}}}
}
-- -------------------happy_list_end---------------------
