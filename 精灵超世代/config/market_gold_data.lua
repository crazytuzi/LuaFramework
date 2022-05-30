----------------------------------------------------
-- 此文件由数据工具生成
-- 金币仙市数据--market_gold_data.xml
--------------------------------------

Config = Config or {} 
Config.MarketGoldData = Config.MarketGoldData or {}

-- -------------------market_gold_cost_start-------------------
Config.MarketGoldData.data_market_gold_cost_length = 3
Config.MarketGoldData.data_market_gold_cost = {
	["market_level"] = {key="market_level", val=1, desc="市场界面进入等级"},
	["item_sale"] = {key="item_sale", val=0.90, desc="物品折扣"},
	["market_type"] = {key="market_type", val={0,1,-1,3,2}, desc="金币市场类型显示"}
}
-- -------------------market_gold_cost_end---------------------


-- -------------------skill_shop_list_start-------------------
Config.MarketGoldData.data_skill_shop_list_length = 36
Config.MarketGoldData.data_skill_shop_list = {
	[1] = {base_id=10500, catalg=1, init_price=6000, init_stock=300, max_price=18000, min_price=4800, open_lev=1, limit_type=0, limit_num=0, sort=100},
	[2] = {base_id=10501, catalg=1, init_price=6000, init_stock=300, max_price=18000, min_price=4800, open_lev=1, limit_type=0, limit_num=0, sort=101},
	[3] = {base_id=10502, catalg=1, init_price=5250, init_stock=300, max_price=15750, min_price=4200, open_lev=1, limit_type=0, limit_num=0, sort=102},
	[4] = {base_id=10503, catalg=1, init_price=5250, init_stock=300, max_price=15750, min_price=4200, open_lev=1, limit_type=0, limit_num=0, sort=103},
	[5] = {base_id=10504, catalg=1, init_price=7500, init_stock=300, max_price=22500, min_price=6000, open_lev=1, limit_type=0, limit_num=0, sort=104},
	[6] = {base_id=10505, catalg=1, init_price=7500, init_stock=300, max_price=22500, min_price=6000, open_lev=1, limit_type=0, limit_num=0, sort=105},
	[7] = {base_id=10506, catalg=1, init_price=4500, init_stock=300, max_price=13500, min_price=3600, open_lev=1, limit_type=0, limit_num=0, sort=106},
	[8] = {base_id=10507, catalg=1, init_price=4500, init_stock=300, max_price=13500, min_price=3600, open_lev=1, limit_type=0, limit_num=0, sort=107},
	[9] = {base_id=10508, catalg=1, init_price=3000, init_stock=300, max_price=9000, min_price=2400, open_lev=1, limit_type=0, limit_num=0, sort=108},
	[10] = {base_id=10509, catalg=1, init_price=3000, init_stock=300, max_price=9000, min_price=2400, open_lev=1, limit_type=0, limit_num=0, sort=109},
	[11] = {base_id=10510, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=110},
	[12] = {base_id=10511, catalg=1, init_price=2250, init_stock=300, max_price=6750, min_price=1800, open_lev=1, limit_type=0, limit_num=0, sort=111},
	[13] = {base_id=10512, catalg=1, init_price=2250, init_stock=300, max_price=6750, min_price=1800, open_lev=1, limit_type=0, limit_num=0, sort=112},
	[14] = {base_id=10513, catalg=1, init_price=2250, init_stock=300, max_price=6750, min_price=1800, open_lev=1, limit_type=0, limit_num=0, sort=113},
	[15] = {base_id=10514, catalg=1, init_price=2250, init_stock=300, max_price=6750, min_price=1800, open_lev=1, limit_type=0, limit_num=0, sort=114},
	[16] = {base_id=10515, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=115},
	[17] = {base_id=10516, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=116},
	[18] = {base_id=10517, catalg=1, init_price=3000, init_stock=300, max_price=9000, min_price=2400, open_lev=1, limit_type=0, limit_num=0, sort=117},
	[19] = {base_id=10518, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=118},
	[20] = {base_id=10519, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=119},
	[21] = {base_id=10520, catalg=1, init_price=3000, init_stock=300, max_price=9000, min_price=2400, open_lev=1, limit_type=0, limit_num=0, sort=120},
	[22] = {base_id=10521, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=121},
	[23] = {base_id=10522, catalg=1, init_price=4500, init_stock=300, max_price=13500, min_price=3600, open_lev=1, limit_type=0, limit_num=0, sort=122},
	[24] = {base_id=10523, catalg=1, init_price=4500, init_stock=300, max_price=13500, min_price=3600, open_lev=1, limit_type=0, limit_num=0, sort=123},
	[25] = {base_id=10524, catalg=1, init_price=4500, init_stock=300, max_price=13500, min_price=3600, open_lev=1, limit_type=0, limit_num=0, sort=124},
	[26] = {base_id=10525, catalg=1, init_price=3750, init_stock=300, max_price=11250, min_price=3000, open_lev=1, limit_type=0, limit_num=0, sort=125},
	[27] = {base_id=10526, catalg=1, init_price=6000, init_stock=300, max_price=18000, min_price=4800, open_lev=1, limit_type=0, limit_num=0, sort=126},
	[28] = {base_id=10527, catalg=1, init_price=6000, init_stock=300, max_price=18000, min_price=4800, open_lev=1, limit_type=0, limit_num=0, sort=127},
	[29] = {base_id=10528, catalg=1, init_price=3000, init_stock=300, max_price=9000, min_price=2400, open_lev=1, limit_type=0, limit_num=0, sort=128},
	[30] = {base_id=10529, catalg=1, init_price=3000, init_stock=300, max_price=9000, min_price=2400, open_lev=1, limit_type=0, limit_num=0, sort=129},
	[31] = {base_id=10530, catalg=1, init_price=2400, init_stock=300, max_price=7200, min_price=1920, open_lev=1, limit_type=0, limit_num=0, sort=130},
	[32] = {base_id=10531, catalg=1, init_price=7500, init_stock=300, max_price=22500, min_price=6000, open_lev=1, limit_type=0, limit_num=0, sort=131},
	[33] = {base_id=10532, catalg=1, init_price=4500, init_stock=300, max_price=13500, min_price=3600, open_lev=1, limit_type=0, limit_num=0, sort=132},
	[34] = {base_id=10533, catalg=1, init_price=5000, init_stock=301, max_price=15000, min_price=4000, open_lev=1, limit_type=0, limit_num=0, sort=133},
	[35] = {base_id=10534, catalg=1, init_price=5000, init_stock=302, max_price=15000, min_price=4000, open_lev=1, limit_type=0, limit_num=0, sort=134},
	[36] = {base_id=10535, catalg=1, init_price=5000, init_stock=303, max_price=15000, min_price=4000, open_lev=1, limit_type=0, limit_num=0, sort=135}
}
-- -------------------skill_shop_list_end---------------------


-- -------------------form_shop_list_start-------------------
Config.MarketGoldData.data_form_shop_list_length = 36
Config.MarketGoldData.data_form_shop_list = {
	[1] = {base_id=10700, catalg=2, init_price=42000, init_stock=300, max_price=126000, min_price=33600, open_lev=1, limit_type=0, limit_num=0, sort=400},
	[2] = {base_id=10701, catalg=2, init_price=42000, init_stock=300, max_price=126000, min_price=33600, open_lev=1, limit_type=0, limit_num=0, sort=401},
	[3] = {base_id=10702, catalg=2, init_price=36750, init_stock=300, max_price=110250, min_price=29400, open_lev=1, limit_type=0, limit_num=0, sort=402},
	[4] = {base_id=10703, catalg=2, init_price=36750, init_stock=300, max_price=110250, min_price=29400, open_lev=1, limit_type=0, limit_num=0, sort=403},
	[5] = {base_id=10704, catalg=2, init_price=52500, init_stock=300, max_price=157500, min_price=42000, open_lev=1, limit_type=0, limit_num=0, sort=404},
	[6] = {base_id=10705, catalg=2, init_price=52500, init_stock=300, max_price=157500, min_price=42000, open_lev=1, limit_type=0, limit_num=0, sort=405},
	[7] = {base_id=10706, catalg=2, init_price=31500, init_stock=300, max_price=94500, min_price=25200, open_lev=1, limit_type=0, limit_num=0, sort=406},
	[8] = {base_id=10707, catalg=2, init_price=31500, init_stock=300, max_price=94500, min_price=25200, open_lev=1, limit_type=0, limit_num=0, sort=407},
	[9] = {base_id=10708, catalg=2, init_price=21000, init_stock=300, max_price=63000, min_price=16800, open_lev=1, limit_type=0, limit_num=0, sort=408},
	[10] = {base_id=10709, catalg=2, init_price=21000, init_stock=300, max_price=63000, min_price=16800, open_lev=1, limit_type=0, limit_num=0, sort=409},
	[11] = {base_id=10710, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=410},
	[12] = {base_id=10711, catalg=2, init_price=15750, init_stock=300, max_price=47250, min_price=12600, open_lev=1, limit_type=0, limit_num=0, sort=411},
	[13] = {base_id=10712, catalg=2, init_price=15750, init_stock=300, max_price=47250, min_price=12600, open_lev=1, limit_type=0, limit_num=0, sort=412},
	[14] = {base_id=10713, catalg=2, init_price=15750, init_stock=300, max_price=47250, min_price=12600, open_lev=1, limit_type=0, limit_num=0, sort=413},
	[15] = {base_id=10714, catalg=2, init_price=15750, init_stock=300, max_price=47250, min_price=12600, open_lev=1, limit_type=0, limit_num=0, sort=414},
	[16] = {base_id=10715, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=415},
	[17] = {base_id=10716, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=416},
	[18] = {base_id=10717, catalg=2, init_price=21000, init_stock=300, max_price=63000, min_price=16800, open_lev=1, limit_type=0, limit_num=0, sort=417},
	[19] = {base_id=10718, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=418},
	[20] = {base_id=10719, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=419},
	[21] = {base_id=10720, catalg=2, init_price=21000, init_stock=300, max_price=63000, min_price=16800, open_lev=1, limit_type=0, limit_num=0, sort=420},
	[22] = {base_id=10721, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=421},
	[23] = {base_id=10722, catalg=2, init_price=31500, init_stock=300, max_price=94500, min_price=25200, open_lev=1, limit_type=0, limit_num=0, sort=422},
	[24] = {base_id=10723, catalg=2, init_price=31500, init_stock=300, max_price=94500, min_price=25200, open_lev=1, limit_type=0, limit_num=0, sort=423},
	[25] = {base_id=10724, catalg=2, init_price=31500, init_stock=300, max_price=94500, min_price=25200, open_lev=1, limit_type=0, limit_num=0, sort=424},
	[26] = {base_id=10725, catalg=2, init_price=26250, init_stock=300, max_price=78750, min_price=21000, open_lev=1, limit_type=0, limit_num=0, sort=425},
	[27] = {base_id=10726, catalg=2, init_price=42000, init_stock=300, max_price=126000, min_price=33600, open_lev=1, limit_type=0, limit_num=0, sort=426},
	[28] = {base_id=10727, catalg=2, init_price=42000, init_stock=300, max_price=126000, min_price=33600, open_lev=1, limit_type=0, limit_num=0, sort=427},
	[29] = {base_id=10728, catalg=2, init_price=21000, init_stock=300, max_price=63000, min_price=16800, open_lev=1, limit_type=0, limit_num=0, sort=428},
	[30] = {base_id=10729, catalg=2, init_price=21000, init_stock=300, max_price=63000, min_price=16800, open_lev=1, limit_type=0, limit_num=0, sort=429},
	[31] = {base_id=10730, catalg=2, init_price=16800, init_stock=300, max_price=50400, min_price=13440, open_lev=1, limit_type=0, limit_num=0, sort=430},
	[32] = {base_id=10731, catalg=2, init_price=52500, init_stock=300, max_price=157500, min_price=42000, open_lev=1, limit_type=0, limit_num=0, sort=431},
	[33] = {base_id=10732, catalg=2, init_price=31500, init_stock=300, max_price=94500, min_price=25200, open_lev=1, limit_type=0, limit_num=0, sort=432},
	[34] = {base_id=10733, catalg=2, init_price=35000, init_stock=301, max_price=105000, min_price=28000, open_lev=1, limit_type=0, limit_num=0, sort=433},
	[35] = {base_id=10734, catalg=2, init_price=35000, init_stock=302, max_price=105000, min_price=28000, open_lev=1, limit_type=0, limit_num=0, sort=434},
	[36] = {base_id=10735, catalg=2, init_price=35000, init_stock=303, max_price=105000, min_price=28000, open_lev=1, limit_type=0, limit_num=0, sort=435}
}
-- -------------------form_shop_list_end---------------------


-- -------------------break_shop_list_start-------------------
Config.MarketGoldData.data_break_shop_list_length = 16
Config.MarketGoldData.data_break_shop_list = {
	[1] = {base_id=10040, catalg=3, init_price=200, init_stock=10000, max_price=200, min_price=200, open_lev=1, limit_type=0, limit_num=0, sort=300},
	[2] = {base_id=10041, catalg=3, init_price=1000, init_stock=10000, max_price=1000, min_price=800, open_lev=1, limit_type=0, limit_num=0, sort=304},
	[3] = {base_id=10042, catalg=3, init_price=8000, init_stock=10000, max_price=8000, min_price=8000, open_lev=1, limit_type=0, limit_num=0, sort=308},
	[4] = {base_id=10043, catalg=3, init_price=40000, init_stock=10000, max_price=40000, min_price=40000, open_lev=1, limit_type=0, limit_num=0, sort=312},
	[5] = {base_id=10050, catalg=3, init_price=200, init_stock=10000, max_price=200, min_price=200, open_lev=1, limit_type=0, limit_num=0, sort=301},
	[6] = {base_id=10051, catalg=3, init_price=1000, init_stock=10000, max_price=1000, min_price=1000, open_lev=1, limit_type=0, limit_num=0, sort=305},
	[7] = {base_id=10052, catalg=3, init_price=8000, init_stock=10000, max_price=8000, min_price=8000, open_lev=1, limit_type=0, limit_num=0, sort=309},
	[8] = {base_id=10053, catalg=3, init_price=40000, init_stock=10000, max_price=40000, min_price=40000, open_lev=1, limit_type=0, limit_num=0, sort=313},
	[9] = {base_id=10060, catalg=3, init_price=200, init_stock=10000, max_price=200, min_price=200, open_lev=1, limit_type=0, limit_num=0, sort=302},
	[10] = {base_id=10061, catalg=3, init_price=1000, init_stock=10000, max_price=1000, min_price=1000, open_lev=1, limit_type=0, limit_num=0, sort=306},
	[11] = {base_id=10062, catalg=3, init_price=8000, init_stock=10000, max_price=8000, min_price=8000, open_lev=1, limit_type=0, limit_num=0, sort=310},
	[12] = {base_id=10063, catalg=3, init_price=40000, init_stock=10000, max_price=40000, min_price=40000, open_lev=1, limit_type=0, limit_num=0, sort=314},
	[13] = {base_id=10070, catalg=3, init_price=200, init_stock=10000, max_price=200, min_price=200, open_lev=1, limit_type=0, limit_num=0, sort=303},
	[14] = {base_id=10071, catalg=3, init_price=1000, init_stock=10000, max_price=1000, min_price=1000, open_lev=1, limit_type=0, limit_num=0, sort=307},
	[15] = {base_id=10072, catalg=3, init_price=8000, init_stock=10000, max_price=8000, min_price=8000, open_lev=1, limit_type=0, limit_num=0, sort=311},
	[16] = {base_id=10073, catalg=3, init_price=40000, init_stock=10000, max_price=40000, min_price=40000, open_lev=1, limit_type=0, limit_num=0, sort=315}
}
-- -------------------break_shop_list_end---------------------


-- -------------------other_shop_list_start-------------------
Config.MarketGoldData.data_other_shop_list_length = 5
Config.MarketGoldData.data_other_shop_list = {
	[1] = {base_id=10151, catalg=4, init_price=8000, init_stock=3000, max_price=24000, min_price=6400, open_lev=1, limit_type=2, limit_num=5, sort=2},
	[2] = {base_id=10152, catalg=4, init_price=20000, init_stock=3000, max_price=60000, min_price=16000, open_lev=1, limit_type=2, limit_num=2, sort=3},
	[3] = {base_id=10430, catalg=4, init_price=18000, init_stock=300, max_price=54000, min_price=14400, open_lev=1, limit_type=0, limit_num=0, sort=4},
	[4] = {base_id=10431, catalg=4, init_price=30000, init_stock=300, max_price=90000, min_price=24000, open_lev=1, limit_type=0, limit_num=0, sort=5},
	[5] = {base_id=14000, catalg=4, init_price=21000, init_stock=10000, max_price=21000, min_price=21000, open_lev=1, limit_type=0, limit_num=0, sort=6}
}
-- -------------------other_shop_list_end---------------------


-- -------------------hide_sell_list_start-------------------
Config.MarketGoldData.data_hide_sell_list_length = 6
Config.MarketGoldData.data_hide_sell_list = {
	[10202] = {name="寻宝券", price=3000, open_lev=10},
	[10422] = {name="圣灵法戒碎片", price=2700, open_lev=1},
	[10423] = {name="主神权杖碎片", price=10000, open_lev=1},
	[70001] = {name="晶钢凿", price=5000, open_lev=1},
	[10003] = {name="副本扫荡券", price=1000, open_lev=1},
	[10150] = {name="铜制钥匙", price=2000, open_lev=1}
}
-- -------------------hide_sell_list_end---------------------


-- -------------------stable_sell_list_start-------------------
Config.MarketGoldData.data_stable_sell_list_length = 1
Config.MarketGoldData.data_stable_sell_list = {
	[10207] = {name="小金币袋子", discount=800, open_lev=10}
}
-- -------------------stable_sell_list_end---------------------


-- -------------------change_sell_list_start-------------------
Config.MarketGoldData.data_change_sell_list_length = 1
Config.MarketGoldData.data_change_sell_list = {
	[10208] = {id=10208, name="大金币袋子", exchange_id=10207}
}
-- -------------------change_sell_list_end---------------------


-- -------------------explain_start-------------------
Config.MarketGoldData.data_explain_length = 2
Config.MarketGoldData.data_explain = {
	[1] = {id=1, title="金币市场相关", desc="1.金币市场所有商品的价格会随着买卖发生涨跌\n2.金币市场价格每日0点会进行调整\n3.游戏中获得的金币市场商品出售时会以当前价格的<div fontcolor=#a95f0f>0.9倍</div>获得金币"},
	[2] = {id=2, title="银币市场相关", desc="1.银币市场的商品可用于参与帮会远航玩法\n2.银币摆摊每个摊位最多可出售5件商品\n3.每个商品摆摊时间为24小时，若超时可点击重新上架"}
}
-- -------------------explain_end---------------------
