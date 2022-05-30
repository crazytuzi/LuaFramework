----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--recruit_award_data.xml
--------------------------------------

Config = Config or {} 
Config.RecruitAwardData = Config.RecruitAwardData or {}

-- -------------------const_start-------------------
Config.RecruitAwardData.data_const_length = 3
Config.RecruitAwardData.data_const = {
	["open_day"] = {val=0, desc="注册第几天开始"},
	["end_day"] = {val=0, desc="注册第几天结束"},
	["desc_rult"] = {val=0, desc="1.消耗钻石参与召唤可得好礼；\n2.免费召唤、金币召唤、召唤券召唤次数不计算在内。"}
}
Config.RecruitAwardData.data_const_fun = function(key)
	local data=Config.RecruitAwardData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitAwardData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------huoli_start-------------------
Config.RecruitAwardData.data_huoli_length = 9
Config.RecruitAwardData.data_huoli = {
	[1] = {id=1, desc="钻石召唤5次", type=0, count=5, award={{3,100}}},
	[2] = {id=2, desc="钻石召唤10次", type=0, count=10, award={{3,100},{3,100}}},
	[3] = {id=3, desc="钻石召唤20次", type=0, count=20, award={{3,100},{3,100}}},
	[4] = {id=4, desc="钻石召唤30次", type=0, count=30, award={{3,100},{3,100}}},
	[5] = {id=5, desc="钻石召唤50次", type=0, count=50, award={{3,100},{3,100}}},
	[6] = {id=6, desc="钻石召唤80次", type=0, count=80, award={{3,100},{3,100}}},
	[7] = {id=7, desc="钻石召唤100次", type=0, count=100, award={{3,100},{3,100}}},
	[8] = {id=8, desc="钻石召唤150次", type=0, count=150, award={{3,100},{3,100}}},
	[9] = {id=9, desc="钻石召唤200次", type=0, count=200, award={{3,100},{3,100}}}
}
Config.RecruitAwardData.data_huoli_fun = function(key)
	local data=Config.RecruitAwardData.data_huoli[key]
	if DATA_DEBUG and data == nil then
		print('(Config.RecruitAwardData.data_huoli['..key..'])not found') return
	end
	return data
end
-- -------------------huoli_end---------------------
