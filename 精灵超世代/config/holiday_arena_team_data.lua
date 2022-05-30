----------------------------------------------------
-- 此文件由数据工具生成
-- 组队竞技场--holiday_arena_team_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayArenaTeamData = Config.HolidayArenaTeamData or {}

-- -------------------const_start-------------------
Config.HolidayArenaTeamData.data_const_length = 17
Config.HolidayArenaTeamData.data_const = {
	["team_open_lev"] = {key='team_open_lev', val=55, desc="开启等级"},
	["team_open_day"] = {key='team_open_day', val=8, desc="开启天数"},
	["team_level_disparity"] = {key='team_level_disparity', val=1, desc="匹配最大段位差距"},
	["team_service_time"] = {key='team_service_time', val={2020,4,8,0,0,0}, desc="最晚开服要求时间"},
	["team_people_number"] = {key='team_people_number', val=300, desc="排行榜初始化数据采集人属（竞技场排行榜）"},
	["team_battle_free"] = {key='team_battle_free', val=2, desc="每日免费挑战次数"},
	["team_battle_pay"] = {key='team_battle_pay', val=2, desc="每日付费挑战次数"},
	["team_recommend_player"] = {key='team_recommend_player', val={{800,1200},{500,1500},{100,2000},{1,99999}}, desc="推荐玩家战力区间"},
	["team_integral_min"] = {key='team_integral_min', val=1200, desc="仅依靠排名搜索最小积分"},
	["team_opponent_time"] = {key='team_opponent_time', val=60, desc="自动进入战斗倒计时（秒）"},
	["team_refresh_num"] = {key='team_refresh_num', val=3, desc="每日刷新次数"},
	["team_score_constant1"] = {key='team_score_constant1', val=500, desc="得分公式系数1"},
	["team_score_constant2"] = {key='team_score_constant2', val=40, desc="得分公式系数2"},
	["team_deduction_constant1"] = {key='team_deduction_constant1', val=200, desc="扣分公式系数1"},
	["team_deduction_constant2"] = {key='team_deduction_constant2', val=40, desc="扣分公式系数2"},
	["team_deduction_basics"] = {key='team_deduction_basics', val=5, desc="扣分基础分"},
	["team_effectiveness_coefficient"] = {key='team_effectiveness_coefficient', val=1, desc="标准战力修正系数"}
}
Config.HolidayArenaTeamData.data_const_fun = function(key)
	local data=Config.HolidayArenaTeamData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayArenaTeamData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------elite_level_start-------------------
Config.HolidayArenaTeamData.data_elite_level_length = 12
Config.HolidayArenaTeamData.data_elite_level = {
	[1] = {lev=1, name="黑铁", need_score=1000, base_add_score=17, icon="amp_icon_1"},
	[2] = {lev=2, name="青铜Ⅰ", need_score=1030, base_add_score=17, icon="amp_icon_2"},
	[3] = {lev=3, name="青铜Ⅱ", need_score=1060, base_add_score=18, icon="amp_icon_2"},
	[4] = {lev=4, name="白银Ⅰ", need_score=1110, base_add_score=19, icon="amp_icon_3"},
	[5] = {lev=5, name="白银Ⅱ", need_score=1160, base_add_score=20, icon="amp_icon_3"},
	[6] = {lev=6, name="黄金Ⅰ", need_score=1230, base_add_score=21, icon="amp_icon_4"},
	[7] = {lev=7, name="黄金Ⅱ", need_score=1300, base_add_score=22, icon="amp_icon_4"},
	[8] = {lev=8, name="铂金Ⅰ", need_score=1390, base_add_score=23, icon="amp_icon_5"},
	[9] = {lev=9, name="铂金Ⅱ", need_score=1480, base_add_score=25, icon="amp_icon_5"},
	[10] = {lev=10, name="钻石Ⅰ", need_score=1580, base_add_score=27, icon="amp_icon_6"},
	[11] = {lev=11, name="钻石Ⅱ", need_score=1680, base_add_score=29, icon="amp_icon_6"},
	[12] = {lev=12, name="大师", need_score=1800, base_add_score=30, icon="amp_icon_7"}
}
Config.HolidayArenaTeamData.data_elite_level_fun = function(key)
	local data=Config.HolidayArenaTeamData.data_elite_level[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayArenaTeamData.data_elite_level['..key..'])not found') return
	end
	return data
end
-- -------------------elite_level_end---------------------


-- -------------------elite_award_start-------------------
Config.HolidayArenaTeamData.data_elite_award_length = 11
Config.HolidayArenaTeamData.data_elite_award = {
	[2] = {lev=2, award={{80267,450},{1,100000}}},
	[3] = {lev=3, award={{80267,550},{1,150000}}},
	[4] = {lev=4, award={{80267,650},{1,200000}}},
	[5] = {lev=5, award={{80267,750},{1,250000}}},
	[6] = {lev=6, award={{80267,850},{1,350000}}},
	[7] = {lev=7, award={{80267,950},{1,450000}}},
	[8] = {lev=8, award={{80267,1050},{1,600000}}},
	[9] = {lev=9, award={{80267,1150},{1,750000}}},
	[10] = {lev=10, award={{80267,1250},{1,1000000}}},
	[11] = {lev=11, award={{80267,1350},{1,1250000}}},
	[12] = {lev=12, award={{80267,1500},{1,1500000}}}
}
Config.HolidayArenaTeamData.data_elite_award_fun = function(key)
	local data=Config.HolidayArenaTeamData.data_elite_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayArenaTeamData.data_elite_award['..key..'])not found') return
	end
	return data
end
-- -------------------elite_award_end---------------------


-- -------------------rank_reward_start-------------------
Config.HolidayArenaTeamData.data_rank_reward_length = 7
Config.HolidayArenaTeamData.data_rank_reward = {
	[1] = {min=1, max=1, items={{80267,4500},{60131,1}}},
	[2] = {min=2, max=3, items={{80267,3750},{60132,1}}},
	[4] = {min=4, max=10, items={{80267,3000},{60133,1}}},
	[11] = {min=11, max=20, items={{80267,2500}}},
	[21] = {min=21, max=50, items={{80267,2000}}},
	[51] = {min=51, max=100, items={{80267,1750}}},
	[101] = {min=101, max=999, items={{80267,1500}}}
}
Config.HolidayArenaTeamData.data_rank_reward_fun = function(key)
	local data=Config.HolidayArenaTeamData.data_rank_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayArenaTeamData.data_rank_reward['..key..'])not found') return
	end
	return data
end
-- -------------------rank_reward_end---------------------


-- -------------------explain_start-------------------
Config.HolidayArenaTeamData.data_explain_length = 3
Config.HolidayArenaTeamData.data_explain = {
	[1] = {id=1, title="基础规则", desc="1.本玩法需玩家到达<div fontcolor=289b14>55级</div>才可参加\n2.所有玩家将会依据其在其所在服的竞技场排名获得其在本玩法的初始段位\n3.玩家至多可邀请<div fontcolor=289b14>1名</div>其它玩家以组成队伍进行挑战\n4.被匹配到的队友不会进行积分计算，且不会扣除其挑战次数\n5.在队伍匹配或挑战中时，不可退出队伍\n6.排行榜只会在某玩家积分结算时才会发生变化，且可能存在延迟显示\n7.本玩法获得的积分道具所对应的兑换商店限时开启，在活动关闭后，商店会持续开放<div fontcolor=289b14>1天</div>，请及时兑换\n8.主界面与排行榜的玩家战力显示会有延迟，但匹配中的战力为真实战力\n9.每位玩家每天有<div fontcolor=289b14>2次</div>免费挑战次数与<div fontcolor=289b14>2次</div>付费挑战次数"},
	[2] = {id=2, title="战斗规则", desc="1.本玩法采用<div fontcolor=289b14>三局两胜制</div>\n2.自动进入战斗将会以队长最后一次保存的顺序进入战斗\n3.当回合数打满后，按照双方总伤害量判定胜负，<div fontcolor=289b14>伤害高</div>的一方胜利"},
	[3] = {id=3, title="奖励规则", desc="1.玩家需要至少挑战<div fontcolor=289b14>1次</div>才能进入排行榜以及获得奖励\n2.在玩法结束时，排行榜奖励将通过邮件发放给所有玩家\n3.未领取的奖励将会通过邮件补发"}
}
Config.HolidayArenaTeamData.data_explain_fun = function(key)
	local data=Config.HolidayArenaTeamData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayArenaTeamData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------battle_pay_start-------------------
Config.HolidayArenaTeamData.data_battle_pay_length = 2
Config.HolidayArenaTeamData.data_battle_pay = {
	[1] = {count=1, expend={{3,100}}},
	[2] = {count=2, expend={{3,200}}}
}
Config.HolidayArenaTeamData.data_battle_pay_fun = function(key)
	local data=Config.HolidayArenaTeamData.data_battle_pay[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayArenaTeamData.data_battle_pay['..key..'])not found') return
	end
	return data
end
-- -------------------battle_pay_end---------------------
