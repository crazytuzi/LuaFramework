----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_lanterm_festival_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayLantermFestivalData = Config.HolidayLantermFestivalData or {}

-- -------------------constant_start-------------------
Config.HolidayLantermFestivalData.data_constant_length = 3
Config.HolidayLantermFestivalData.data_constant = {
	["awards_4_expend"] = {val={80201,20}, desc="4奖池消耗"},
	["awards_expend_items"] = {val=80201, desc="抽奖道具"},
	["holiday_content_tips"] = {val={}, desc="1.通过节日期间各类玩法可以获得「元宵花灯」。\n2.消耗「元宵花灯」可以进行抽奖，共有「纳福灯」「祈愿灯」「丰登灯」三个抽奖池可以抽取，其中「祈愿灯」与「丰登灯」分别需要累计消耗「元宵花灯」100，200个才能开启\n3.每种花灯各项物品的抽取概率相等，获取后的物品不会重复获得\n4.所有物品都抽取完成后，还能继续抽取「小花灯」，小花灯没有数量限制，会随机掉落一些成长道具。\n5.活动结束后，未使用的「元宵花灯」将无法继续使用，请大人及时使用"}
}
Config.HolidayLantermFestivalData.data_constant_fun = function(key)
	local data=Config.HolidayLantermFestivalData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayLantermFestivalData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------consume_num_start-------------------
Config.HolidayLantermFestivalData.data_consume_num_length = 4
Config.HolidayLantermFestivalData.data_consume_num = {
	[1] = {id=1, need_num=0},
	[2] = {id=2, need_num=100},
	[3] = {id=3, need_num=200},
	[4] = {id=4, need_num=645}
}
Config.HolidayLantermFestivalData.data_consume_num_fun = function(key)
	local data=Config.HolidayLantermFestivalData.data_consume_num[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayLantermFestivalData.data_consume_num['..key..'])not found') return
	end
	return data
end
-- -------------------consume_num_end---------------------


-- -------------------consume_list_start-------------------
Config.HolidayLantermFestivalData.data_consume_list_length = 3
Config.HolidayLantermFestivalData.data_consume_list = {
	[1] = {
		[1] = {id=1, count=1, expend=0},
		[2] = {id=1, count=2, expend=5},
		[3] = {id=1, count=3, expend=10},
		[4] = {id=1, count=4, expend=10},
		[5] = {id=1, count=5, expend=15},
		[6] = {id=1, count=6, expend=15},
		[7] = {id=1, count=7, expend=20},
		[8] = {id=1, count=8, expend=20},
		[9] = {id=1, count=9, expend=20},
		[10] = {id=1, count=10, expend=20},
		[11] = {id=1, count=11, expend=40},
		[12] = {id=1, count=12, expend=40},
	},
	[2] = {
		[1] = {id=2, count=1, expend=0},
		[2] = {id=2, count=2, expend=5},
		[3] = {id=2, count=3, expend=10},
		[4] = {id=2, count=4, expend=10},
		[5] = {id=2, count=5, expend=15},
		[6] = {id=2, count=6, expend=15},
		[7] = {id=2, count=7, expend=20},
		[8] = {id=2, count=8, expend=20},
		[9] = {id=2, count=9, expend=20},
		[10] = {id=2, count=10, expend=20},
		[11] = {id=2, count=11, expend=40},
		[12] = {id=2, count=12, expend=40},
	},
	[3] = {
		[1] = {id=3, count=1, expend=0},
		[2] = {id=3, count=2, expend=5},
		[3] = {id=3, count=3, expend=10},
		[4] = {id=3, count=4, expend=10},
		[5] = {id=3, count=5, expend=15},
		[6] = {id=3, count=6, expend=15},
		[7] = {id=3, count=7, expend=20},
		[8] = {id=3, count=8, expend=20},
		[9] = {id=3, count=9, expend=20},
		[10] = {id=3, count=10, expend=20},
		[11] = {id=3, count=11, expend=40},
		[12] = {id=3, count=12, expend=40},
	},
}
-- -------------------consume_list_end---------------------


-- -------------------rand_list_start-------------------
Config.HolidayLantermFestivalData.data_rand_list_length = 4
Config.HolidayLantermFestivalData.data_rand_list = {
	[1] = {
		[1] = {id=1, award_id=1, item_id=37002, item_num=1, order=1, pro=200, must_no_count=4, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[2] = {id=1, award_id=2, item_id=40108, item_num=1, order=2, pro=200, must_no_count=3, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[3] = {id=1, award_id=3, item_id=10403, item_num=1, order=3, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[4] = {id=1, award_id=4, item_id=10403, item_num=1, order=4, pro=200, must_no_count=8, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[5] = {id=1, award_id=5, item_id=3, item_num=50, order=5, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[6] = {id=1, award_id=6, item_id=3, item_num=50, order=6, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[7] = {id=1, award_id=7, item_id=3, item_num=50, order=7, pro=200, must_no_count=5, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[8] = {id=1, award_id=8, item_id=3, item_num=50, order=8, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[9] = {id=1, award_id=9, item_id=10001, item_num=50, order=9, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[10] = {id=1, award_id=10, item_id=10001, item_num=50, order=10, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[11] = {id=1, award_id=11, item_id=10001, item_num=50, order=11, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[12] = {id=1, award_id=12, item_id=10001, item_num=50, order=12, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
	},
	[2] = {
		[13] = {id=2, award_id=13, item_id=14001, item_num=1, order=1, pro=200, must_no_count=6, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[14] = {id=2, award_id=14, item_id=40108, item_num=1, order=2, pro=200, must_no_count=3, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[15] = {id=2, award_id=15, item_id=10403, item_num=1, order=3, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[16] = {id=2, award_id=16, item_id=10403, item_num=1, order=4, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[17] = {id=2, award_id=17, item_id=3, item_num=50, order=5, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[18] = {id=2, award_id=18, item_id=3, item_num=50, order=6, pro=200, must_no_count=5, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[19] = {id=2, award_id=19, item_id=3, item_num=50, order=7, pro=200, must_no_count=1, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[20] = {id=2, award_id=20, item_id=3, item_num=50, order=8, pro=200, must_no_count=8, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[21] = {id=2, award_id=21, item_id=37001, item_num=1, order=9, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[22] = {id=2, award_id=22, item_id=37001, item_num=1, order=10, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[23] = {id=2, award_id=23, item_id=37001, item_num=1, order=11, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[24] = {id=2, award_id=24, item_id=37001, item_num=1, order=12, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
	},
	[3] = {
		[25] = {id=3, award_id=25, item_id=50901, item_num=1, order=1, pro=200, must_no_count=7, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[26] = {id=3, award_id=26, item_id=40108, item_num=1, order=2, pro=200, must_no_count=5, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[27] = {id=3, award_id=27, item_id=10403, item_num=1, order=3, pro=200, must_no_count=2, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[28] = {id=3, award_id=28, item_id=10403, item_num=1, order=4, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[29] = {id=3, award_id=29, item_id=3, item_num=50, order=5, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[30] = {id=3, award_id=30, item_id=3, item_num=50, order=6, pro=200, must_no_count=9, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[31] = {id=3, award_id=31, item_id=3, item_num=50, order=7, pro=200, must_no_count=8, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[32] = {id=3, award_id=32, item_id=3, item_num=50, order=8, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=1},
		[33] = {id=3, award_id=33, item_id=10450, item_num=50, order=9, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[34] = {id=3, award_id=34, item_id=10450, item_num=50, order=10, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[35] = {id=3, award_id=35, item_id=10450, item_num=50, order=11, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
		[36] = {id=3, award_id=36, item_id=10450, item_num=50, order=12, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=1, effect=0},
	},
	[4] = {
		[37] = {id=4, award_id=37, item_id=37001, item_num=1, order=1, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[38] = {id=4, award_id=38, item_id=37001, item_num=1, order=2, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[39] = {id=4, award_id=39, item_id=37001, item_num=1, order=3, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[40] = {id=4, award_id=40, item_id=10001, item_num=50, order=4, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[41] = {id=4, award_id=41, item_id=10001, item_num=50, order=5, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[42] = {id=4, award_id=42, item_id=10001, item_num=50, order=6, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[43] = {id=4, award_id=43, item_id=10002, item_num=1, order=7, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[44] = {id=4, award_id=44, item_id=10002, item_num=1, order=8, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[45] = {id=4, award_id=45, item_id=10002, item_num=1, order=9, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[46] = {id=4, award_id=46, item_id=10450, item_num=50, order=10, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[47] = {id=4, award_id=47, item_id=10450, item_num=50, order=11, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
		[48] = {id=4, award_id=48, item_id=10450, item_num=50, order=12, pro=200, must_no_count=0, min_open_day=7, max_open_day=9999, limit_count=999, effect=1},
	},
}
-- -------------------rand_list_end---------------------
