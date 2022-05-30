----------------------------------------------------
-- 此文件由数据工具生成
-- 新版活动BOSS--holiday_boss_new_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayBossNewData = Config.HolidayBossNewData or {}

-- -------------------const_start-------------------
Config.HolidayBossNewData.data_const_length = 9
Config.HolidayBossNewData.data_const = {
	["action_time"] = {val=1, desc="2月10日~3月8日"},
	["action_pre_reward"] = {val={{3,1},{29905,1},{10403,1},{25,1}}, desc="活动界面奖励预览"},
	["fight_max_count"] = {val=2, desc="显示挑战次数上限"},
	["start_fight_count"] = {val=2, desc="初始挑战次数"},
	["game_rule1"] = {val=1, desc="活动周期\n    试炼之境每周重置前都会进行一次更新，更新后关卡内容会发生变化。请尽量在一周内攻略完所有关卡\n\n英雄锁定\n    在挑战任何关卡时，不再消耗出战的英雄的使用次数。\n\n关卡特征\n    每次挑战结束，关卡怪物的剩余生命值将被保留至下一次挑战\n    每个关卡有对应的效果加成，搭配合适的英雄进行挑战，可以事半功倍哦~\n\n奖励获取\n    通关奖励\n        每次通过关卡，会随机掉落一些奖励，各个阶段的掉落均有不同\n    结算奖励\n        每通关一个阶段，会使结算奖励升级，在周期结算时可获取到上一期的结算奖励（奖励通过邮件发放）\n         如果提前通关当期所有关卡，可立即获取结算奖励\n\n难度升降\n    首次进入难度匹配\n        首次参与活动的玩家会根据用户当前最高战力进行难度匹配，后续将不再进行匹配\n    升降级区\n        每周会根据关卡分为降级，保级，升级3个区域\n        完全通关对应的区域可解锁更好的结算奖励\n        通关升级区后，下一期的难度会有所上升（达到上限将不再提升），对应的奖励也会获得更好\n        若用户一周内玩家不参加或没有通关降级区，则下一期会降级（多周未参与最多下降一级）\n\n参与次数\n    每日免费挑战2次，每日0点会重置免费次数和购买次数\n    只要参与战斗，无论胜负，均会消耗一次挑战次数\n"},
	["action_num_espensive"] = {val=100, desc="次数购买钻石价格"},
	["partner_num"] = {val=4, desc="英雄限制次数"},
	["partner_num_up"] = {val=8, desc="UP英雄限制次数"},
	["fight_buy_max_count"] = {val=2, desc="购买次数"}
}
Config.HolidayBossNewData.data_const_fun = function(key)
	local data=Config.HolidayBossNewData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayBossNewData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------round_list_start-------------------
Config.HolidayBossNewData.data_round_list_length = 4
Config.HolidayBossNewData.data_round_list = {
	[1] = {unit_round=1},
	[2] = {unit_round=2},
	[3] = {unit_round=3},
	[4] = {unit_round=4}
}
Config.HolidayBossNewData.data_round_list_fun = function(key)
	local data=Config.HolidayBossNewData.data_round_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayBossNewData.data_round_list['..key..'])not found') return
	end
	return data
end
-- -------------------round_list_end---------------------


-- -------------------lev_reward_list_start-------------------
Config.HolidayBossNewData.data_lev_reward_list_length = 10
Config.HolidayBossNewData.data_lev_reward_list = {
	[1] = {
		[1] = {sort_id=1, order_id=5, reward={{3,150},{39035,3},{25,1000}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,200},{39035,4},{25,1200}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,250},{39035,5},{25,1400}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[2] = {
		[1] = {sort_id=1, order_id=5, reward={{3,165},{39035,4},{25,1200}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,220},{39035,5},{25,1400}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,275},{39035,6},{25,1600}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[3] = {
		[1] = {sort_id=1, order_id=5, reward={{3,180},{39035,5},{25,1400}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,240},{39035,6},{25,1600}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,305},{39035,7},{25,1800}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[4] = {
		[1] = {sort_id=1, order_id=5, reward={{3,200},{39035,6},{25,1600}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,265},{39035,7},{25,1800}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,335},{39035,8},{25,2000}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[5] = {
		[1] = {sort_id=1, order_id=5, reward={{3,220},{39035,7},{25,1800}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,295},{39035,8},{25,2000}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,365},{39035,9},{25,2200}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[6] = {
		[1] = {sort_id=1, order_id=5, reward={{3,240},{39035,8},{25,2000}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,320},{39035,9},{25,2200}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,405},{39035,10},{25,2400}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[7] = {
		[1] = {sort_id=1, order_id=5, reward={{3,260},{39035,9},{25,2200}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,340},{39035,10},{25,2400}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,440},{39035,11},{25,2600}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[8] = {
		[1] = {sort_id=1, order_id=5, reward={{3,280},{39035,10},{25,2400}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,360},{39035,11},{25,2600}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,460},{39035,12},{25,2800}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[9] = {
		[1] = {sort_id=1, order_id=5, reward={{3,300},{39035,11},{25,2600}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,380},{39035,12},{25,2800}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,480},{39035,13},{25,3000}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
	[10] = {
		[1] = {sort_id=1, order_id=5, reward={{3,320},{39035,12},{25,2800}}, show_reward={{29,1},{25,1}}},
		[2] = {sort_id=2, order_id=10, reward={{3,400},{39035,13},{25,3000}}, show_reward={{29,1},{37001,1},{25,1}}},
		[3] = {sort_id=3, order_id=15, reward={{3,500},{39035,14},{25,3200}}, show_reward={{29,1},{10403,1},{37001,1},{25,1}}},
	},
}
-- -------------------lev_reward_list_end---------------------


-- -------------------change_boss_list_start-------------------
Config.HolidayBossNewData.data_change_boss_list_length = 4
Config.HolidayBossNewData.data_change_boss_list = {
	[1] = {
		[1] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=10504, name="输出试炼", master_lev=100, power=102444},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=10509, name="输出试炼", master_lev=100, power=102444},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=50503, name="输出试炼", master_lev=100, power=102444},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=30501, name="输出试炼", master_lev=100, power=102444},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=20504, name="BOSS关", master_lev=120, power=164972},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20505, name="生命试炼", master_lev=115, power=161866},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20509, name="生命试炼", master_lev=115, power=161469},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=50502, name="生命试炼", master_lev=115, power=161469},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20508, name="生命试炼", master_lev=115, power=162263},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=40502, name="BOSS关", master_lev=140, power=204509},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=6, head_id=10505, name="控制试炼", master_lev=135, power=195620},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=6, head_id=50505, name="控制试炼", master_lev=135, power=194652},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=6, head_id=10503, name="控制试炼", master_lev=135, power=193324},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=6, head_id=10510, name="控制试炼", master_lev=135, power=194652},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=7, head_id=30509, name="BOSS关", master_lev=160, power=315568},
			},
		},
		[2] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=10504, name="输出试炼", master_lev=140, power=199864},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=10509, name="输出试炼", master_lev=140, power=199864},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=50503, name="输出试炼", master_lev=140, power=199864},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=30501, name="输出试炼", master_lev=140, power=199864},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=7, head_id=20504, name="BOSS关", master_lev=160, power=312122},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20505, name="生命试炼", master_lev=155, power=310115},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20509, name="生命试炼", master_lev=155, power=309255},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=50502, name="生命试炼", master_lev=155, power=309255},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20508, name="生命试炼", master_lev=155, power=310975},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=7, head_id=40502, name="BOSS关", master_lev=180, power=474289},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=7, head_id=10505, name="控制试炼", master_lev=175, power=457972},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=7, head_id=50505, name="控制试炼", master_lev=175, power=455150},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=7, head_id=10503, name="控制试炼", master_lev=175, power=451852},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=7, head_id=10510, name="控制试炼", master_lev=175, power=455150},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=8, head_id=30509, name="BOSS关", master_lev=200, power=702165},
			},
		},
		[3] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=10504, name="输出试炼", master_lev=180, power=463425},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=10509, name="输出试炼", master_lev=180, power=463425},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=50503, name="输出试炼", master_lev=180, power=463425},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=30501, name="输出试炼", master_lev=180, power=463425},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=20504, name="BOSS关", master_lev=200, power=694622},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=20505, name="生命试炼", master_lev=195, power=693150},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=20509, name="生命试炼", master_lev=195, power=690870},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=50502, name="生命试炼", master_lev=195, power=690870},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=20508, name="生命试炼", master_lev=195, power=695430},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=9, head_id=40502, name="BOSS关", master_lev=220, power=1121191},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=9, head_id=10505, name="控制试炼", master_lev=215, power=1089899},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=9, head_id=50505, name="控制试炼", master_lev=215, power=1082249},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=9, head_id=10503, name="控制试炼", master_lev=215, power=1075115},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=9, head_id=10510, name="控制试炼", master_lev=215, power=1082249},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=30509, name="BOSS关", master_lev=240, power=1247973},
			},
		},
		[4] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=10504, name="输出试炼", master_lev=220, power=1099497},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=10509, name="输出试炼", master_lev=220, power=1099497},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=50503, name="输出试炼", master_lev=220, power=1099497},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=30501, name="输出试炼", master_lev=220, power=1099497},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=20504, name="BOSS关", master_lev=240, power=1235711},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20505, name="生命试炼", master_lev=235, power=1234727},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20509, name="生命试炼", master_lev=235, power=1230408},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=50502, name="生命试炼", master_lev=235, power=1230408},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20508, name="生命试炼", master_lev=235, power=1239046},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=40502, name="BOSS关", master_lev=260, power=1556669},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=10505, name="控制试炼", master_lev=255, power=1365663},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=50505, name="控制试炼", master_lev=255, power=1356043},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=10503, name="控制试炼", master_lev=255, power=1347291},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=10510, name="控制试炼", master_lev=255, power=1356043},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=30509, name="BOSS关", master_lev=280, power=2000442},
			},
		},
		[5] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10504, name="输出试炼", master_lev=255, power=1348047},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10509, name="输出试炼", master_lev=255, power=1348047},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=50503, name="输出试炼", master_lev=255, power=1348047},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=30501, name="输出试炼", master_lev=255, power=1348047},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=20504, name="BOSS关", master_lev=275, power=1871677},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20505, name="生命试炼", master_lev=270, power=1787853},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20509, name="生命试炼", master_lev=270, power=1789192},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=50502, name="生命试炼", master_lev=270, power=1789192},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20508, name="生命试炼", master_lev=270, power=1786514},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=40502, name="BOSS关", master_lev=295, power=2365809},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=10505, name="控制试炼", master_lev=290, power=2226611},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=50505, name="控制试炼", master_lev=290, power=2229181},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=10503, name="控制试炼", master_lev=290, power=2241595},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=10510, name="控制试炼", master_lev=290, power=2229181},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30509, name="BOSS关", master_lev=315, power=2813908},
			},
		},
		[6] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10504, name="输出试炼", master_lev=290, power=2220951},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10509, name="输出试炼", master_lev=290, power=2220951},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=50503, name="输出试炼", master_lev=290, power=2220951},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=30501, name="输出试炼", master_lev=290, power=2220951},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=20504, name="BOSS关", master_lev=310, power=2686654},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20505, name="生命试炼", master_lev=305, power=2596856},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20509, name="生命试炼", master_lev=305, power=2598099},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50502, name="生命试炼", master_lev=305, power=2598099},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="生命试炼", master_lev=305, power=2595613},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40502, name="BOSS关", master_lev=330, power=3174816},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=10505, name="控制试炼", master_lev=325, power=3036139},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50505, name="控制试炼", master_lev=325, power=3038521},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=10503, name="控制试炼", master_lev=325, power=3058819},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=10510, name="控制试炼", master_lev=325, power=3038521},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30509, name="BOSS关", master_lev=350, power=3627369},
			},
		},
		[7] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=325, power=3035887},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=325, power=3035887},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50503, name="输出试炼", master_lev=325, power=3035887},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=325, power=3035887},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=20504, name="BOSS关", master_lev=345, power=3501627},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20505, name="生命试炼", master_lev=340, power=3405912},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20509, name="生命试炼", master_lev=340, power=3407063},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50502, name="生命试炼", master_lev=340, power=3407063},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="生命试炼", master_lev=340, power=3404761},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40502, name="BOSS关", master_lev=365, power=3983874},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=10505, name="控制试炼", master_lev=360, power=3845672},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50505, name="控制试炼", master_lev=360, power=3847864},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=10503, name="控制试炼", master_lev=360, power=3876016},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=10510, name="控制试炼", master_lev=360, power=3847864},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30509, name="BOSS关", master_lev=385, power=4440694},
			},
		},
		[8] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=360, power=3850858},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=360, power=3850858},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50503, name="输出试炼", master_lev=360, power=3850858},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=360, power=3850858},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=20504, name="BOSS关", master_lev=380, power=4316155},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20505, name="生命试炼", master_lev=375, power=4215015},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20509, name="生命试炼", master_lev=375, power=4216070},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50502, name="生命试炼", master_lev=375, power=4216070},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="生命试炼", master_lev=375, power=4213960},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40502, name="BOSS关", master_lev=400, power=4792995},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=10505, name="控制试炼", master_lev=395, power=4655153},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50505, name="控制试炼", master_lev=395, power=4657157},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=10503, name="控制试炼", master_lev=395, power=4693141},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=10510, name="控制试炼", master_lev=395, power=4657157},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30509, name="BOSS关", master_lev=420, power=5254525},
			},
		},
		[9] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=395, power=4665711},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=395, power=4665711},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50503, name="输出试炼", master_lev=395, power=4665711},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=395, power=4665711},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=20504, name="BOSS关", master_lev=415, power=5131818},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20505, name="生命试炼", master_lev=410, power=5024081},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20509, name="生命试炼", master_lev=410, power=5025044},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50502, name="生命试炼", master_lev=410, power=5025044},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="生命试炼", master_lev=410, power=5023118},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40502, name="BOSS关", master_lev=435, power=5601946},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=10505, name="控制试炼", master_lev=430, power=5465125},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50505, name="控制试炼", master_lev=430, power=5466943},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=10503, name="控制试炼", master_lev=430, power=5510785},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=10510, name="控制试炼", master_lev=430, power=5466943},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30509, name="BOSS关", master_lev=455, power=6068377},
			},
		},
		[10] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=430, power=5481373},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=430, power=5481373},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50503, name="输出试炼", master_lev=430, power=5481373},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=430, power=5481373},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=20504, name="BOSS关", master_lev=450, power=5947542},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20505, name="生命试炼", master_lev=445, power=5833211},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20509, name="生命试炼", master_lev=445, power=5834079},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50502, name="生命试炼", master_lev=445, power=5834079},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="生命试炼", master_lev=445, power=5832343},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40502, name="BOSS关", master_lev=470, power=6411043},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=10505, name="控制试炼", master_lev=465, power=6275080},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50505, name="控制试炼", master_lev=465, power=6276708},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=10503, name="控制试炼", master_lev=465, power=6328402},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=10510, name="控制试炼", master_lev=465, power=6276708},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30509, name="BOSS关", master_lev=490, power=6882279},
			},
		},
	},
	[2] = {
		[1] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=10509, name="输出试炼", master_lev=100, power=102444},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=30503, name="输出试炼", master_lev=100, power=102716},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=30501, name="输出试炼", master_lev=100, power=102444},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=50507, name="输出试炼", master_lev=100, power=102444},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=30507, name="BOSS关", master_lev=120, power=165548},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20501, name="生命试炼", master_lev=115, power=161469},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30504, name="生命试炼", master_lev=115, power=161469},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30508, name="生命试炼", master_lev=115, power=161469},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=10505, name="生命试炼", master_lev=115, power=161866},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20507, name="BOSS关", master_lev=140, power=204011},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=6, head_id=20505, name="控制试炼", master_lev=135, power=194652},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=6, head_id=20508, name="控制试炼", master_lev=135, power=196284},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=6, head_id=40504, name="控制试炼", master_lev=135, power=195620},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=6, head_id=30506, name="控制试炼", master_lev=135, power=193988},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=7, head_id=50504, name="BOSS关", master_lev=160, power=316694},
			},
		},
		[2] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=10509, name="输出试炼", master_lev=140, power=199864},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=30503, name="输出试炼", master_lev=140, power=200551},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=30501, name="输出试炼", master_lev=140, power=199864},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=50507, name="输出试炼", master_lev=140, power=199864},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=7, head_id=30507, name="BOSS关", master_lev=160, power=313248},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20501, name="生命试炼", master_lev=155, power=309255},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30504, name="生命试炼", master_lev=155, power=309255},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30508, name="生命试炼", master_lev=155, power=309255},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=10505, name="生命试炼", master_lev=155, power=310115},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=7, head_id=20507, name="BOSS关", master_lev=180, power=472841},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=7, head_id=20505, name="控制试炼", master_lev=175, power=455150},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=7, head_id=20508, name="控制试炼", master_lev=175, power=459621},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=7, head_id=40504, name="控制试炼", master_lev=175, power=457972},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=7, head_id=30506, name="控制试炼", master_lev=175, power=453501},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=8, head_id=50504, name="BOSS关", master_lev=200, power=704646},
			},
		},
		[3] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=10509, name="输出试炼", master_lev=180, power=463425},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=30503, name="输出试炼", master_lev=180, power=465120},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=30501, name="输出试炼", master_lev=180, power=463425},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=50507, name="输出试炼", master_lev=180, power=463425},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=30507, name="BOSS关", master_lev=200, power=697103},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=20501, name="生命试炼", master_lev=195, power=690870},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=30504, name="生命试炼", master_lev=195, power=690870},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=30508, name="生命试炼", master_lev=195, power=690870},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=10505, name="生命试炼", master_lev=195, power=693150},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=9, head_id=20507, name="BOSS关", master_lev=220, power=1117289},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=9, head_id=20505, name="控制试炼", master_lev=215, power=1082249},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=9, head_id=20508, name="控制试炼", master_lev=215, power=1093466},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=9, head_id=40504, name="控制试炼", master_lev=215, power=1089899},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=9, head_id=30506, name="控制试炼", master_lev=215, power=1078682},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=50504, name="BOSS关", master_lev=240, power=1252021},
			},
		},
		[4] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=10509, name="输出试炼", master_lev=220, power=1099497},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=30503, name="输出试炼", master_lev=220, power=1103153},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=30501, name="输出试炼", master_lev=220, power=1099497},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=50507, name="输出试炼", master_lev=220, power=1099497},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30507, name="BOSS关", master_lev=240, power=1239759},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20501, name="生命试炼", master_lev=235, power=1230408},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30504, name="生命试炼", master_lev=235, power=1230408},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30508, name="生命试炼", master_lev=235, power=1230408},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=10505, name="生命试炼", master_lev=235, power=1234727},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20507, name="BOSS关", master_lev=260, power=1558036},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=20505, name="控制试炼", master_lev=255, power=1356043},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=20508, name="控制试炼", master_lev=255, power=1370039},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=40504, name="控制试炼", master_lev=255, power=1365663},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=30506, name="控制试炼", master_lev=255, power=1351667},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=50504, name="BOSS关", master_lev=280, power=1995350},
			},
		},
		[5] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=10509, name="输出试炼", master_lev=255, power=1348047},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30503, name="输出试炼", master_lev=255, power=1352423},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30501, name="输出试炼", master_lev=255, power=1348047},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=50507, name="输出试炼", master_lev=255, power=1348047},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30507, name="BOSS关", master_lev=275, power=1867148},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20501, name="生命试炼", master_lev=270, power=1789192},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30504, name="生命试炼", master_lev=270, power=1789192},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30508, name="生命试炼", master_lev=270, power=1789192},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=10505, name="生命试炼", master_lev=270, power=1787853},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20507, name="BOSS关", master_lev=295, power=2367081},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=20505, name="控制试炼", master_lev=290, power=2229181},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=20508, name="控制试炼", master_lev=290, power=2220404},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=40504, name="控制试炼", master_lev=290, power=2226611},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=30506, name="控制试炼", master_lev=290, power=2235388},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=50504, name="BOSS关", master_lev=315, power=2804890},
			},
		},
		[6] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=10509, name="输出试炼", master_lev=290, power=2220951},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30503, name="输出试炼", master_lev=290, power=2214744},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30501, name="输出试炼", master_lev=290, power=2220951},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=50507, name="输出试炼", master_lev=290, power=2220951},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30507, name="BOSS关", master_lev=310, power=2678201},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=305, power=2598099},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30504, name="生命试炼", master_lev=305, power=2598099},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30508, name="生命试炼", master_lev=305, power=2598099},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=305, power=2596856},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="BOSS关", master_lev=330, power=3175994},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20505, name="控制试炼", master_lev=325, power=3038521},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=20508, name="控制试炼", master_lev=325, power=3025990},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40504, name="控制试炼", master_lev=325, power=3036139},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=30506, name="控制试炼", master_lev=325, power=3048670},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=50504, name="BOSS关", master_lev=350, power=3614425},
			},
		},
		[7] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=325, power=3035887},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30503, name="输出试炼", master_lev=325, power=3025738},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=325, power=3035887},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50507, name="输出试炼", master_lev=325, power=3035887},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30507, name="BOSS关", master_lev=345, power=3489233},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=340, power=3407063},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30504, name="生命试炼", master_lev=340, power=3407063},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30508, name="生命试炼", master_lev=340, power=3407063},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=340, power=3405912},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="BOSS关", master_lev=365, power=3984956},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20505, name="控制试炼", master_lev=360, power=3847864},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=20508, name="控制试炼", master_lev=360, power=3831596},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40504, name="控制试炼", master_lev=360, power=3845672},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=30506, name="控制试炼", master_lev=360, power=3861940},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=50504, name="BOSS关", master_lev=385, power=4423828},
			},
		},
		[8] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=360, power=3850858},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30503, name="输出试炼", master_lev=360, power=3836782},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=360, power=3850858},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50507, name="输出试炼", master_lev=360, power=3850858},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30507, name="BOSS关", master_lev=380, power=4299840},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=375, power=4216070},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30504, name="生命试炼", master_lev=375, power=4216070},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30508, name="生命试炼", master_lev=375, power=4216070},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=375, power=4215015},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="BOSS关", master_lev=400, power=4793985},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20505, name="控制试炼", master_lev=395, power=4657157},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=20508, name="控制试炼", master_lev=395, power=4637161},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40504, name="控制试炼", master_lev=395, power=4655153},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=30506, name="控制试炼", master_lev=395, power=4675149},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=50504, name="BOSS关", master_lev=420, power=5233715},
			},
		},
		[9] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=395, power=4665711},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30503, name="输出试炼", master_lev=395, power=4647719},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=395, power=4665711},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50507, name="输出试炼", master_lev=395, power=4665711},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30507, name="BOSS关", master_lev=415, power=5111577},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=410, power=5025044},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30504, name="生命试炼", master_lev=410, power=5025044},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30508, name="生命试炼", master_lev=410, power=5025044},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=410, power=5024081},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="BOSS关", master_lev=435, power=5602839},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20505, name="控制试炼", master_lev=430, power=5466943},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=20508, name="控制试炼", master_lev=430, power=5443204},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40504, name="控制试炼", master_lev=430, power=5465125},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=30506, name="控制试炼", master_lev=430, power=5488864},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=50504, name="BOSS关", master_lev=455, power=6043642},
			},
		},
		[10] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10509, name="输出试炼", master_lev=430, power=5481373},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30503, name="输出试炼", master_lev=430, power=5459452},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30501, name="输出试炼", master_lev=430, power=5481373},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50507, name="输出试炼", master_lev=430, power=5481373},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30507, name="BOSS关", master_lev=450, power=5923373},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=445, power=5834079},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30504, name="生命试炼", master_lev=445, power=5834079},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30508, name="生命试炼", master_lev=445, power=5834079},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=445, power=5833211},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="BOSS关", master_lev=470, power=6411842},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20505, name="控制试炼", master_lev=465, power=6276708},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=20508, name="控制试炼", master_lev=465, power=6249233},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40504, name="控制试炼", master_lev=465, power=6275080},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=30506, name="控制试炼", master_lev=465, power=6302555},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=50504, name="BOSS关", master_lev=490, power=6853631},
			},
		},
	},
	[3] = {
		[1] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=10506, name="输出试炼", master_lev=100, power=102444},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=10501, name="输出试炼", master_lev=100, power=102444},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=40508, name="输出试炼", master_lev=100, power=102444},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=5, head_id=30502, name="输出试炼", master_lev=100, power=102444},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=50507, name="BOSS关", master_lev=120, power=165548},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=40504, name="生命试炼", master_lev=115, power=161072},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=10505, name="生命试炼", master_lev=115, power=161866},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20501, name="生命试炼", master_lev=115, power=162263},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30506, name="生命试炼", master_lev=115, power=161469},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30509, name="BOSS关", master_lev=140, power=203513},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=6, head_id=20502, name="控制试炼", master_lev=135, power=193988},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=6, head_id=40503, name="控制试炼", master_lev=135, power=193988},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=6, head_id=50508, name="控制试炼", master_lev=135, power=194956},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=6, head_id=20507, name="控制试炼", master_lev=135, power=194652},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=7, head_id=30508, name="BOSS关", master_lev=160, power=316694},
			},
		},
		[2] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=10506, name="输出试炼", master_lev=140, power=199864},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=10501, name="输出试炼", master_lev=140, power=199864},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=40508, name="输出试炼", master_lev=140, power=199864},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=6, head_id=30502, name="输出试炼", master_lev=140, power=199864},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=7, head_id=50507, name="BOSS关", master_lev=160, power=313248},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=40504, name="生命试炼", master_lev=155, power=308395},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=10505, name="生命试炼", master_lev=155, power=310115},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20501, name="生命试炼", master_lev=155, power=310975},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=30506, name="生命试炼", master_lev=155, power=309255},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=7, head_id=30509, name="BOSS关", master_lev=180, power=471393},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=7, head_id=20502, name="控制试炼", master_lev=175, power=453501},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=7, head_id=40503, name="控制试炼", master_lev=175, power=453501},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=7, head_id=50508, name="控制试炼", master_lev=175, power=456323},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=7, head_id=20507, name="控制试炼", master_lev=175, power=455150},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=8, head_id=30508, name="BOSS关", master_lev=200, power=704646},
			},
		},
		[3] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=10506, name="输出试炼", master_lev=180, power=463425},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=10501, name="输出试炼", master_lev=180, power=463425},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=40508, name="输出试炼", master_lev=180, power=463425},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=8, head_id=30502, name="输出试炼", master_lev=180, power=463425},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=50507, name="BOSS关", master_lev=200, power=697103},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=40504, name="生命试炼", master_lev=195, power=688590},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=10505, name="生命试炼", master_lev=195, power=693150},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=20501, name="生命试炼", master_lev=195, power=695430},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=30506, name="生命试炼", master_lev=195, power=690870},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=9, head_id=30509, name="BOSS关", master_lev=220, power=1113387},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=9, head_id=20502, name="控制试炼", master_lev=215, power=1078682},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=9, head_id=40503, name="控制试炼", master_lev=215, power=1078682},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=9, head_id=50508, name="控制试炼", master_lev=215, power=1086332},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=9, head_id=20507, name="控制试炼", master_lev=215, power=1082249},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=30508, name="BOSS关", master_lev=240, power=1252021},
			},
		},
		[4] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=10506, name="输出试炼", master_lev=220, power=1099497},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=10501, name="输出试炼", master_lev=220, power=1099497},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=40508, name="输出试炼", master_lev=220, power=1099497},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=9, head_id=30502, name="输出试炼", master_lev=220, power=1099497},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=50507, name="BOSS关", master_lev=240, power=1239759},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=40504, name="生命试炼", master_lev=235, power=1226089},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=10505, name="生命试炼", master_lev=235, power=1234727},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20501, name="生命试炼", master_lev=235, power=1239046},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30506, name="生命试炼", master_lev=235, power=1230408},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30509, name="BOSS关", master_lev=260, power=1559403},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=20502, name="控制试炼", master_lev=255, power=1351667},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=40503, name="控制试炼", master_lev=255, power=1351667},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=50508, name="控制试炼", master_lev=255, power=1361287},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=20507, name="控制试炼", master_lev=255, power=1356043},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=30508, name="BOSS关", master_lev=280, power=1995350},
			},
		},
		[5] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10506, name="输出试炼", master_lev=255, power=1348047},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10501, name="输出试炼", master_lev=255, power=1348047},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=40508, name="输出试炼", master_lev=255, power=1348047},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=30502, name="输出试炼", master_lev=255, power=1348047},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=50507, name="BOSS关", master_lev=275, power=1867148},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=40504, name="生命试炼", master_lev=270, power=1790531},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=10505, name="生命试炼", master_lev=270, power=1787853},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20501, name="生命试炼", master_lev=270, power=1786514},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30506, name="生命试炼", master_lev=270, power=1789192},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=30509, name="BOSS关", master_lev=295, power=2368353},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=20502, name="控制试炼", master_lev=290, power=2235388},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=40503, name="控制试炼", master_lev=290, power=2235388},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=50508, name="控制试炼", master_lev=290, power=2232818},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=20507, name="控制试炼", master_lev=290, power=2229181},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30508, name="BOSS关", master_lev=315, power=2804890},
			},
		},
		[6] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10506, name="输出试炼", master_lev=290, power=2220951},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=10501, name="输出试炼", master_lev=290, power=2220951},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=40508, name="输出试炼", master_lev=290, power=2220951},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=10, head_id=30502, name="输出试炼", master_lev=290, power=2220951},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50507, name="BOSS关", master_lev=310, power=2678201},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40504, name="生命试炼", master_lev=305, power=2599342},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=305, power=2596856},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=305, power=2595613},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30506, name="生命试炼", master_lev=305, power=2598099},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30509, name="BOSS关", master_lev=330, power=3177172},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20502, name="控制试炼", master_lev=325, power=3048670},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=40503, name="控制试炼", master_lev=325, power=3048670},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=50508, name="控制试炼", master_lev=325, power=3046288},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20507, name="控制试炼", master_lev=325, power=3038521},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30508, name="BOSS关", master_lev=350, power=3614425},
			},
		},
		[7] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10506, name="输出试炼", master_lev=325, power=3035887},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10501, name="输出试炼", master_lev=325, power=3035887},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=40508, name="输出试炼", master_lev=325, power=3035887},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=325, power=3035887},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50507, name="BOSS关", master_lev=345, power=3489233},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40504, name="生命试炼", master_lev=340, power=3408214},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=340, power=3405912},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=340, power=3404761},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30506, name="生命试炼", master_lev=340, power=3407063},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30509, name="BOSS关", master_lev=365, power=3986038},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20502, name="控制试炼", master_lev=360, power=3861940},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=40503, name="控制试炼", master_lev=360, power=3861940},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=50508, name="控制试炼", master_lev=360, power=3859748},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20507, name="控制试炼", master_lev=360, power=3847864},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30508, name="BOSS关", master_lev=385, power=4423828},
			},
		},
		[8] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10506, name="输出试炼", master_lev=360, power=3850858},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10501, name="输出试炼", master_lev=360, power=3850858},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=40508, name="输出试炼", master_lev=360, power=3850858},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=360, power=3850858},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50507, name="BOSS关", master_lev=380, power=4299840},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40504, name="生命试炼", master_lev=375, power=4217125},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=375, power=4215015},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=375, power=4213960},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30506, name="生命试炼", master_lev=375, power=4216070},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30509, name="BOSS关", master_lev=400, power=4794975},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20502, name="控制试炼", master_lev=395, power=4675149},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=40503, name="控制试炼", master_lev=395, power=4675149},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=50508, name="控制试炼", master_lev=395, power=4673145},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20507, name="控制试炼", master_lev=395, power=4657157},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30508, name="BOSS关", master_lev=420, power=5233715},
			},
		},
		[9] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10506, name="输出试炼", master_lev=395, power=4665711},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10501, name="输出试炼", master_lev=395, power=4665711},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=40508, name="输出试炼", master_lev=395, power=4665711},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=395, power=4665711},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50507, name="BOSS关", master_lev=415, power=5111577},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40504, name="生命试炼", master_lev=410, power=5026007},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=410, power=5024081},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=410, power=5023118},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30506, name="生命试炼", master_lev=410, power=5025044},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30509, name="BOSS关", master_lev=435, power=5603732},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20502, name="控制试炼", master_lev=430, power=5488864},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=40503, name="控制试炼", master_lev=430, power=5488864},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=50508, name="控制试炼", master_lev=430, power=5487046},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20507, name="控制试炼", master_lev=430, power=5466943},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30508, name="BOSS关", master_lev=455, power=6043642},
			},
		},
		[10] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10506, name="输出试炼", master_lev=430, power=5481373},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=10501, name="输出试炼", master_lev=430, power=5481373},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=40508, name="输出试炼", master_lev=430, power=5481373},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=430, power=5481373},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方法术伤害提升100%"}, star=11, head_id=50507, name="BOSS关", master_lev=450, power=5923373},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40504, name="生命试炼", master_lev=445, power=5834947},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=10505, name="生命试炼", master_lev=445, power=5833211},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20501, name="生命试炼", master_lev=445, power=5832343},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30506, name="生命试炼", master_lev=445, power=5834079},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=30509, name="BOSS关", master_lev=470, power=6412641},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=20502, name="控制试炼", master_lev=465, power=6302555},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=40503, name="控制试炼", master_lev=465, power=6302555},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=50508, name="控制试炼", master_lev=465, power=6300927},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20507, name="控制试炼", master_lev=465, power=6276708},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=30508, name="BOSS关", master_lev=490, power=6853631},
			},
		},
	},
	[4] = {
		[1] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=20504, name="输出试炼", master_lev=100, power=102172},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=10510, name="输出试炼", master_lev=100, power=102444},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=30502, name="输出试炼", master_lev=100, power=102716},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=5, head_id=10504, name="输出试炼", master_lev=100, power=102444},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=50503, name="BOSS关", master_lev=120, power=164972},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=40503, name="生命试炼", master_lev=115, power=161866},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=50504, name="生命试炼", master_lev=115, power=161469},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=50508, name="生命试炼", master_lev=115, power=162263},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20507, name="生命试炼", master_lev=115, power=161469},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20508, name="BOSS关", master_lev=140, power=205007},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=6, head_id=30504, name="控制试炼", master_lev=135, power=195620},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=6, head_id=50502, name="控制试炼", master_lev=135, power=195620},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=6, head_id=40502, name="控制试炼", master_lev=135, power=194652},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=6, head_id=20509, name="控制试炼", master_lev=135, power=194956},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=7, head_id=10502, name="BOSS关", master_lev=160, power=314924},
			},
		},
		[2] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=20504, name="输出试炼", master_lev=140, power=199177},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=10510, name="输出试炼", master_lev=140, power=199864},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=30502, name="输出试炼", master_lev=140, power=200551},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=6, head_id=10504, name="输出试炼", master_lev=140, power=199864},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=7, head_id=50503, name="BOSS关", master_lev=160, power=312122},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=40503, name="生命试炼", master_lev=155, power=310115},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=50504, name="生命试炼", master_lev=155, power=309255},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=50508, name="生命试炼", master_lev=155, power=310975},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=6, head_id=20507, name="生命试炼", master_lev=155, power=309255},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=7, head_id=20508, name="BOSS关", master_lev=180, power=475737},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=7, head_id=30504, name="控制试炼", master_lev=175, power=457972},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=7, head_id=50502, name="控制试炼", master_lev=175, power=457972},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=7, head_id=40502, name="控制试炼", master_lev=175, power=455150},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=7, head_id=20509, name="控制试炼", master_lev=175, power=456323},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=8, head_id=10502, name="BOSS关", master_lev=200, power=699980},
			},
		},
		[3] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=20504, name="输出试炼", master_lev=180, power=461730},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=10510, name="输出试炼", master_lev=180, power=463425},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=30502, name="输出试炼", master_lev=180, power=465120},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=8, head_id=10504, name="输出试炼", master_lev=180, power=463425},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=50503, name="BOSS关", master_lev=200, power=694622},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=40503, name="生命试炼", master_lev=195, power=693150},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=50504, name="生命试炼", master_lev=195, power=690870},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=50508, name="生命试炼", master_lev=195, power=695430},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=8, head_id=20507, name="生命试炼", master_lev=195, power=690870},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=9, head_id=20508, name="BOSS关", master_lev=220, power=1125093},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=9, head_id=30504, name="控制试炼", master_lev=215, power=1089899},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=9, head_id=50502, name="控制试炼", master_lev=215, power=1089899},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=9, head_id=40502, name="控制试炼", master_lev=215, power=1082249},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=9, head_id=20509, name="控制试炼", master_lev=215, power=1086332},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=10502, name="BOSS关", master_lev=240, power=1243225},
			},
		},
		[4] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=20504, name="输出试炼", master_lev=220, power=1095841},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=10510, name="输出试炼", master_lev=220, power=1099497},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=30502, name="输出试炼", master_lev=220, power=1103153},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=9, head_id=10504, name="输出试炼", master_lev=220, power=1099497},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=50503, name="BOSS关", master_lev=240, power=1235711},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=40503, name="生命试炼", master_lev=235, power=1234727},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=50504, name="生命试炼", master_lev=235, power=1230408},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=50508, name="生命试炼", master_lev=235, power=1239046},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20507, name="生命试炼", master_lev=235, power=1230408},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20508, name="BOSS关", master_lev=260, power=1555302},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=30504, name="控制试炼", master_lev=255, power=1365663},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=50502, name="控制试炼", master_lev=255, power=1365663},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=40502, name="控制试炼", master_lev=255, power=1356043},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=20509, name="控制试炼", master_lev=255, power=1361287},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=10, head_id=10502, name="BOSS关", master_lev=280, power=1997974},
			},
		},
		[5] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=20504, name="输出试炼", master_lev=255, power=1343671},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=10510, name="输出试炼", master_lev=255, power=1348047},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30502, name="输出试炼", master_lev=255, power=1352423},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=10504, name="输出试炼", master_lev=255, power=1348047},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=50503, name="BOSS关", master_lev=275, power=1871677},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=40503, name="生命试炼", master_lev=270, power=1787853},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=50504, name="生命试炼", master_lev=270, power=1789192},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=50508, name="生命试炼", master_lev=270, power=1786514},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20507, name="生命试炼", master_lev=270, power=1789192},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=10, head_id=20508, name="BOSS关", master_lev=295, power=2364537},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=10, head_id=30504, name="控制试炼", master_lev=290, power=2226611},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=10, head_id=50502, name="控制试炼", master_lev=290, power=2226611},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=10, head_id=40502, name="控制试炼", master_lev=290, power=2229181},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=10, head_id=20509, name="控制试炼", master_lev=290, power=2232818},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=10502, name="BOSS关", master_lev=315, power=2807324},
			},
		},
		[6] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=20504, name="输出试炼", master_lev=290, power=2227158},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=10510, name="输出试炼", master_lev=290, power=2220951},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=30502, name="输出试炼", master_lev=290, power=2214744},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=10, head_id=10504, name="输出试炼", master_lev=290, power=2220951},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50503, name="BOSS关", master_lev=310, power=2686654},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40503, name="生命试炼", master_lev=305, power=2596856},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50504, name="生命试炼", master_lev=305, power=2598099},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50508, name="生命试炼", master_lev=305, power=2595613},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="生命试炼", master_lev=305, power=2598099},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="BOSS关", master_lev=330, power=3173638},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=30504, name="控制试炼", master_lev=325, power=3036139},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50502, name="控制试炼", master_lev=325, power=3036139},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40502, name="控制试炼", master_lev=325, power=3038521},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20509, name="控制试炼", master_lev=325, power=3046288},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=10502, name="BOSS关", master_lev=350, power=3616671},
			},
		},
		[7] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=20504, name="输出试炼", master_lev=325, power=3046036},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10510, name="输出试炼", master_lev=325, power=3035887},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=325, power=3025738},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=325, power=3035887},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50503, name="BOSS关", master_lev=345, power=3501627},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40503, name="生命试炼", master_lev=340, power=3405912},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50504, name="生命试炼", master_lev=340, power=3407063},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50508, name="生命试炼", master_lev=340, power=3404761},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="生命试炼", master_lev=340, power=3407063},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="BOSS关", master_lev=365, power=3982792},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=30504, name="控制试炼", master_lev=360, power=3845672},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50502, name="控制试炼", master_lev=360, power=3845672},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40502, name="控制试炼", master_lev=360, power=3847864},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20509, name="控制试炼", master_lev=360, power=3859748},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=10502, name="BOSS关", master_lev=385, power=4425888},
			},
		},
		[8] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=20504, name="输出试炼", master_lev=360, power=3864934},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10510, name="输出试炼", master_lev=360, power=3850858},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=360, power=3836782},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=360, power=3850858},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50503, name="BOSS关", master_lev=380, power=4316155},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40503, name="生命试炼", master_lev=375, power=4215015},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50504, name="生命试炼", master_lev=375, power=4216070},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50508, name="生命试炼", master_lev=375, power=4213960},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="生命试炼", master_lev=375, power=4216070},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="BOSS关", master_lev=400, power=4792005},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=30504, name="控制试炼", master_lev=395, power=4655153},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50502, name="控制试炼", master_lev=395, power=4655153},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40502, name="控制试炼", master_lev=395, power=4657157},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20509, name="控制试炼", master_lev=395, power=4673145},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=10502, name="BOSS关", master_lev=420, power=5235587},
			},
		},
		[9] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=20504, name="输出试炼", master_lev=395, power=4683703},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10510, name="输出试炼", master_lev=395, power=4665711},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=395, power=4647719},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=395, power=4665711},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50503, name="BOSS关", master_lev=415, power=5131818},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40503, name="生命试炼", master_lev=410, power=5024081},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50504, name="生命试炼", master_lev=410, power=5025044},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50508, name="生命试炼", master_lev=410, power=5023118},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="生命试炼", master_lev=410, power=5025044},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="BOSS关", master_lev=435, power=5601053},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=30504, name="控制试炼", master_lev=430, power=5465125},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50502, name="控制试炼", master_lev=430, power=5465125},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40502, name="控制试炼", master_lev=430, power=5466943},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20509, name="控制试炼", master_lev=430, power=5487046},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=10502, name="BOSS关", master_lev=455, power=6045324},
			},
		},
		[10] = {
			[1] = {
				[1] = {order_type=1, sort_id=1, order_id=1, add_skill_decs={"我方风系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=20504, name="输出试炼", master_lev=430, power=5503294},
				[2] = {order_type=1, sort_id=2, order_id=2, add_skill_decs={"我方水系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10510, name="输出试炼", master_lev=430, power=5481373},
				[3] = {order_type=1, sort_id=3, order_id=3, add_skill_decs={"我方火系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=30502, name="输出试炼", master_lev=430, power=5459452},
				[4] = {order_type=1, sort_id=4, order_id=4, add_skill_decs={"我方暗系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=10504, name="输出试炼", master_lev=430, power=5481373},
				[5] = {order_type=1, sort_id=5, order_id=5, add_skill_decs={"我方光系英雄伤害提升100%","我方物理伤害提升100%"}, star=11, head_id=50503, name="BOSS关", master_lev=450, power=5947542},
			},
			[2] = {
				[6] = {order_type=2, sort_id=1, order_id=6, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=40503, name="生命试炼", master_lev=445, power=5833211},
				[7] = {order_type=2, sort_id=2, order_id=7, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50504, name="生命试炼", master_lev=445, power=5834079},
				[8] = {order_type=2, sort_id=3, order_id=8, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=50508, name="生命试炼", master_lev=445, power=5832343},
				[9] = {order_type=2, sort_id=4, order_id=9, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20507, name="生命试炼", master_lev=445, power=5834079},
				[10] = {order_type=2, sort_id=5, order_id=10, add_skill_decs={"回合结束会受到8%最大生命的伤害","生命值高于90%时，伤害增加150%"}, star=11, head_id=20508, name="BOSS关", master_lev=470, power=6410244},
			},
			[3] = {
				[11] = {order_type=3, sort_id=1, order_id=11, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方风系英雄伤害提升100%"}, star=11, head_id=30504, name="控制试炼", master_lev=465, power=6275080},
				[12] = {order_type=3, sort_id=2, order_id=12, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方水系英雄伤害提升100%"}, star=11, head_id=50502, name="控制试炼", master_lev=465, power=6275080},
				[13] = {order_type=3, sort_id=3, order_id=13, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方火系英雄伤害提升100%"}, star=11, head_id=40502, name="控制试炼", master_lev=465, power=6276708},
				[14] = {order_type=3, sort_id=4, order_id=14, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方暗系英雄伤害提升100%"}, star=11, head_id=20509, name="控制试炼", master_lev=465, power=6300927},
				[15] = {order_type=3, sort_id=5, order_id=15, add_skill_decs={"敌人被控制时，会增加100%受到伤害","我方光系英雄伤害提升100%"}, star=11, head_id=10502, name="BOSS关", master_lev=490, power=6855121},
			},
		},
	},
}
-- -------------------change_boss_list_end---------------------


-- -------------------explain_start-------------------
Config.HolidayBossNewData.data_explain_length = 6
Config.HolidayBossNewData.data_explain = {
	[1] = {id=1, title="活动周期", desc="试炼之境<div fontcolor=#c23f35>每周重置都会进行一次更新</div>，更新后关卡内容会发生变化。请尽量在一周内攻略完所有关卡"},
	[2] = {id=2, title="挑战注意", desc="在挑战任何关卡时，无论是否成功，<div fontcolor=#c23f35>都会消耗今日可挑战次数</div>。"},
	[3] = {id=3, title="关卡特征", desc="每次挑战结束，关卡怪物的剩余生命值将被保留至下一次挑战\n每个关卡有对应的效果加成，<div fontcolor=#c23f35>搭配合适的英雄进行挑战，可以事半功倍哦~</div>"},
	[4] = {id=4, title="奖励获取", desc="通关奖励\n每次通过关卡，<div fontcolor=#c23f35>会随机掉落一些奖励</div>，各个阶段的掉落均有不同\n \n结算奖励\n每通关一个阶段，会使<div fontcolor=#c23f35>结算奖励升级</div>，在周期结算时可获取到上一期的结算奖励（奖励通过邮件发放）\n如果提前通关当期所有关卡，可立即获取结算奖励"},
	[5] = {id=5, title="难度升降", desc="首次进入难度匹配\n首次参与活动的玩家会根据用户<div fontcolor=#c23f35>当前最高战力</div>进行难度匹配，后续将不再进行匹配（单一大轮内）\n \n升降级区\n每周会根据关卡分为<div fontcolor=#c23f35>降级，保级，升级</div>3个区域\n完全通关对应的区域可解锁更好的结算奖励\n通关升级区后，下一期的难度会有所上升（达到上限将不再提升），对应的奖励也会获得更好\n若用户一周内玩家不参加或没有通关降级区，则下一期会降级（多周未参与最多下降一级）"},
	[6] = {id=6, title="参与次数", desc="每日可以<div fontcolor=#c23f35>免费挑战2次</div>，每日0点会重置挑战次数和购买次数\n\n一旦发起挑战，无论胜负，均会消耗一次挑战次数"}
}
Config.HolidayBossNewData.data_explain_fun = function(key)
	local data=Config.HolidayBossNewData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayBossNewData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------
