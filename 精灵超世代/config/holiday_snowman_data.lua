----------------------------------------------------
-- 此文件由数据工具生成
-- 堆雪人活动数据配置--holiday_snowman_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidaySnowmanData = Config.HolidaySnowmanData or {}

-- -------------------const_data_start-------------------
Config.HolidaySnowmanData.data_const_data_length = 1
Config.HolidaySnowmanData.data_const_data = {
	["cost_item"] = {key="cost_item", val=14803, desc="消耗道具"}
}
-- -------------------const_data_end---------------------


-- -------------------item_data_start-------------------
Config.HolidaySnowmanData.data_item_data_length = 1
Config.HolidaySnowmanData.data_item_data = {
	[14803] = {base_id=14803, happy_val=1, reward_id=14800}
}
-- -------------------item_data_end---------------------


-- -------------------happy_list_start-------------------
Config.HolidaySnowmanData.data_happy_list_length = 4
Config.HolidaySnowmanData.data_happy_list = {
	[100] = {happy_val=100, rewards={{14801,1}}},
	[250] = {happy_val=250, rewards={{14801,1}}},
	[400] = {happy_val=400, rewards={{14801,1}}},
	[600] = {happy_val=600, rewards={{14802,1}}}
}
-- -------------------happy_list_end---------------------
