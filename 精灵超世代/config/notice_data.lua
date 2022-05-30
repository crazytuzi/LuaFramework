----------------------------------------------------
-- 此文件由数据工具生成
-- 公告配置数据--notice_data.xml
--------------------------------------

Config = Config or {} 
Config.NoticeData = Config.NoticeData or {}

LocalizedConfigRequire("config.auto_config.notice_data@data_get")

-- -------------------get_start-------------------
Config.NoticeData.data_get_fun = function(key)
	local data=Config.NoticeData.data_get[key]
	if DATA_DEBUG and data == nil then
		print('(Config.NoticeData.data_get['..key..'])not found') return
	end
	return data
end
-- -------------------get_end---------------------
