----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_personal_gift_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayPersonalGiftData = Config.HolidayPersonalGiftData or {}

-- -------------------price_start-------------------
Config.HolidayPersonalGiftData.data_price_length = 6
Config.HolidayPersonalGiftData.data_price = {
	[6] = {charge_id=1201, price=6},
	[30] = {charge_id=1202, price=30},
	[68] = {charge_id=1203, price=68},
	[128] = {charge_id=1204, price=128},
	[328] = {charge_id=1205, price=328},
	[648] = {charge_id=1206, price=648}
}
Config.HolidayPersonalGiftData.data_price_fun = function(key)
	local data=Config.HolidayPersonalGiftData.data_price[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPersonalGiftData.data_price['..key..'])not found') return
	end
	return data
end
-- -------------------price_end---------------------


-- -------------------gift_warehouse_start-------------------
Config.HolidayPersonalGiftData.data_gift_warehouse_length = 6
Config.HolidayPersonalGiftData.data_gift_warehouse = {
	[1] = {price=648, award={{3,6480},{10,105300}}, limit_count=1, name="888"},
	[2] = {price=648, award={{3,6480},{28,4200}}, limit_count=1, name="888"},
	[3] = {price=648, award={{3,6480},{10450,42100}}, limit_count=1, name="888"},
	[4] = {price=648, award={{3,6480},{72001,2800}}, limit_count=1, name="888"},
	[5] = {price=648, award={{3,6480},{32,2106000}}, limit_count=1, name="888"},
	[6] = {price=648, award={{3,6480},{17009,2100}}, limit_count=1, name="888"}
}
Config.HolidayPersonalGiftData.data_gift_warehouse_fun = function(key)
	local data=Config.HolidayPersonalGiftData.data_gift_warehouse[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPersonalGiftData.data_gift_warehouse['..key..'])not found') return
	end
	return data
end
-- -------------------gift_warehouse_end---------------------
