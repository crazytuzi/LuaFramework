----------------------------------------------------
-- 此文件由数据工具生成
-- 签到--checkin_data.xml
--------------------------------------

Config = Config or {} 
Config.CheckinData = Config.CheckinData or {}

LocalizedConfigRequire("config.auto_config.checkin_data@data_award")
LocalizedConfigRequire("config.auto_config.checkin_data@data_const")

-- -------------------award_start-------------------
-- -------------------award_end---------------------


-- -------------------energy_start-------------------
Config.CheckinData.data_energy_length = 0
Config.CheckinData.data_energy = {

}
Config.CheckinData.data_energy_fun = function(key)
	local data=Config.CheckinData.data_energy[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CheckinData.data_energy['..key..'])not found') return
	end
	return data
end
-- -------------------energy_end---------------------


-- -------------------const_start-------------------
Config.CheckinData.data_const_fun = function(key)
	local data=Config.CheckinData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.CheckinData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------
