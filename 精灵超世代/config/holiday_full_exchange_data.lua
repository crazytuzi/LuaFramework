----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_full_exchange_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayFullExchangeData = Config.HolidayFullExchangeData or {}

-- -------------------holiday_full_exchange_start-------------------
Config.HolidayFullExchangeData.data_holiday_full_exchange_length = 4
Config.HolidayFullExchangeData.data_holiday_full_exchange = {
	[0] = {min=0, max=998, val=0},
	[1999] = {min=1999, max=4998, val=800},
	[4999] = {min=4999, max=9998, val=2250},
	[9999] = {min=9999, max=999999, val=5000}
}
Config.HolidayFullExchangeData.data_holiday_full_exchange_fun = function(key)
	local data=Config.HolidayFullExchangeData.data_holiday_full_exchange[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayFullExchangeData.data_holiday_full_exchange['..key..'])not found') return
	end
	return data
end
-- -------------------holiday_full_exchange_end---------------------
