----------------------------------------------------
-- 此文件由数据工具生成
-- 远征配置数据--expedition_data.xml
--------------------------------------

Config = Config or {} 
Config.ExpeditionData = Config.ExpeditionData or {}

-- -------------------const_start-------------------
Config.ExpeditionData.data_const_length = 10
Config.ExpeditionData.data_const = {
	["num_employees"] = {val=3, desc="可雇佣英雄数量"},
	["num_employment"] = {val=10, desc="可被雇佣次数"},
	["war_ratio"] = {val=1500, desc="可雇佣英雄战力上限（千分比）"},
	["drop"] = {val={{14,10}}, desc="英雄被雇用奖励"},
	["game_rule"] = {val=1, desc="一、远征说明\n1.远征共有3个难度，通关上一难度后开启下一难度，达到该难度战力后即可挑战。每天只可挑战一个难度，选择后当天不可更换难度。\n2.远征总共15关，点击关卡即可进行挑战。\n3.每个关卡胜利后均可获得奖励，每成功挑战3个关卡即可领取宝箱奖励，远征勋章可在远征商店中兑换道具。\n4.每次挑战后英雄血量将会保留，下场战斗中该血量将会被继承。\n5.每天凌晨0点重置，所有关卡刷新为未通关状态，英雄回复满血状态。\n二、好友助阵\n1.每人每天可派遣1个英雄，派遣出的英雄可被好友借用，被好友借用后可获得奖励。\n2.每人每天可最多借用3个英雄，借用英雄可用于远征，多个借用的英雄不可同时上阵，当场战斗胜利后，借用的英雄不可继续使用。\n3.仅可借用战力低于己方最高战力英雄150%战力的英雄。\n三、自动扫荡\n1.当日所选难度与前一天难度相同时，且前一天通关关卡超过10关时，将会根据前一天通关关卡为玩家进行扫荡，扫荡关卡数为前一天通关关卡数减去10，扫荡后自动挑战。\n2.自动扫荡的关卡无需玩家挑战，直接战斗胜利，并获得相关奖励。"},
	["red_war_ratio"] = {val=100, desc="红点显示战力（千分比），玩家有英雄战力≥关卡战力*该常量，远征显示红点"},
	["regression_level"] = {val=10, desc="远征自动扫荡倒退关卡数"},
	["easy_mapping_power"] = {val=1500000, desc="应运于普通模式，与玩家历史最高战力做比较，取较小值，依据较小值匹配关卡难度"},
	["difficult_mapping_power"] = {val=2200000, desc="应运于困难模式，与玩家历史最高战力做比较，取较小值，依据较小值匹配关卡难度"},
	["hell_mapping_power"] = {val=3500000, desc="应运于地狱模式，与玩家历史最高战力做比较，取较小值，依据较小值匹配关卡难度"}
}
Config.ExpeditionData.data_const_fun = function(key)
	local data=Config.ExpeditionData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExpeditionData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------sign_info_start-------------------
Config.ExpeditionData.data_sign_info_length = 20
Config.ExpeditionData.data_sign_info = {
	[1] = {id=1, floor=1, type=1, pos={{180,613}}},
	[2] = {id=2, floor=2, type=1, pos={{301,665}}},
	[3] = {id=3, floor=3, type=1, pos={{387,766}}},
	[4] = {id=4, floor=0, type=2, pos={{482,844}}},
	[5] = {id=5, floor=4, type=1, pos={{577,805}}},
	[6] = {id=6, floor=5, type=1, pos={{656,752}}},
	[7] = {id=7, floor=6, type=1, pos={{729,678}}},
	[8] = {id=8, floor=0, type=2, pos={{827,654}}},
	[9] = {id=9, floor=7, type=1, pos={{701,625}}},
	[10] = {id=10, floor=8, type=1, pos={{579,582}}},
	[11] = {id=11, floor=9, type=1, pos={{460,532}}},
	[12] = {id=12, floor=0, type=2, pos={{352,482}}},
	[13] = {id=13, floor=10, type=1, pos={{432,391}}},
	[14] = {id=14, floor=11, type=1, pos={{560,344}}},
	[15] = {id=15, floor=12, type=1, pos={{700,403}}},
	[16] = {id=16, floor=0, type=2, pos={{866,445}}},
	[17] = {id=17, floor=13, type=1, pos={{837,328}}},
	[18] = {id=18, floor=14, type=1, pos={{766,259}}},
	[19] = {id=19, floor=15, type=1, pos={{673,226}}},
	[20] = {id=20, floor=0, type=2, pos={{525,201}}}
}
Config.ExpeditionData.data_sign_info_fun = function(key)
	local data=Config.ExpeditionData.data_sign_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExpeditionData.data_sign_info['..key..'])not found') return
	end
	return data
end
-- -------------------sign_info_end---------------------


-- -------------------sign_reward_start-------------------
Config.ExpeditionData.data_sign_reward_length = 3
Config.ExpeditionData.data_sign_reward = {
	[1] = {id=1, items={{1,1410000},{25,2025}}, desc="txt_cn_heroexpedit_1", power=1, is_jump=0},
	[2] = {id=2, items={{1,1940000},{25,2650}}, desc="txt_cn_heroexpedit_2", power=1000000, is_jump=1},
	[3] = {id=3, items={{1,2525000},{25,3525}}, desc="txt_cn_heroexpedit_3", power=1800000, is_jump=1}
}
Config.ExpeditionData.data_sign_reward_fun = function(key)
	local data=Config.ExpeditionData.data_sign_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ExpeditionData.data_sign_reward['..key..'])not found') return
	end
	return data
end
-- -------------------sign_reward_end---------------------
