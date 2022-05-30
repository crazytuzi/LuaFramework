----------------------------------------------------
-- 此文件由数据工具生成
-- 战令活动配置数据--holiday_new_war_order_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayNewWarOrderData = Config.HolidayNewWarOrderData or {}

LocalizedConfigRequire("config.auto_config.holiday_new_war_order_data@data_day_task_list")
LocalizedConfigRequire("config.auto_config.holiday_new_war_order_data@data_lev_reward_list")
LocalizedConfigRequire("config.auto_config.holiday_new_war_order_data@data_week_task_list")
LocalizedConfigRequire("config.auto_config.holiday_new_war_order_data@data_advance_card_list")
LocalizedConfigRequire("config.auto_config.holiday_new_war_order_data@data_constant")

-- -------------------constant_start-------------------
Config.HolidayNewWarOrderData.data_constant_fun = function(key)
	local data=Config.HolidayNewWarOrderData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayNewWarOrderData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------lev_reward_list_start-------------------
-- -------------------lev_reward_list_end---------------------


-- -------------------day_task_list_start-------------------
-- -------------------day_task_list_end---------------------


-- -------------------week_task_list_start-------------------
-- -------------------week_task_list_end---------------------


-- -------------------advance_card_list_start-------------------
-- -------------------advance_card_list_end---------------------
