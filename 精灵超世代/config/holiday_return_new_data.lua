----------------------------------------------------
-- 此文件由数据工具生成
-- 回归活动配置数据--holiday_return_new_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayReturnNewData = Config.HolidayReturnNewData or {}

-- -------------------constant_start-------------------
Config.HolidayReturnNewData.data_constant_length = 22
Config.HolidayReturnNewData.data_constant = {
	["free_draw_time"] = {label='free_draw_time', val=1, desc="活动期间免费抽奖次数"},
	["draw_item_cost"] = {label='draw_item_cost', val={{10416,100}}, desc="一次抽奖道具消耗"},
	["draw_item_value"] = {label='draw_item_value', val={{3,1}}, desc="抽奖道具价值"},
	["red_item_id"] = {label='red_item_id', val=10417, desc="红包道具id"},
	["max_day_get_num"] = {label='max_day_get_num', val=5, desc="每日可领红包最大数"},
	["broadcast_num"] = {label='broadcast_num', val=30, desc="传闻显示数量"},
	["max_get_num"] = {label='max_get_num', val=8, desc="红包最大可领人数"},
	["effect_time"] = {label='effect_time', val=24, desc="红包有效时间（小时）"},
	["red_packet_cond"] = {label='red_packet_cond', val={{'open_day',17},{'lev',10}}, desc="领红包玩家条件"},
	["exchange_item_id"] = {label='exchange_item_id', val=10418, desc="兑换商店道具id"},
	["exchange_item_day_limit_num"] = {label='exchange_item_day_limit_num', val=100, desc="兑换道具每日获取上限"},
	["tips_1"] = {label='tips_1', val=1, desc="1、活动期间，累计进行100次祈愿，必定可获得奖池包括【英雄祈愿自选礼盒】在内的<div fontcolor=#ef3a3a></div>全部物品！\n2、<div fontcolor=#ef3a3a>首次祈愿免费</div>，后续祈愿需要消耗【英雄祈愿券】。\n3、【英雄祈愿券】每个价值1钻石，<div fontcolor=#ef3a3a>活动结束后将无法使用并会按1：1回收为5千金币(以邮件形式发放)</div>，请冒险者大人尽快使用。\n4、<div fontcolor=#ef3a3a>第80次祈愿开始</div>，即有机率可以获得【英雄祈愿自选礼盒】，强力英雄<div fontcolor=#ef3a3a>【哪吒】、【维纳斯】、【尼德霍格】</div>三选一。"},
	["tips_2"] = {label='tips_2', val=2, desc="1、活动期间，玩家每日与<div fontcolor=#65df74>回归玩家</div>完成以下指定玩法可获得对应的【时光漂流瓶】，使用一定数量的【时光漂流瓶】可兑换相应奖励；\n（1）与回归玩家完成好友切磋1次可获得10个漂流瓶，同个回归好友每日只能获得1次奖励\n（2）在无尽试炼-好友支援中使用回归玩家支援英雄可获得20个漂流瓶，同个回归好友每日只能获得1次奖励\n（3）与回归玩家完成组队竞技场组队并参与1次挑战可获得5个漂流瓶\n2、活动期间，40级以上玩家在登录之前连续15日未登录游戏，即为回归玩家，<div fontcolor=#65df74>头像将会显示“回归”字眼</div>的特殊标记，可前往查看自己的回归好友。\n3、通过指定玩法每日最高可获得<div fontcolor=#65df74>100个</div>【时光漂流瓶】。\n4、除完成指定玩法外，也可以通过领取回归玩家发送的全服回归红包获得【时光漂流瓶】，请关注游戏内提示哦~\n5、【时光漂流瓶】<div fontcolor=#65df74>活动结束后将无法使用并会按1：1回收为5千金币(以邮件形式发放)</div>，请冒险者大人尽快使用。"},
	["exchange_cond"] = {label='exchange_cond', val={{'open_day',17},{'lev',10}}, desc="兑换商店玩家条件"},
	["arena_team_award"] = {label='arena_team_award', val={{10418,5}}, desc="组队竞技场奖励"},
	["pk_award"] = {label='pk_award', val={{10418,10}}, desc="pk奖励"},
	["endless_award"] = {label='endless_award', val={{10418,20}}, desc="无尽试炼奖励"},
	["invade_id"] = {label='invade_id', val=99936, desc="id"},
	["defend_id"] = {label='defend_id', val=99937, desc="id"},
	["red_item_value"] = {label='red_item_value', val={{1,100000}}, desc="红包道具返还价值"},
	["exchange_item_value"] = {label='exchange_item_value', val={{1,5000}}, desc="兑换道具返还价值"},
	["draw_item_reward_value"] = {label='draw_item_reward_value', val={{1,5000}}, desc="抽奖道具返还价值"}
}
Config.HolidayReturnNewData.data_constant_fun = function(key)
	local data=Config.HolidayReturnNewData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnNewData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------action_holiday_start-------------------
Config.HolidayReturnNewData.data_action_holiday_length = 1
Config.HolidayReturnNewData.data_action_holiday = {
	[1] = {
		[101] = {period=1, camp_id=101, min_day=0, max_day=14, title="重逢之礼", ico="222", panel_type=121, panel_res="txt_cn_returnaction1", tips="1、活动期间，40级以上玩家在登录之前连续15日未登录游戏，即为回归玩家；\n2、回归玩家头像左下角将显示“回归”字眼的特殊标记；\n3、回归玩家可免费立领以下祝福好礼；"},
		[102] = {period=1, camp_id=102, min_day=0, max_day=14, title="英雄祈愿", ico="220", panel_type=122, panel_res="txt_cn_return_summon_1", tips=""},
		[103] = {period=1, camp_id=103, min_day=0, max_day=14, title="重聚作战", ico="223", panel_type=123, panel_res="txt_cn_returnaction2", tips="重聚冒险大陆，协力再创辉煌"},
		[104] = {period=1, camp_id=104, min_day=0, max_day=14, title="专属签到", ico="224", panel_type=124, panel_res="txt_cn_returnaction3", tips="每日登录领取回归专属好礼"},
	},
}
-- -------------------action_holiday_end---------------------


-- -------------------privilege_start-------------------
Config.HolidayReturnNewData.data_privilege_length = 1
Config.HolidayReturnNewData.data_privilege = {
	[1] = {period=1, start_time={2019,12,19,0,0,0}, end_time={2020,1,1,23,59,59}, open_cond={{'prevlogout_day',16},{'lev',40}}, holiday_day=14}
}
Config.HolidayReturnNewData.data_privilege_fun = function(key)
	local data=Config.HolidayReturnNewData.data_privilege[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnNewData.data_privilege['..key..'])not found') return
	end
	return data
end
-- -------------------privilege_end---------------------


-- -------------------gift_start-------------------
Config.HolidayReturnNewData.data_gift_length = 1
Config.HolidayReturnNewData.data_gift = {
	[1] = {period=1, rewards={{50917,1},{10403,2},{10416,500},{39059,1}}}
}
Config.HolidayReturnNewData.data_gift_fun = function(key)
	local data=Config.HolidayReturnNewData.data_gift[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnNewData.data_gift['..key..'])not found') return
	end
	return data
end
-- -------------------gift_end---------------------


-- -------------------signin_start-------------------
Config.HolidayReturnNewData.data_signin_length = 1
Config.HolidayReturnNewData.data_signin = {
	[1] = {
		[1] = {period=1, day=1, name="天", rewards={{10416,100},{10417,1}}},
		[2] = {period=1, day=2, name="天", rewards={{10416,100},{10417,1}}},
		[3] = {period=1, day=3, name="天", rewards={{10416,100},{10417,1}}},
		[4] = {period=1, day=4, name="天", rewards={{10416,100},{10417,1}}},
		[5] = {period=1, day=5, name="天", rewards={{10416,100},{10417,1}}},
		[6] = {period=1, day=6, name="天", rewards={{10416,100},{10417,1}}},
		[7] = {period=1, day=7, name="天", rewards={{10416,100},{10417,1}}},
	},
}
-- -------------------signin_end---------------------


-- -------------------summon_start-------------------
Config.HolidayReturnNewData.data_summon_length = 1
Config.HolidayReturnNewData.data_summon = {
	[1] = {
		[1] = {period=1, id=1, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[2] = {period=1, id=2, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[3] = {period=1, id=3, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[4] = {period=1, id=4, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[5] = {period=1, id=5, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[6] = {period=1, id=6, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[7] = {period=1, id=7, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[8] = {period=1, id=8, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[9] = {period=1, id=9, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[10] = {period=1, id=10, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[11] = {period=1, id=11, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[12] = {period=1, id=12, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[13] = {period=1, id=13, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[14] = {period=1, id=14, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[15] = {period=1, id=15, type_id=1, rewards={{72001,5}}, must_not=0, must=0, pro=100, show=0, show_pro=15, sort=0},
		[16] = {period=1, id=16, type_id=2, rewards={{10040,5}}, must_not=0, must=0, pro=100, show=0, show_pro=5, sort=0},
		[17] = {period=1, id=17, type_id=2, rewards={{10040,5}}, must_not=0, must=0, pro=100, show=0, show_pro=5, sort=0},
		[18] = {period=1, id=18, type_id=2, rewards={{10040,5}}, must_not=0, must=0, pro=100, show=0, show_pro=5, sort=0},
		[19] = {period=1, id=19, type_id=2, rewards={{10040,5}}, must_not=0, must=0, pro=100, show=0, show_pro=5, sort=0},
		[20] = {period=1, id=20, type_id=2, rewards={{10040,5}}, must_not=0, must=0, pro=100, show=0, show_pro=5, sort=0},
		[21] = {period=1, id=21, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[22] = {period=1, id=22, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[23] = {period=1, id=23, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[24] = {period=1, id=24, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[25] = {period=1, id=25, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[26] = {period=1, id=26, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[27] = {period=1, id=27, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[28] = {period=1, id=28, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[29] = {period=1, id=29, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[30] = {period=1, id=30, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[31] = {period=1, id=31, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[32] = {period=1, id=32, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[33] = {period=1, id=33, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[34] = {period=1, id=34, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[35] = {period=1, id=35, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[36] = {period=1, id=36, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[37] = {period=1, id=37, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[38] = {period=1, id=38, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[39] = {period=1, id=39, type_id=3, rewards={{28,10}}, must_not=0, must=0, pro=100, show=0, show_pro=19, sort=0},
		[40] = {period=1, id=40, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[41] = {period=1, id=41, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[42] = {period=1, id=42, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[43] = {period=1, id=43, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[44] = {period=1, id=44, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[45] = {period=1, id=45, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[46] = {period=1, id=46, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[47] = {period=1, id=47, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[48] = {period=1, id=48, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[49] = {period=1, id=49, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[50] = {period=1, id=50, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[51] = {period=1, id=51, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[52] = {period=1, id=52, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[53] = {period=1, id=53, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[54] = {period=1, id=54, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[55] = {period=1, id=55, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[56] = {period=1, id=56, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[57] = {period=1, id=57, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[58] = {period=1, id=58, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[59] = {period=1, id=59, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[60] = {period=1, id=60, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[61] = {period=1, id=61, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[62] = {period=1, id=62, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[63] = {period=1, id=63, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[64] = {period=1, id=64, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[65] = {period=1, id=65, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[66] = {period=1, id=66, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[67] = {period=1, id=67, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[68] = {period=1, id=68, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[69] = {period=1, id=69, type_id=4, rewards={{10450,100}}, must_not=0, must=0, pro=100, show=0, show_pro=30, sort=0},
		[70] = {period=1, id=70, type_id=5, rewards={{35,1}}, must_not=62, must=0, pro=100, show=0, show_pro=5, sort=0},
		[71] = {period=1, id=71, type_id=5, rewards={{35,1}}, must_not=40, must=0, pro=100, show=0, show_pro=5, sort=0},
		[72] = {period=1, id=72, type_id=5, rewards={{35,1}}, must_not=0, must=0, pro=100, show=0, show_pro=5, sort=0},
		[73] = {period=1, id=73, type_id=5, rewards={{35,1}}, must_not=91, must=0, pro=100, show=0, show_pro=5, sort=0},
		[74] = {period=1, id=74, type_id=5, rewards={{35,1}}, must_not=0, must=18, pro=100, show=0, show_pro=5, sort=0},
		[75] = {period=1, id=75, type_id=6, rewards={{10602,1}}, must_not=0, must=0, pro=100, show=0, show_pro=2, sort=0},
		[76] = {period=1, id=76, type_id=6, rewards={{10602,1}}, must_not=15, must=0, pro=100, show=0, show_pro=2, sort=0},
		[77] = {period=1, id=77, type_id=7, rewards={{29905,5}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=3},
		[78] = {period=1, id=78, type_id=7, rewards={{29905,5}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=3},
		[79] = {period=1, id=79, type_id=7, rewards={{29905,5}}, must_not=81, must=0, pro=100, show=1, show_pro=10, sort=3},
		[80] = {period=1, id=80, type_id=7, rewards={{29905,5}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=3},
		[81] = {period=1, id=81, type_id=7, rewards={{29905,5}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=3},
		[82] = {period=1, id=82, type_id=7, rewards={{29905,5}}, must_not=30, must=0, pro=100, show=1, show_pro=10, sort=3},
		[83] = {period=1, id=83, type_id=7, rewards={{29905,5}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=3},
		[84] = {period=1, id=84, type_id=7, rewards={{29905,5}}, must_not=70, must=0, pro=100, show=1, show_pro=10, sort=3},
		[85] = {period=1, id=85, type_id=7, rewards={{29905,5}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=3},
		[86] = {period=1, id=86, type_id=7, rewards={{29905,5}}, must_not=0, must=10, pro=100, show=1, show_pro=10, sort=3},
		[87] = {period=1, id=87, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[88] = {period=1, id=88, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[89] = {period=1, id=89, type_id=8, rewards={{10403,1}}, must_not=60, must=0, pro=100, show=1, show_pro=10, sort=4},
		[90] = {period=1, id=90, type_id=8, rewards={{10403,1}}, must_not=61, must=0, pro=100, show=1, show_pro=10, sort=4},
		[91] = {period=1, id=91, type_id=8, rewards={{10403,1}}, must_not=90, must=0, pro=100, show=1, show_pro=10, sort=4},
		[92] = {period=1, id=92, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[93] = {period=1, id=93, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[94] = {period=1, id=94, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[95] = {period=1, id=95, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[96] = {period=1, id=96, type_id=8, rewards={{10403,1}}, must_not=0, must=0, pro=100, show=1, show_pro=10, sort=4},
		[97] = {period=1, id=97, type_id=9, rewards={{14001,1}}, must_not=0, must=28, pro=100, show=1, show_pro=3, sort=2},
		[98] = {period=1, id=98, type_id=9, rewards={{14001,1}}, must_not=50, must=0, pro=100, show=1, show_pro=3, sort=2},
		[99] = {period=1, id=99, type_id=9, rewards={{14001,1}}, must_not=0, must=0, pro=100, show=1, show_pro=3, sort=2},
		[100] = {period=1, id=100, type_id=10, rewards={{39060,1}}, must_not=80, must=0, pro=100, show=1, show_pro=1, sort=1},
	},
}
-- -------------------summon_end---------------------


-- -------------------task_start-------------------
Config.HolidayReturnNewData.data_task_length = 7
Config.HolidayReturnNewData.data_task = {
	["1_101"] = {period=1, id=101, f_id=101, s_id=1, title="欢迎来我家做客", desc="拜访任意好友家园1次", progress={{cli_label="evt_visit_home",target=0,target_val=1,param={}}}, award={{10417,1}}, source_id=418},
	["1_102"] = {period=1, id=102, f_id=102, s_id=1, title="我们的友谊，情比金坚", desc="好友赠送获得80点友情点", progress={{cli_label="evt_get_friend_point",target=0,target_val=80,param={}}}, award={{10416,100}}, source_id=402},
	["1_103"] = {period=1, id=103, f_id=103, s_id=1, title="今天开始是第一天", desc="新增1个好友", progress={{cli_label="evt_add_friend",target=0,target_val=1,param={}}}, award={{10416,100}}, source_id=402},
	["1_104"] = {period=1, id=104, f_id=103, s_id=2, title="今天开始是第一天", desc="新增3个好友", progress={{cli_label="evt_add_friend",target=0,target_val=3,param={}}}, award={{10416,100}}, source_id=402},
	["1_105"] = {period=1, id=105, f_id=103, s_id=3, title="今天开始是第一天", desc="新增5个好友", progress={{cli_label="evt_add_friend",target=0,target_val=5,param={}}}, award={{10416,100}}, source_id=402},
	["1_106"] = {period=1, id=106, f_id=104, s_id=1, title="我们的公会无人能敌！", desc="完成1次公会副本", progress={{cli_label="evt_guild_dun_fight",target=0,target_val=1,param={}}}, award={{10416,100}}, source_id=419},
	["1_107"] = {period=1, id=107, f_id=105, s_id=1, title="哇！一起探险吧", desc="完成1次公会秘境", progress={{cli_label="evt_guild_secret_area_combat",target=0,target_val=1,param={}}}, award={{10416,100}}, source_id=419}
}
Config.HolidayReturnNewData.data_task_fun = function(key)
	local data=Config.HolidayReturnNewData.data_task[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayReturnNewData.data_task['..key..'])not found') return
	end
	return data
end
-- -------------------task_end---------------------


-- -------------------lanterm_adventure_task_list_start-------------------
Config.HolidayReturnNewData.data_lanterm_adventure_task_list_length = 1
Config.HolidayReturnNewData.data_lanterm_adventure_task_list = {
	[1] = {
		[101] = {
			[1] = {id=101},
		},
		[102] = {
			[1] = {id=102},
		},
		[103] = {
			[1] = {id=103},
			[2] = {id=104},
			[3] = {id=105},
		},
		[104] = {
			[1] = {id=106},
		},
		[105] = {
			[1] = {id=107},
		},
	},
}
-- -------------------lanterm_adventure_task_list_end---------------------


-- -------------------shop_start-------------------
Config.HolidayReturnNewData.data_shop_length = 1
Config.HolidayReturnNewData.data_shop = {
	[1] = {
		[1] = {period=1, id=1, expend={{10418,300}}, award={{14001,1}}, r_limit_day=0, r_limit_all=1, title="", sub_type=2},
		[2] = {period=1, id=2, expend={{10418,60}}, award={{10403,1}}, r_limit_day=0, r_limit_all=3, title="", sub_type=2},
		[3] = {period=1, id=3, expend={{10418,100}}, award={{10602,1}}, r_limit_day=0, r_limit_all=1, title="", sub_type=2},
		[4] = {period=1, id=4, expend={{10418,50}}, award={{10450,100}}, r_limit_day=0, r_limit_all=10, title="", sub_type=2},
		[5] = {period=1, id=5, expend={{10418,50}}, award={{10040,5}}, r_limit_day=0, r_limit_all=10, title="", sub_type=2},
		[6] = {period=1, id=6, expend={{10418,10}}, award={{1,50000}}, r_limit_day=0, r_limit_all=99, title="", sub_type=2},
		[7] = {period=1, id=7, expend={{10418,10}}, award={{22,10000}}, r_limit_day=0, r_limit_all=99, title="", sub_type=2},
	},
}
-- -------------------shop_end---------------------
