----------------------------------------------------
-- 此文件由数据工具生成
-- 新七日登录配置数据--login_days_new_data.xml
--------------------------------------

Config = Config or {} 
Config.LoginDaysNewData = Config.LoginDaysNewData or {}

LocalizedConfigRequire("config.auto_config.login_days_new_data@data_day")

-- -------------------day_start-------------------
Config.LoginDaysNewData.data_day_fun = function(key)
	local data=Config.LoginDaysNewData.data_day[key]
	if DATA_DEBUG and data == nil then
		print('(Config.LoginDaysNewData.data_day['..key..'])not found') return
	end
	return data
end
-- -------------------day_end---------------------
