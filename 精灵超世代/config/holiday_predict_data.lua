----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_predict_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayPredictData = Config.HolidayPredictData or {}

-- -------------------constant_start-------------------
Config.HolidayPredictData.data_constant_length = 15
Config.HolidayPredictData.data_constant = {
	["num_1"] = {key="num_1", val=3, desc="幸运松果数"},
	["num_2"] = {key="num_2", val=3, desc="豪华松果数"},
	["must_num_1"] = {key="must_num_1", val=0, desc="幸运松果必出珍品数"},
	["must_num_2"] = {key="must_num_2", val=40, desc="豪华松果必出珍品数"},
	["refresh"] = {key="refresh", val={{37008,1}}, desc="刷新消耗"},
	["item1"] = {key="item1", val=37008, desc="松果币道具"},
	["free_time1"] = {key="free_time1", val=2, desc="幸运松果每日免费刷新次数"},
	["free_time2"] = {key="free_time2", val=1, desc="豪华松果每日免费刷新次数"},
	["game_rule1"] = {key="game_rule1", val=1, desc="玩法说明：\n1、活动期间每天均有免费机会打开松果宝藏\n2、若该宝藏结果符合预期，你可以消耗松果币可购买当前宝藏结果，拥有这些道具（松果币不足可使用钻石补足）\n3、宝藏刷新次数及结果每日0点重置，请及时购买哦"},
	["game_rule2"] = {key="game_rule2", val=2, desc="玩法说明：\n1、活动期间每天均有免费机会打开松果宝藏\n2、若该宝藏结果符合预期，你可以消耗松果币可购买当前宝藏结果，拥有这些道具（松果币不足可使用钻石补足）\n3、宝藏刷新次数及结果每日0点重置，请及时购买哦\n4、豪华松果刷新达到指定次数必出珍稀道具哦"},
	["buy_time1"] = {key="buy_time1", val=3, desc="幸运松果活动限购次数"},
	["buy_time2"] = {key="buy_time2", val=1, desc="豪华松果活动限购次数"},
	["show_item1"] = {key="show_item1", val={{29905,1},{14001,1},{10408,1},{10403,1},{200214,1},{200314,1}}, desc="主界面奖励预览配置幸运"},
	["show_item2"] = {key="show_item2", val={{29962,1},{29906,1},{29905,1},{14001,1},{10408,1},{10403,1}}, desc="主界面奖励预览配置豪华"},
	["item_price"] = {key="item_price", val={{3,100}}, desc="松果币价格"}
}
Config.HolidayPredictData.data_constant_fun = function(key)
	local data=Config.HolidayPredictData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPredictData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------prize_pool_start-------------------
Config.HolidayPredictData.data_prize_pool_length = 2
Config.HolidayPredictData.data_prize_pool = {
	[1] = {type=1, expend_item={{37008,20}}, expend_gold={{3,2000}}},
	[2] = {type=2, expend_item={{37008,60}}, expend_gold={{3,6000}}}
}
Config.HolidayPredictData.data_prize_pool_fun = function(key)
	local data=Config.HolidayPredictData.data_prize_pool[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPredictData.data_prize_pool['..key..'])not found') return
	end
	return data
end
-- -------------------prize_pool_end---------------------


-- -------------------reward_pos_start-------------------
Config.HolidayPredictData.data_reward_pos_length = 108
Config.HolidayPredictData.data_reward_pos = {
	[101] = {item_id=14001, item_num=1, is_goal=1},
	[102] = {item_id=14001, item_num=2, is_goal=1},
	[103] = {item_id=10408, item_num=8, is_goal=1},
	[104] = {item_id=10403, item_num=8, is_goal=1},
	[105] = {item_id=29905, item_num=50, is_goal=1},
	[106] = {item_id=29905, item_num=25, is_goal=1},
	[107] = {item_id=29105, item_num=25, is_goal=1},
	[108] = {item_id=29205, item_num=25, is_goal=1},
	[109] = {item_id=29305, item_num=25, is_goal=1},
	[110] = {item_id=14002, item_num=20, is_goal=1},
	[111] = {item_id=10450, item_num=500, is_goal=1},
	[112] = {item_id=10450, item_num=800, is_goal=1},
	[113] = {item_id=10450, item_num=1000, is_goal=1},
	[114] = {item_id=17005, item_num=50, is_goal=1},
	[115] = {item_id=10408, item_num=5, is_goal=1},
	[116] = {item_id=10403, item_num=5, is_goal=1},
	[117] = {item_id=29905, item_num=20, is_goal=1},
	[118] = {item_id=200313, item_num=1, is_goal=1},
	[119] = {item_id=200314, item_num=1, is_goal=1},
	[120] = {item_id=200213, item_num=1, is_goal=1},
	[121] = {item_id=200214, item_num=1, is_goal=1},
	[122] = {item_id=200206, item_num=1, is_goal=0},
	[123] = {item_id=200207, item_num=1, is_goal=0},
	[124] = {item_id=200113, item_num=1, is_goal=0},
	[125] = {item_id=200312, item_num=1, is_goal=0},
	[126] = {item_id=200307, item_num=1, is_goal=0},
	[127] = {item_id=200308, item_num=1, is_goal=0},
	[128] = {item_id=10408, item_num=1, is_goal=0},
	[129] = {item_id=10403, item_num=1, is_goal=0},
	[130] = {item_id=37001, item_num=5, is_goal=0},
	[131] = {item_id=10002, item_num=6, is_goal=0},
	[132] = {item_id=10450, item_num=200, is_goal=0},
	[133] = {item_id=72001, item_num=15, is_goal=0},
	[134] = {item_id=17005, item_num=10, is_goal=0},
	[135] = {item_id=10001, item_num=200, is_goal=0},
	[136] = {item_id=10103, item_num=10, is_goal=0},
	[137] = {item_id=10, item_num=500, is_goal=0},
	[138] = {item_id=24900, item_num=50, is_goal=1},
	[139] = {item_id=24902, item_num=50, is_goal=1},
	[140] = {item_id=24903, item_num=50, is_goal=1},
	[141] = {item_id=25900, item_num=50, is_goal=1},
	[142] = {item_id=25903, item_num=50, is_goal=1},
	[143] = {item_id=25904, item_num=50, is_goal=1},
	[144] = {item_id=26900, item_num=50, is_goal=1},
	[145] = {item_id=26903, item_num=50, is_goal=1},
	[146] = {item_id=26905, item_num=50, is_goal=1},
	[147] = {item_id=24901, item_num=50, is_goal=1},
	[148] = {item_id=24904, item_num=50, is_goal=1},
	[149] = {item_id=24910, item_num=50, is_goal=1},
	[150] = {item_id=25906, item_num=50, is_goal=1},
	[151] = {item_id=25907, item_num=50, is_goal=1},
	[152] = {item_id=26901, item_num=50, is_goal=1},
	[153] = {item_id=26906, item_num=50, is_goal=1},
	[154] = {item_id=26907, item_num=50, is_goal=1},
	[155] = {item_id=27901, item_num=50, is_goal=1},
	[156] = {item_id=27902, item_num=50, is_goal=1},
	[157] = {item_id=27903, item_num=50, is_goal=1},
	[158] = {item_id=27905, item_num=50, is_goal=1},
	[159] = {item_id=27906, item_num=50, is_goal=1},
	[160] = {item_id=27907, item_num=50, is_goal=1},
	[161] = {item_id=28901, item_num=50, is_goal=1},
	[162] = {item_id=28903, item_num=50, is_goal=1},
	[163] = {item_id=28904, item_num=50, is_goal=1},
	[164] = {item_id=28906, item_num=50, is_goal=1},
	[165] = {item_id=28907, item_num=50, is_goal=1},
	[166] = {item_id=29906, item_num=50, is_goal=1},
	[167] = {item_id=24900, item_num=50, is_goal=1},
	[168] = {item_id=24902, item_num=50, is_goal=1},
	[169] = {item_id=24903, item_num=50, is_goal=1},
	[170] = {item_id=24905, item_num=50, is_goal=1},
	[171] = {item_id=24906, item_num=50, is_goal=1},
	[172] = {item_id=24907, item_num=50, is_goal=1},
	[173] = {item_id=24908, item_num=50, is_goal=1},
	[174] = {item_id=25900, item_num=50, is_goal=1},
	[175] = {item_id=25901, item_num=50, is_goal=1},
	[176] = {item_id=25902, item_num=50, is_goal=1},
	[177] = {item_id=25903, item_num=50, is_goal=1},
	[178] = {item_id=25904, item_num=50, is_goal=1},
	[179] = {item_id=25905, item_num=50, is_goal=1},
	[180] = {item_id=26900, item_num=50, is_goal=1},
	[181] = {item_id=26902, item_num=50, is_goal=1},
	[182] = {item_id=26903, item_num=50, is_goal=1},
	[183] = {item_id=26904, item_num=50, is_goal=1},
	[184] = {item_id=26905, item_num=50, is_goal=1},
	[185] = {item_id=27900, item_num=50, is_goal=1},
	[186] = {item_id=27904, item_num=50, is_goal=1},
	[187] = {item_id=28900, item_num=50, is_goal=1},
	[188] = {item_id=28902, item_num=50, is_goal=1},
	[189] = {item_id=29906, item_num=50, is_goal=1},
	[190] = {item_id=14001, item_num=1, is_goal=1},
	[191] = {item_id=37002, item_num=2, is_goal=0},
	[192] = {item_id=10450, item_num=1000, is_goal=0},
	[193] = {item_id=72001, item_num=50, is_goal=0},
	[194] = {item_id=17009, item_num=50, is_goal=0},
	[195] = {item_id=10408, item_num=6, is_goal=0},
	[196] = {item_id=10403, item_num=6, is_goal=0},
	[197] = {item_id=200313, item_num=1, is_goal=1},
	[198] = {item_id=200314, item_num=1, is_goal=1},
	[199] = {item_id=200213, item_num=1, is_goal=1},
	[200] = {item_id=200214, item_num=1, is_goal=1},
	[201] = {item_id=29905, item_num=50, is_goal=1},
	[202] = {item_id=10408, item_num=2, is_goal=0},
	[203] = {item_id=10403, item_num=2, is_goal=0},
	[204] = {item_id=10450, item_num=300, is_goal=0},
	[205] = {item_id=10, item_num=500, is_goal=0},
	[206] = {item_id=29, item_num=3, is_goal=0},
	[207] = {item_id=10001, item_num=500, is_goal=0},
	[208] = {item_id=28, item_num=50, is_goal=0}
}
Config.HolidayPredictData.data_reward_pos_fun = function(key)
	local data=Config.HolidayPredictData.data_reward_pos[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayPredictData.data_reward_pos['..key..'])not found') return
	end
	return data
end
-- -------------------reward_pos_end---------------------


-- -------------------magnificat_list_start-------------------
Config.HolidayPredictData.data_magnificat_list_length = 2
Config.HolidayPredictData.data_magnificat_list = {
	[1] = {
		[101] = {name="先知水晶", num=1},
		[102] = {name="先知水晶", num=2},
		[103] = {name="精英召唤卷", num=8},
		[104] = {name="高级召唤卷", num=8},
		[105] = {name="5星随机碎片", num=50},
		[106] = {name="5星随机碎片", num=25},
		[107] = {name="5星水系碎片", num=25},
		[108] = {name="5星火系碎片", num=25},
		[109] = {name="5星自然碎片", num=25},
		[110] = {name="先知精华", num=20},
		[111] = {name="符文精华", num=500},
		[112] = {name="符文精华", num=800},
		[113] = {name="符文精华", num=1000},
		[114] = {name="原初结晶", num=50},
		[115] = {name="精英召唤卷", num=5},
		[116] = {name="高级召唤卷", num=5},
		[117] = {name="5星随机碎片", num=20},
		[118] = {name="神秘占星仪", num=1},
		[119] = {name="优雅星月小床", num=1},
		[120] = {name="皇室钢琴", num=1},
		[121] = {name="贵族黄金马车", num=1},
		[122] = {name="贵族纹章地毯", num=1},
		[123] = {name="典雅落地窗", num=1},
		[124] = {name="舒适木床", num=1},
		[125] = {name="占星窗帘", num=1},
		[126] = {name="占星密室地毯", num=1},
		[127] = {name="占星挂毯", num=1},
		[128] = {name="精英召唤卷", num=1},
		[129] = {name="高级召唤卷", num=1},
		[130] = {name="寻宝券", num=5},
		[131] = {name="远航刷新券", num=6},
		[132] = {name="符文精华", num=200},
		[133] = {name="炼神石", num=15},
		[134] = {name="原初结晶", num=10},
		[135] = {name="进阶石", num=200},
		[136] = {name="竞技挑战券", num=10},
		[137] = {name="公会贡献", num=500},
	},
	[2] = {
		[138] = {name="娜迦公主碎片", num=50},
		[139] = {name="冰霜巨龙碎片", num=50},
		[140] = {name="泰坦碎片", num=50},
		[141] = {name="炽天使碎片", num=50},
		[142] = {name="菲尼克斯碎片", num=50},
		[143] = {name="阿波罗碎片", num=50},
		[144] = {name="奥丁碎片", num=50},
		[145] = {name="魅魔女王碎片", num=50},
		[146] = {name="雅典娜碎片", num=50},
		[147] = {name="冰雪女王碎片", num=50},
		[148] = {name="波塞冬碎片", num=50},
		[149] = {name="酒神碎片", num=50},
		[150] = {name="普罗米修斯碎片", num=50},
		[151] = {name="瓦尔基里碎片", num=50},
		[152] = {name="影刹碎片", num=50},
		[153] = {name="潘碎片", num=50},
		[154] = {name="斯芬克斯碎片", num=50},
		[155] = {name="宙斯碎片", num=50},
		[156] = {name="赫拉碎片", num=50},
		[157] = {name="雷神碎片", num=50},
		[158] = {name="艾蕾莉亚碎片", num=50},
		[159] = {name="神灵大祭司碎片", num=50},
		[160] = {name="拉斐尔碎片", num=50},
		[161] = {name="哈迪斯碎片", num=50},
		[162] = {name="黑暗之主碎片", num=50},
		[163] = {name="阿努比斯碎片", num=50},
		[164] = {name="潘多拉碎片", num=50},
		[165] = {name="海拉碎片", num=50},
		[166] = {name="5星光暗碎片", num=50},
		[167] = {name="娜迦公主碎片", num=50},
		[168] = {name="冰霜巨龙碎片", num=50},
		[169] = {name="泰坦碎片", num=50},
		[170] = {name="派西斯碎片", num=50},
		[171] = {name="少年梅林碎片", num=50},
		[172] = {name="海宁芙碎片", num=50},
		[173] = {name="阿瑞斯碎片", num=50},
		[174] = {name="炽天使碎片", num=50},
		[175] = {name="炎魔之王碎片", num=50},
		[176] = {name="剑豪卡赞碎片", num=50},
		[177] = {name="菲尼克斯碎片", num=50},
		[178] = {name="阿波罗碎片", num=50},
		[179] = {name="吸血伯爵碎片", num=50},
		[180] = {name="奥丁碎片", num=50},
		[181] = {name="凯兰崔尔碎片", num=50},
		[182] = {name="魅魔女王碎片", num=50},
		[183] = {name="美杜莎碎片", num=50},
		[184] = {name="雅典娜碎片", num=50},
		[185] = {name="伊西斯碎片", num=50},
		[186] = {name="盖亚碎片", num=50},
		[187] = {name="蛇女墨莎碎片", num=50},
		[188] = {name="亚巴顿碎片", num=50},
		[189] = {name="5星光暗碎片", num=50},
		[190] = {name="先知水晶", num=1},
		[191] = {name="高级寻宝券", num=2},
		[192] = {name="符文精华", num=1000},
		[193] = {name="炼神石", num=50},
		[194] = {name="原初结晶", num=50},
		[195] = {name="精英召唤卷", num=6},
		[196] = {name="高级召唤卷", num=6},
		[197] = {name="神秘占星仪", num=1},
		[198] = {name="优雅星月小床", num=1},
		[199] = {name="皇室钢琴", num=1},
		[200] = {name="贵族黄金马车", num=1},
		[201] = {name="5星随机碎片", num=50},
		[202] = {name="精英召唤卷", num=2},
		[203] = {name="高级召唤卷", num=2},
		[204] = {name="符文精华", num=300},
		[205] = {name="公会贡献", num=500},
		[206] = {name="皮肤碎片", num=3},
		[207] = {name="进阶石", num=500},
		[208] = {name="神装碎片", num=50},
	},
}
-- -------------------magnificat_list_end---------------------
