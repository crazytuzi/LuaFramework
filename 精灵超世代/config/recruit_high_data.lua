----------------------------------------------------
-- 此文件由数据工具生成
-- 高级伙伴招募数据--recruit_high_data.xml
--------------------------------------

Config = Config or {} 
Config.RecruitHighData = Config.RecruitHighData or {}

LocalizedConfigRequire("config.auto_config.recruit_high_data@data_seerpalace_award")
LocalizedConfigRequire("config.auto_config.recruit_high_data@data_seerpalace_const")
LocalizedConfigRequire("config.auto_config.recruit_high_data@data_seerpalace_data")

-- -------------------seerpalace_data_start-------------------
Config.RecruitHighData.data_seerpalace_data_fun = function(key)
	local data=Config.RecruitHighData.data_seerpalace_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHighData.data_seerpalace_data['..key..'])not found') return
	end
	return data
end
-- -------------------seerpalace_data_end---------------------


-- -------------------seerpalace_const_start-------------------
Config.RecruitHighData.data_seerpalace_const_fun = function(key)
	local data=Config.RecruitHighData.data_seerpalace_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitHighData.data_seerpalace_const['..key..'])not found') return
	end
	return data
end
-- -------------------seerpalace_const_end---------------------


-- -------------------seerpalace_award_start-------------------
-- -------------------seerpalace_award_end---------------------
