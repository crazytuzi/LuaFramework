----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_role_push_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayRolePushData = Config.HolidayRolePushData or {}

-- -------------------constant_start-------------------
Config.HolidayRolePushData.data_constant_length = 2
Config.HolidayRolePushData.data_constant = {
	["count"] = {val=1, desc="每天推送次数"},
	["off_time_push"] = {val=1800, desc="离线间隔秒数"}
}
Config.HolidayRolePushData.data_constant_fun = function(key)
	local data=Config.HolidayRolePushData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayRolePushData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------push_list_start-------------------
Config.HolidayRolePushData.data_push_list_length = 4
Config.HolidayRolePushData.data_push_list = {
	[1] = {jump_id=1},
	[2] = {jump_id=2},
	[3] = {jump_id=3},
	[4] = {jump_id=4}
}
Config.HolidayRolePushData.data_push_list_fun = function(key)
	local data=Config.HolidayRolePushData.data_push_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayRolePushData.data_push_list['..key..'])not found') return
	end
	return data
end
-- -------------------push_list_end---------------------
