----------------------------------------------------
-- 此文件由数据工具生成
-- 伙伴招募数据--recruit_data.xml
--------------------------------------

Config = Config or {} 
Config.RecruitData = Config.RecruitData or {}

LocalizedConfigRequire("config.auto_config.recruit_data@data_explain")
LocalizedConfigRequire("config.auto_config.recruit_data@data_partnersummon_const")
LocalizedConfigRequire("config.auto_config.recruit_data@data_partnersummon_data")
LocalizedConfigRequire("config.auto_config.recruit_data@data_summon_data")

-- -------------------partnersummon_data_start-------------------
Config.RecruitData.data_partnersummon_data_fun = function(key)
	local data=Config.RecruitData.data_partnersummon_data[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitData.data_partnersummon_data['..key..'])not found') return
	end
	return data
end
-- -------------------partnersummon_data_end---------------------

Config.RecruitData.data_partnersummon_txt = {
	[1] = {desc="<div fontcolor=#ffffff outline=2,#3d5078>随机获得1个或10个1-5星宝可梦</div>"},
	[2] = {desc="<div fontcolor=#ffffff outline=2,#d63636>随机获得1个或10个3-5星宝可梦</div>"},
	[3] = {desc="<div fontcolor=#ffffff outline=2,#ba39da>随机获得1个或10个2-5星宝可梦</div>"},
}

-- -------------------partnersummon_const_start-------------------
Config.RecruitData.data_partnersummon_const_fun = function(key)
	local data=Config.RecruitData.data_partnersummon_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitData.data_partnersummon_const['..key..'])not found') return
	end
	return data
end
-- -------------------partnersummon_const_end---------------------


-- -------------------explain_start-------------------
Config.RecruitData.data_explain_fun = function(key)
	local data=Config.RecruitData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------summon_data_start-------------------
-- -------------------summon_data_end---------------------
