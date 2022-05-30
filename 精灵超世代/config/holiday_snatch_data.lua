----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_snatch_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidaySnatchData = Config.HolidaySnatchData or {}

-- -------------------const_start-------------------
Config.HolidaySnatchData.data_const_length = 11
Config.HolidaySnatchData.data_const = {
	["item_price"] = {code="item_price", val=10, desc="门票价值"},
	["item_score"] = {code="item_score", val={37007,3}, desc="门票积分"},
	["holiday_open_time"] = {code="holiday_open_time", val={{12,0,0},{18,0,0}}, desc="开启时间"},
	["holiday_close_time"] = {code="holiday_close_time", val={{14,0,0},{20,0,0}}, desc="结束时间"},
	["holiday_rule"] = {code="holiday_rule", val={}, desc="<div fontcolor=#fca000>活动时间：</div>6月6日至6月11日\n<div fontcolor=#fca000>玩法说明：</div>\n1.花费<div fontcolor=#00ff00>1夺宝币</div>可购买1人次，并获得一个<div fontcolor=#00ff00>夺宝号码</div>\n2.商品<div fontcolor=#00ff00>购买次数</div>够了之后，会抽出一名幸运玩家获得该商品\n3.每逢<div fontcolor=#00ff00>购买次数达到条件</div>会开奖一次\n4.购买次数越多，中奖概率越高\n5.已开奖却未中奖的玩家均会<div fontcolor=#00ff00>1:3邮件获得所消耗夺宝币的夺宝积分</div>，可以在兑换商店兑换道具（下架物品只返还夺宝币）\n6.奖品及积分会通过<div fontcolor=#00ff00>邮件形式</div>发放，请大人及时领取并使用哦\n7.商品如果在<div fontcolor=#00ff00>2个小时</div>内没有达到足够的购买人次会<div fontcolor=#00ff00>下架</div>，并<div fontcolor=#00ff00>返还</div>玩家花费的<div fontcolor=#00ff00>夺宝币</div>\n<div fontcolor=#fca000>抽奖规则：</div>\n1.每一期开奖会随机出一个<div fontcolor=#00ff00>随机数</div>\n2.根据<div fontcolor=#00ff00>最后30位夺宝玩家的购买时间</div>和随机数计算出幸运号码\n3.幸运号码与夺宝号码相同的玩家最终获得该商品\n4.幸运号码=10001+[（最后30位夺宝玩家的购买时间之和+每期随机数）÷总需人次]的余数\n"},
	["alive_day"] = {code="alive_day", val=2, desc="活跃天数"},
	["group_limit"] = {code="group_limit", val=50000, desc="单组人数限制"},
	["zone_min_num"] = {code="zone_min_num", val=15000, desc="最后一组人数小于值 则合并到前1组"},
	["item_ticket"] = {code="item_ticket", val=37006, desc="夺宝门票"},
	["snatch_time1"] = {code="snatch_time1", val={{12,0},{14,0}}, desc="夺宝时间1"},
	["snatch_time2"] = {code="snatch_time2", val={{18,0},{20,0}}, desc="夺宝时间2"}
}
Config.HolidaySnatchData.data_const_fun = function(key)
	local data=Config.HolidaySnatchData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySnatchData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------join_goods_list_start-------------------
Config.HolidaySnatchData.data_join_goods_list_length = 81
Config.HolidaySnatchData.data_join_goods_list = {
	[101] = {f_id=1001, id=101, name="冰雪女王碎片", award={{24901,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[102] = {f_id=1001, id=102, name="波塞冬碎片", award={{24904,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[103] = {f_id=1001, id=103, name="瓦尔基里碎片", award={{25907,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[104] = {f_id=1001, id=104, name="洛基碎片", award={{25908,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[105] = {f_id=1001, id=105, name="潘碎片", award={{26906,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[106] = {f_id=1001, id=106, name="斯芬克斯碎片", award={{26907,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[107] = {f_id=1001, id=107, name="宙斯碎片", award={{27901,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[108] = {f_id=1001, id=108, name="神灵大祭司碎片", award={{27906,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[109] = {f_id=1001, id=109, name="黑暗之主碎片", award={{28903,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[110] = {f_id=1001, id=110, name="潘多拉碎片", award={{28906,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[111] = {f_id=1001, id=111, name="拉斐尔碎片", award={{27907,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[112] = {f_id=1001, id=112, name="芬尼尔碎片", award={{26908,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[113] = {f_id=1001, id=113, name="耶梦加得碎片", award={{24909,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[201] = {f_id=1002, id=201, name="冰雪女王碎片", award={{24901,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[202] = {f_id=1002, id=202, name="波塞冬碎片", award={{24904,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[203] = {f_id=1002, id=203, name="普罗米修斯碎片", award={{25906,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[204] = {f_id=1002, id=204, name="瓦尔基里碎片", award={{25907,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[205] = {f_id=1002, id=205, name="洛基碎片", award={{25908,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[206] = {f_id=1002, id=206, name="影刹碎片", award={{26901,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[207] = {f_id=1002, id=207, name="潘碎片", award={{26906,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[208] = {f_id=1002, id=208, name="斯芬克斯碎片", award={{26907,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[209] = {f_id=1002, id=209, name="宙斯碎片", award={{27901,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[210] = {f_id=1002, id=210, name="神灵大祭司碎片", award={{27906,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[211] = {f_id=1002, id=211, name="哈迪斯碎片", award={{28901,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=100, limit_role_max=400, is_hot=1},
	[212] = {f_id=1002, id=212, name="黑暗之主碎片", award={{28903,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[213] = {f_id=1002, id=213, name="潘多拉碎片", award={{28906,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[214] = {f_id=1002, id=214, name="拉斐尔碎片", award={{27907,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[215] = {f_id=1002, id=215, name="芬尼尔碎片", award={{26908,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[216] = {f_id=1002, id=216, name="耶梦加得碎片", award={{24909,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[217] = {f_id=1002, id=217, name="彩虹符文", award={{10454,1}}, price=625, expend={{37006,1}}, limit_min=625, limit_max=625, pro=50, limit_role_max=625, is_hot=1},
	[301] = {f_id=1003, id=301, name="冰雪女王碎片", award={{24901,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[302] = {f_id=1003, id=302, name="波塞冬碎片", award={{24904,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[303] = {f_id=1003, id=303, name="普罗米修斯碎片", award={{25906,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[304] = {f_id=1003, id=304, name="瓦尔基里碎片", award={{25907,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[305] = {f_id=1003, id=305, name="洛基碎片", award={{25908,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[306] = {f_id=1003, id=306, name="影刹碎片", award={{26901,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[307] = {f_id=1003, id=307, name="潘碎片", award={{26906,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[308] = {f_id=1003, id=308, name="斯芬克斯碎片", award={{26907,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[309] = {f_id=1003, id=309, name="宙斯碎片", award={{27901,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[310] = {f_id=1003, id=310, name="神灵大祭司碎片", award={{27906,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[311] = {f_id=1003, id=311, name="哈迪斯碎片", award={{28901,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[312] = {f_id=1003, id=312, name="黑暗之主碎片", award={{28903,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[313] = {f_id=1003, id=313, name="潘多拉碎片", award={{28906,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[314] = {f_id=1003, id=314, name="拉斐尔碎片", award={{27907,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[315] = {f_id=1003, id=315, name="芬尼尔碎片", award={{26908,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[316] = {f_id=1003, id=316, name="耶梦加得碎片", award={{24909,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[317] = {f_id=1003, id=317, name="娜迦公主碎片", award={{24900,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[318] = {f_id=1003, id=318, name="冰霜巨龙碎片", award={{24902,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[319] = {f_id=1003, id=319, name="泰坦碎片", award={{24903,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[320] = {f_id=1003, id=320, name="炽天使碎片", award={{25900,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[321] = {f_id=1003, id=321, name="炎魔之王碎片", award={{25901,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[322] = {f_id=1003, id=322, name="菲尼克斯碎片", award={{25903,50}}, price=250, expend={{37006,1}}, limit_min=250, limit_max=250, pro=100, limit_role_max=250, is_hot=1},
	[323] = {f_id=1003, id=323, name="阿波罗碎片", award={{25904,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[324] = {f_id=1003, id=324, name="奥丁碎片", award={{26900,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[325] = {f_id=1003, id=325, name="凯兰崔尔碎片", award={{26902,50}}, price=150, expend={{37006,1}}, limit_min=150, limit_max=150, pro=100, limit_role_max=150, is_hot=1},
	[326] = {f_id=1003, id=326, name="魅魔女王碎片", award={{26903,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[327] = {f_id=1003, id=327, name="雅典娜碎片", award={{26905,50}}, price=200, expend={{37006,1}}, limit_min=200, limit_max=200, pro=100, limit_role_max=200, is_hot=1},
	[328] = {f_id=1003, id=328, name="赫拉碎片", award={{27902,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=100, limit_role_max=400, is_hot=1},
	[329] = {f_id=1003, id=329, name="雷神碎片", award={{27903,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=100, limit_role_max=400, is_hot=1},
	[330] = {f_id=1003, id=330, name="艾蕾莉亚碎片", award={{27905,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=100, limit_role_max=400, is_hot=1},
	[331] = {f_id=1003, id=331, name="亚巴顿碎片", award={{28902,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=100, limit_role_max=400, is_hot=1},
	[332] = {f_id=1003, id=332, name="阿努比斯碎片", award={{28904,50}}, price=400, expend={{37006,1}}, limit_min=400, limit_max=400, pro=50, limit_role_max=400, is_hot=1},
	[333] = {f_id=1003, id=333, name="彩虹符文", award={{10454,1}}, price=625, expend={{37006,1}}, limit_min=625, limit_max=625, pro=50, limit_role_max=625, is_hot=1},
	[334] = {f_id=1003, id=334, name="随机2星红装礼包", award={{38061,1}}, price=145, expend={{37006,1}}, limit_min=145, limit_max=145, pro=100, limit_role_max=145, is_hot=1},
	[401] = {f_id=1004, id=401, name="彩虹符文", award={{10454,1}}, price=625, expend={{37006,1}}, limit_min=625, limit_max=625, pro=50, limit_role_max=625, is_hot=0},
	[402] = {f_id=1004, id=402, name="先知水晶", award={{14001,6}}, price=375, expend={{37006,1}}, limit_min=375, limit_max=375, pro=100, limit_role_max=375, is_hot=0},
	[403] = {f_id=1004, id=403, name="高级召唤卷", award={{10403,10}}, price=60, expend={{37006,1}}, limit_min=60, limit_max=60, pro=100, limit_role_max=60, is_hot=0},
	[404] = {f_id=1004, id=404, name="符文精华", award={{10450,5000}}, price=125, expend={{37006,1}}, limit_min=125, limit_max=125, pro=100, limit_role_max=125, is_hot=0},
	[405] = {f_id=1004, id=405, name="5星随机碎片", award={{29905,50}}, price=125, expend={{37006,1}}, limit_min=125, limit_max=125, pro=100, limit_role_max=125, is_hot=0},
	[406] = {f_id=1004, id=406, name="先知水晶", award={{14001,3}}, price=180, expend={{37006,1}}, limit_min=180, limit_max=180, pro=100, limit_role_max=180, is_hot=0},
	[407] = {f_id=1004, id=407, name="高级召唤卷", award={{10403,20}}, price=125, expend={{37006,1}}, limit_min=125, limit_max=125, pro=100, limit_role_max=125, is_hot=0},
	[408] = {f_id=1004, id=408, name="符文精华", award={{10450,3000}}, price=75, expend={{37006,1}}, limit_min=75, limit_max=75, pro=100, limit_role_max=75, is_hot=0},
	[409] = {f_id=1004, id=409, name="高级寻宝券", award={{37002,5}}, price=125, expend={{37006,1}}, limit_min=125, limit_max=125, pro=100, limit_role_max=125, is_hot=0},
	[501] = {f_id=1005, id=501, name="先知水晶", award={{14001,1}}, price=60, expend={{37006,1}}, limit_min=60, limit_max=60, pro=100, limit_role_max=60, is_hot=0},
	[502] = {f_id=1005, id=502, name="高级召唤卷", award={{10403,1}}, price=6, expend={{37006,1}}, limit_min=6, limit_max=6, pro=100, limit_role_max=6, is_hot=0},
	[503] = {f_id=1005, id=503, name="5星随机碎片", award={{29905,10}}, price=25, expend={{37006,1}}, limit_min=25, limit_max=25, pro=100, limit_role_max=25, is_hot=0},
	[504] = {f_id=1005, id=504, name="先知水晶", award={{14001,1}}, price=60, expend={{37006,1}}, limit_min=60, limit_max=60, pro=100, limit_role_max=60, is_hot=0},
	[505] = {f_id=1005, id=505, name="高级召唤卷", award={{10403,1}}, price=6, expend={{37006,1}}, limit_min=6, limit_max=6, pro=100, limit_role_max=6, is_hot=0},
	[506] = {f_id=1005, id=506, name="符文精华", award={{10450,1000}}, price=25, expend={{37006,1}}, limit_min=25, limit_max=25, pro=100, limit_role_max=25, is_hot=0},
	[507] = {f_id=1005, id=507, name="高级寻宝券", award={{37002,1}}, price=25, expend={{37006,1}}, limit_min=25, limit_max=25, pro=100, limit_role_max=25, is_hot=0},
	[508] = {f_id=1005, id=508, name="寻宝券", award={{37001,10}}, price=10, expend={{37006,1}}, limit_min=10, limit_max=10, pro=100, limit_role_max=10, is_hot=0}
}
Config.HolidaySnatchData.data_join_goods_list_fun = function(key)
	local data=Config.HolidaySnatchData.data_join_goods_list[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidaySnatchData.data_join_goods_list['..key..'])not found') return
	end
	return data
end
-- -------------------join_goods_list_end---------------------
