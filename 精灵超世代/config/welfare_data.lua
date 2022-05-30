----------------------------------------------------
-- 此文件由数据工具生成
-- 活跃度--welfare_data.xml
--------------------------------------

Config = Config or {} 
Config.WelfareData = Config.WelfareData or {}

-- -------------------welfare_const_start-------------------
Config.WelfareData.data_welfare_const_length = 7
Config.WelfareData.data_welfare_const = {
	["award"] = {code="award", val={{26907,50}}, type="所有任务达成后奖励"},
	["min_reg_day"] = {code="min_reg_day", val=1, type="最小注册天数要求"},
	["max_reg_day"] = {code="max_reg_day", val=3, type="最大注册天数限制"},
	["dun_max_id"] = {code="dun_max_id", val=75, type="剧情副本通关数"},
	["invade_id"] = {code="invade_id", val=99940, type="进攻id（展示方）"},
	["defend_id"] = {code="defend_id", val=99941, type="防守id（强力的怪物）"},
	["limit_open_srv_date"] = {code="limit_open_srv_date", val={{2020,4,2},{9,59,0}}, type="该时间后开的新服不开启该活动"}
}
Config.WelfareData.data_welfare_const_fun = function(key)
	local data=Config.WelfareData.data_welfare_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.WelfareData.data_welfare_const['..key..'])not found') return
	end
	return data
end
-- -------------------welfare_const_end---------------------
