----------------------------------------------------
-- 此文件由数据工具生成
-- 精灵抽奖数据--holiday_sprite_lottery_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidaySpriteLotteryData = Config.HolidaySpriteLotteryData or {}

LocalizedConfigRequire("config.auto_config.holiday_sprite_lottery_data@data_hero_show")
LocalizedConfigRequire("config.auto_config.holiday_sprite_lottery_data@data_probability")
LocalizedConfigRequire("config.auto_config.holiday_sprite_lottery_data@data_summon")
LocalizedConfigRequire("config.auto_config.holiday_sprite_lottery_data@data_action")
LocalizedConfigRequire("config.auto_config.holiday_sprite_lottery_data@data_award")
LocalizedConfigRequire("config.auto_config.holiday_sprite_lottery_data@data_const")

-- -------------------const_start-------------------
Config.HolidaySpriteLotteryData.data_const_fun = function(key)
	local data=Config.HolidaySpriteLotteryData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySpriteLotteryData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------action_start-------------------
Config.HolidaySpriteLotteryData.data_action_fun = function(key)
	local data=Config.HolidaySpriteLotteryData.data_action[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySpriteLotteryData.data_action['..key..'])not found') return
	end
	return data
end
-- -------------------action_end---------------------


-- -------------------summon_start-------------------
Config.HolidaySpriteLotteryData.data_summon_fun = function(key)
	local data=Config.HolidaySpriteLotteryData.data_summon[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySpriteLotteryData.data_summon['..key..'])not found') return
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
