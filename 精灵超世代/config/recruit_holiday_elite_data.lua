----------------------------------------------------
-- 此文件由数据工具生成
-- 活动召唤数据--recruit_holiday_elite_data.xml
--------------------------------------

Config = Config or {} 
Config.RecruitHolidayEliteData = Config.RecruitHolidayEliteData or {}

LocalizedConfigRequire("config.auto_config.recruit_holiday_elite_data@data_hero_show")
LocalizedConfigRequire("config.auto_config.recruit_holiday_elite_data@data_probability")
LocalizedConfigRequire("config.auto_config.recruit_holiday_elite_data@data_summon")
LocalizedConfigRequire("config.auto_config.recruit_holiday_elite_data@data_action")
LocalizedConfigRequire("config.auto_config.recruit_holiday_elite_data@data_award")
LocalizedConfigRequire("config.auto_config.recruit_holiday_elite_data@data_const")

-- -------------------const_start-------------------
Config.RecruitHolidayEliteData.data_const_fun = function(key)
	local data=Config.RecruitHolidayEliteData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHolidayEliteData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------action_start-------------------
Config.RecruitHolidayEliteData.data_action_fun = function(key)
	local data=Config.RecruitHolidayEliteData.data_action[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHolidayEliteData.data_action['..key..'])not found') return
	end
	return data
end
-- -------------------action_end---------------------


-- -------------------summon_start-------------------
Config.RecruitHolidayEliteData.data_summon_fun = function(key)
	local data=Config.RecruitHolidayEliteData.data_summon[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHolidayEliteData.data_summon['..key..'])not found') return
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
