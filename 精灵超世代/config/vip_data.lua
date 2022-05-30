----------------------------------------------------
-- 此文件由数据工具生成
-- VIP配置数据--vip_data.xml
--------------------------------------

Config = Config or {} 
Config.VipData = Config.VipData or {}

LocalizedConfigRequire("config.auto_config.vip_data@data_get_reward")
LocalizedConfigRequire("config.auto_config.vip_data@data_get_vip_icon")
LocalizedConfigRequire("config.auto_config.vip_data@data_get_vip_info")

-- -------------------get_reward_start-------------------
Config.VipData.data_get_reward_fun = function(key)
	local data=Config.VipData.data_get_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.VipData.data_get_reward['..key..'])not found') return
	end
	return data
end
-- -------------------get_reward_end---------------------


-- -------------------get_vip_info_start-------------------
Config.VipData.data_get_vip_info_fun = function(key)
	local data=Config.VipData.data_get_vip_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.VipData.data_get_vip_info['..key..'])not found') return
	end
	return data
end
-- -------------------get_vip_info_end---------------------


-- -------------------get_vip_icon_start-------------------
Config.VipData.data_get_vip_icon_fun = function(key)
	local data=Config.VipData.data_get_vip_icon[key]
	if DATA_DEBUG and data == nil then
		print('(Config.VipData.data_get_vip_icon['..key..'])not found') return
	end
	return data
end
-- -------------------get_vip_icon_end---------------------
