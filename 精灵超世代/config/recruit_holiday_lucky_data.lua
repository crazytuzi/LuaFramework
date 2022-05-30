----------------------------------------------------
-- 此文件由数据工具生成
-- 活动召唤数据--recruit_holiday_lucky_data.xml
--------------------------------------

Config = Config or {} 
Config.RecruitHolidayLuckyData = Config.RecruitHolidayLuckyData or {}

LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_probability")
LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_summon")
LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_wish")
LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_action")
LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_award")
LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_const")
LocalizedConfigRequire("config.auto_config.recruit_holiday_lucky_data@data_hero_show")

-- -------------------const_start-------------------
Config.RecruitHolidayLuckyData.data_const_fun = function(key)
	local data=Config.RecruitHolidayLuckyData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHolidayLuckyData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------action_start-------------------
Config.RecruitHolidayLuckyData.data_action_fun = function(key)
	local data=Config.RecruitHolidayLuckyData.data_action[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHolidayLuckyData.data_action['..key..'])not found') return
	end
	return data
end
-- -------------------action_end---------------------


-- -------------------summon_start-------------------
Config.RecruitHolidayLuckyData.data_summon_fun = function(key)
	local data=Config.RecruitHolidayLuckyData.data_summon[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHolidayLuckyData.data_summon['..key..'])not found') return
	end
	return data
end
-- -------------------summon_end---------------------


-- -------------------award_start-------------------
-- -------------------award_end---------------------


-- -------------------probability_start-------------------
-- -------------------probability_end---------------------


-- -------------------hero_show_start-------------------
-- -------------------hero_show_end---------------------


-- -------------------wish_start-------------------
-- -------------------wish_end---------------------
