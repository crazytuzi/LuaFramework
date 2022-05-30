----------------------------------------------------
-- 此文件由数据工具生成
-- 开学季副本--holiday_term_begins_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayTermBeginsData = Config.HolidayTermBeginsData or {}

-- -------------------const_start-------------------
Config.HolidayTermBeginsData.data_const_length = 16
Config.HolidayTermBeginsData.data_const = {
	["action_time"] = {val=1, desc="10月17日-10月30日"},
	["action_pre_reward"] = {val={{80234,1},{29905,1},{35,1},{25,1}}, desc="初始界面活动奖励"},
	["action_num_espensive"] = {val={3,100}, desc="关卡次数购买钻石价格"},
	["free_fight_count"] = {val=2, desc="关卡每日免费挑战次数"},
	["limit_buy_count"] = {val=6, desc="关卡每日限购次数"},
	["entrance_exam_cost"] = {val={3,100}, desc="准考证消耗"},
	["boss_fight_cost"] = {val={80233,1}, desc="boss挑战消耗"},
	["collection_quantity"] = {val=113750, desc="收集数量上限"},
	["damage"] = {val=5, desc="收集buff倍率"},
	["buff_name"] = {val='dam', desc="收集buff"},
	["collection_buff"] = {val=3080, desc="收集伤害buff图标"},
	["collection_damage_tips"] = {val=1, desc="提交满分试卷可以增长进度，进度每增长1%为全服玩家提供5%伤害"},
	["boss_descreption"] = {val=1, desc="1.开学季活动每七天为一轮，后两天开放世界boss挑战。\n2.玩家可以在世界boss页面提交收集到的满分试卷，提交满分试卷会增长进度条的进度，根据玩家提交的数量会在世界boss阶段为所有玩家提供伤害加成。\n3.提交满分试卷，参与并击败世界boss均可获得丰厚奖励。\n4.挑战世界boss需要消耗“准考证”，当道具数量不足时，可以直接消耗钻石进行挑战。\n5.当玩家参与人数不足100时，按照参与人数100来发放排名奖励。\n6.boss挑战于9月11日23:30结束，请合理安排时间。"},
	["level_descreption"] = {val=1, desc="1.开学季活动每七天为一轮，后两天开放世界boss挑战。\n2.关卡挑战中，挑战任何一个关卡无论是否失败，都会消耗一次挑战次数\n3.每次挑战关卡结束后，关卡怪物的剩余血量将被保留至下一次挑战。\n4.通关每一个关卡都可以获得数量不等的满分试卷。\n5.玩家可以在世界boss页面提交收集到的满分试卷，提交满分试卷会增长进度条的进度，根据玩家提交的数量会在世界boss阶段为所有玩家提供伤害加成。\n6.玩家每天拥有2次免费挑战的机会，也可以使用钻石购买挑战次数，日限6次。\n7.关卡挑战于2019年9月11日23:30结束，请合理安排时间。"},
	["paper_item_id"] = {val=80232, desc="试卷id"},
	["ticket_item_id"] = {val=80233, desc="准考证id"}
}
Config.HolidayTermBeginsData.data_const_fun = function(key)
	local data=Config.HolidayTermBeginsData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayTermBeginsData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------round_info_start-------------------
Config.HolidayTermBeginsData.data_round_info_length = 2
Config.HolidayTermBeginsData.data_round_info = {
	[1] = {round=1, start_time={2019,9,5,0,0,0}, end_time={2019,9,11,23,59,59}, unit_round=1, boss_round=1, action_time="9月5日-9月11日"},
	[2] = {round=2, start_time={2019,9,12,0,0,0}, end_time={2019,9,18,23,59,59}, unit_round=2, boss_round=2, action_time="9月12日-9月18日"}
}
Config.HolidayTermBeginsData.data_round_info_fun = function(key)
	local data=Config.HolidayTermBeginsData.data_round_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayTermBeginsData.data_round_info['..key..'])not found') return
	end
	return data
end
-- -------------------round_info_end---------------------


-- -------------------chapter_info_start-------------------
Config.HolidayTermBeginsData.data_chapter_info_length = 2
Config.HolidayTermBeginsData.data_chapter_info = {
	[1] = {
		[1] = {
			[1] = {unit_round=1, type=1, order_id=1, order_name="意志训练", unit_id=89307, hit_award={{80233,1},{80232,10},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=143287, order_res="1"},
			[2] = {unit_round=1, type=1, order_id=2, order_name="素质训练", unit_id=89308, hit_award={{80233,1},{80232,11},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=146899, order_res="2"},
			[3] = {unit_round=1, type=1, order_id=3, order_name="体能训练", unit_id=89309, hit_award={{80233,1},{80232,12},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=149466, order_res="3"},
			[4] = {unit_round=1, type=1, order_id=4, order_name="医疗训练", unit_id=89310, hit_award={{80233,1},{80232,13},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=152756, order_res="4"},
			[5] = {unit_round=1, type=1, order_id=5, order_name="智慧训练", unit_id=89311, hit_award={{80233,1},{80232,14},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=155421, order_res="5"},
		},
		[2] = {
			[6] = {unit_round=1, type=2, order_id=6, order_name="意志训练", unit_id=89312, hit_award={{80233,1},{80232,20},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=202850, order_res="1"},
			[7] = {unit_round=1, type=2, order_id=7, order_name="素质训练", unit_id=89313, hit_award={{80233,1},{80232,21},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=204850, order_res="2"},
			[8] = {unit_round=1, type=2, order_id=8, order_name="体能训练", unit_id=89314, hit_award={{80233,1},{80232,22},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=206950, order_res="3"},
			[9] = {unit_round=1, type=2, order_id=9, order_name="医疗训练", unit_id=89315, hit_award={{80233,1},{80232,23},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=208430, order_res="4"},
			[10] = {unit_round=1, type=2, order_id=10, order_name="智慧训练", unit_id=89316, hit_award={{80233,1},{80232,24},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=210774, order_res="5"},
		},
		[3] = {
			[11] = {unit_round=1, type=3, order_id=11, order_name="意志训练", unit_id=89317, hit_award={{80233,1},{80232,30},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=362794, order_res="1"},
			[12] = {unit_round=1, type=3, order_id=12, order_name="素质训练", unit_id=89318, hit_award={{80233,1},{80232,31},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=395776, order_res="2"},
			[13] = {unit_round=1, type=3, order_id=13, order_name="体能训练", unit_id=89319, hit_award={{80233,1},{80232,32},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=494720, order_res="3"},
			[14] = {unit_round=1, type=3, order_id=14, order_name="医疗训练", unit_id=89320, hit_award={{80233,1},{80232,33},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=593317, order_res="4"},
			[15] = {unit_round=1, type=3, order_id=15, order_name="智慧训练", unit_id=89321, hit_award={{80233,1},{80232,34},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=809069, order_res="5"},
		},
		[4] = {
			[16] = {unit_round=1, type=4, order_id=16, order_name="意志训练", unit_id=89322, hit_award={{80233,1},{80232,40},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=1364208, order_res="1"},
			[17] = {unit_round=1, type=4, order_id=17, order_name="素质训练", unit_id=89323, hit_award={{80233,1},{80232,41},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=1488227, order_res="2"},
			[18] = {unit_round=1, type=4, order_id=18, order_name="体能训练", unit_id=89324, hit_award={{80233,1},{80232,42},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=1533972, order_res="3"},
			[19] = {unit_round=1, type=4, order_id=19, order_name="医疗训练", unit_id=89325, hit_award={{80233,1},{80232,43},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=2267611, order_res="4"},
			[20] = {unit_round=1, type=4, order_id=20, order_name="智慧训练", unit_id=89326, hit_award={{80233,1},{80232,44},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=2748339, order_res="5"},
		},
	},
	[2] = {
		[1] = {
			[1] = {unit_round=2, type=1, order_id=1, order_name="意志训练", unit_id=89359, hit_award={{80233,1},{80232,10},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=143287, order_res="1"},
			[2] = {unit_round=2, type=1, order_id=2, order_name="素质训练", unit_id=89360, hit_award={{80233,1},{80232,11},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=146899, order_res="2"},
			[3] = {unit_round=2, type=1, order_id=3, order_name="体能训练", unit_id=89361, hit_award={{80233,1},{80232,12},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=149466, order_res="3"},
			[4] = {unit_round=2, type=1, order_id=4, order_name="医疗训练", unit_id=89362, hit_award={{80233,1},{80232,13},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=152756, order_res="4"},
			[5] = {unit_round=2, type=1, order_id=5, order_name="智慧训练", unit_id=89363, hit_award={{80233,1},{80232,14},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=155421, order_res="5"},
		},
		[2] = {
			[6] = {unit_round=2, type=2, order_id=6, order_name="意志训练", unit_id=89364, hit_award={{80233,1},{80232,20},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=202850, order_res="1"},
			[7] = {unit_round=2, type=2, order_id=7, order_name="素质训练", unit_id=89365, hit_award={{80233,1},{80232,21},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=204850, order_res="2"},
			[8] = {unit_round=2, type=2, order_id=8, order_name="体能训练", unit_id=89366, hit_award={{80233,1},{80232,22},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=206950, order_res="3"},
			[9] = {unit_round=2, type=2, order_id=9, order_name="医疗训练", unit_id=89367, hit_award={{80233,1},{80232,23},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=208430, order_res="4"},
			[10] = {unit_round=2, type=2, order_id=10, order_name="智慧训练", unit_id=89368, hit_award={{80233,1},{80232,24},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=210774, order_res="5"},
		},
		[3] = {
			[11] = {unit_round=2, type=3, order_id=11, order_name="意志训练", unit_id=89369, hit_award={{80233,1},{80232,30},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=362794, order_res="1"},
			[12] = {unit_round=2, type=3, order_id=12, order_name="素质训练", unit_id=89370, hit_award={{80233,1},{80232,31},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=395776, order_res="2"},
			[13] = {unit_round=2, type=3, order_id=13, order_name="体能训练", unit_id=89371, hit_award={{80233,1},{80232,32},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=494720, order_res="3"},
			[14] = {unit_round=2, type=3, order_id=14, order_name="医疗训练", unit_id=89372, hit_award={{80233,1},{80232,33},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=593317, order_res="4"},
			[15] = {unit_round=2, type=3, order_id=15, order_name="智慧训练", unit_id=89373, hit_award={{80233,1},{80232,34},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=809069, order_res="5"},
		},
		[4] = {
			[16] = {unit_round=2, type=4, order_id=16, order_name="意志训练", unit_id=89374, hit_award={{80233,1},{80232,40},{25,100}}, add_skill_decs={"敌方被控制时会增加100%所受伤害","光系伤害提升100%"}, power=1364208, order_res="1"},
			[17] = {unit_round=2, type=4, order_id=17, order_name="素质训练", unit_id=89375, hit_award={{80233,1},{80232,41},{25,100}}, add_skill_decs={"生命高于90%时伤害增加150%","每回合受到最大生命8%的伤害","暗系伤害提升100%"}, power=1488227, order_res="2"},
			[18] = {unit_round=2, type=4, order_id=18, order_name="体能训练", unit_id=89376, hit_award={{80233,1},{80232,42},{25,100}}, add_skill_decs={"战士伤害提升100%","火系伤害提升100%"}, power=1533972, order_res="3"},
			[19] = {unit_round=2, type=4, order_id=19, order_name="医疗训练", unit_id=89377, hit_award={{80233,1},{80232,43},{25,100}}, add_skill_decs={"我方治疗效果造成等量伤害","风系伤害提升100%"}, power=2267611, order_res="4"},
			[20] = {unit_round=2, type=4, order_id=20, order_name="智慧训练", unit_id=89378, hit_award={{80233,1},{80232,44},{25,100}}, add_skill_decs={"法师伤害提升100%","水系伤害提升100%"}, power=2748339, order_res="5"},
		},
	},
}
-- -------------------chapter_info_end---------------------


-- -------------------max_chapter_id_start-------------------
Config.HolidayTermBeginsData.data_max_chapter_id_length = 2
Config.HolidayTermBeginsData.data_max_chapter_id = {
	[1] = 20,
	[2] = 20,
}
-- -------------------max_chapter_id_end---------------------


-- -------------------max_diff_start-------------------
Config.HolidayTermBeginsData.data_max_diff_length = 2
Config.HolidayTermBeginsData.data_max_diff = {
	[1] = 4,
	[2] = 4,
}
-- -------------------max_diff_end---------------------


-- -------------------boss_info_start-------------------
Config.HolidayTermBeginsData.data_boss_info_length = 2
Config.HolidayTermBeginsData.data_boss_info = {
	[1] = {
		[1] = {boss_round=1, boss_id=1, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[2] = {boss_round=1, boss_id=2, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[3] = {boss_round=1, boss_id=3, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[4] = {boss_round=1, boss_id=4, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[5] = {boss_round=1, boss_id=5, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[6] = {boss_round=1, boss_id=6, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[7] = {boss_round=1, boss_id=7, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[8] = {boss_round=1, boss_id=8, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[9] = {boss_round=1, boss_id=9, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[10] = {boss_round=1, boss_id=10, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[11] = {boss_round=1, boss_id=11, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[12] = {boss_round=1, boss_id=12, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[13] = {boss_round=1, boss_id=13, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[14] = {boss_round=1, boss_id=14, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[15] = {boss_round=1, boss_id=15, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[16] = {boss_round=1, boss_id=16, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[17] = {boss_round=1, boss_id=17, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[18] = {boss_round=1, boss_id=18, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[19] = {boss_round=1, boss_id=19, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[20] = {boss_round=1, boss_id=20, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[21] = {boss_round=1, boss_id=21, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[22] = {boss_round=1, boss_id=22, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[23] = {boss_round=1, boss_id=23, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[24] = {boss_round=1, boss_id=24, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[25] = {boss_round=1, boss_id=25, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[26] = {boss_round=1, boss_id=26, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[27] = {boss_round=1, boss_id=27, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[28] = {boss_round=1, boss_id=28, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[29] = {boss_round=1, boss_id=29, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[30] = {boss_round=1, boss_id=30, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
		[31] = {boss_round=1, boss_id=31, unit_id=89327, hit_award={{80234,8}}, boss_name="开学试炼·炎魔之王"},
	},
	[2] = {
		[1] = {boss_round=2, boss_id=1, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[2] = {boss_round=2, boss_id=2, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[3] = {boss_round=2, boss_id=3, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[4] = {boss_round=2, boss_id=4, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[5] = {boss_round=2, boss_id=5, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[6] = {boss_round=2, boss_id=6, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[7] = {boss_round=2, boss_id=7, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[8] = {boss_round=2, boss_id=8, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[9] = {boss_round=2, boss_id=9, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[10] = {boss_round=2, boss_id=10, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[11] = {boss_round=2, boss_id=11, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[12] = {boss_round=2, boss_id=12, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[13] = {boss_round=2, boss_id=13, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[14] = {boss_round=2, boss_id=14, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[15] = {boss_round=2, boss_id=15, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[16] = {boss_round=2, boss_id=16, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[17] = {boss_round=2, boss_id=17, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[18] = {boss_round=2, boss_id=18, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[19] = {boss_round=2, boss_id=19, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[20] = {boss_round=2, boss_id=20, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[21] = {boss_round=2, boss_id=21, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[22] = {boss_round=2, boss_id=22, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[23] = {boss_round=2, boss_id=23, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[24] = {boss_round=2, boss_id=24, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[25] = {boss_round=2, boss_id=25, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[26] = {boss_round=2, boss_id=26, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[27] = {boss_round=2, boss_id=27, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[28] = {boss_round=2, boss_id=28, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[29] = {boss_round=2, boss_id=29, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[30] = {boss_round=2, boss_id=30, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
		[31] = {boss_round=2, boss_id=31, unit_id=89358, hit_award={{80234,8}}, boss_name="开学试炼·阿努比斯"},
	},
}
-- -------------------boss_info_end---------------------


-- -------------------cellect_reward_info_start-------------------
Config.HolidayTermBeginsData.data_cellect_reward_info_length = 3
Config.HolidayTermBeginsData.data_cellect_reward_info = {
{id=1, count=170, award={{80234,1},{35,1},{25,1000}}, res="termbeginsreward_02"},
{id=2, count=330, award={{80234,3},{35,1},{25,2000}}, res="termbeginsreward_03"},
{id=3, count=490, award={{80234,5},{35,2},{25,5000}}, res="termbeginsreward_04"}
}
-- -------------------cellect_reward_info_end---------------------


-- -------------------rank_reward_start-------------------
Config.HolidayTermBeginsData.data_rank_reward_length = 7
Config.HolidayTermBeginsData.data_rank_reward = {
{rank1=0, rank2=1, award={{3,1000},{35,10},{50016,1}}},
{rank1=1, rank2=5, award={{3,800},{35,8},{50017,1}}},
{rank1=5, rank2=10, award={{3,500},{35,5},{50018,1}}},
{rank1=10, rank2=20, award={{3,200},{35,3}}},
{rank1=20, rank2=50, award={{3,150},{35,2}}},
{rank1=50, rank2=80, award={{3,100},{35,1}}},
{rank1=80, rank2=100, award={{3,50}}}
}
-- -------------------rank_reward_end---------------------


-- -------------------explain_start-------------------
Config.HolidayTermBeginsData.data_explain_length = 0
Config.HolidayTermBeginsData.data_explain = {

}
Config.HolidayTermBeginsData.data_explain_fun = function(key)
	local data=Config.HolidayTermBeginsData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayTermBeginsData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
