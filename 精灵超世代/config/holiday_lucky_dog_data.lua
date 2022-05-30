----------------------------------------------------
-- 此文件由数据工具生成
-- 精英赛配置数据--holiday_lucky_dog_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayLuckyDogData = Config.HolidayLuckyDogData or {}

-- -------------------constant_start-------------------
Config.HolidayLuckyDogData.data_constant_length = 1
Config.HolidayLuckyDogData.data_constant = {
	["rules"] = {code="rules", val=1, desc="1.活动时间：2020年1月23日-29日\n2.活动期间，完成幸运锦鲤任务，即可获得锦鲤号码，参与号码抽奖！\n3.开奖时间为<div fontcolor=289b14>当天晚上的23:50</div>，若你当期获取的号码与开奖号码一样，恭喜你获得大奖！没有中奖也不要灰心，其他号码也能获得安慰幸运奖哦！\n4.每位冒险者大人获取的3个锦鲤任务，要在<div fontcolor=289b14>开奖前（23：50）完成</div>任务获得的号码才能参与幸运锦鲤开奖！赶快行动起来吧！"}
}
Config.HolidayLuckyDogData.data_constant_fun = function(key)
	local data=Config.HolidayLuckyDogData.data_constant[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayLuckyDogData.data_constant['..key..'])not found') return
	end
	return data
end
-- -------------------constant_end---------------------


-- -------------------period_start-------------------
Config.HolidayLuckyDogData.data_period_length = 7
Config.HolidayLuckyDogData.data_period = {
	[1] = {period=1, quest_ids={101,108,109}, open_time="1月23日23：50"},
	[2] = {period=2, quest_ids={102,108,109}, open_time="1月24日23：50"},
	[3] = {period=3, quest_ids={103,108,109}, open_time="1月25日23：50"},
	[4] = {period=4, quest_ids={104,108,109}, open_time="1月26日23：50"},
	[5] = {period=5, quest_ids={105,108,109}, open_time="1月27日23：50"},
	[6] = {period=6, quest_ids={106,108,109}, open_time="1月28日23：50"},
	[7] = {period=7, quest_ids={107,108,109}, open_time="1月29日23：50"}
}
Config.HolidayLuckyDogData.data_period_fun = function(key)
	local data=Config.HolidayLuckyDogData.data_period[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayLuckyDogData.data_period['..key..'])not found') return
	end
	return data
end
-- -------------------period_end---------------------


-- -------------------quest_start-------------------
Config.HolidayLuckyDogData.data_quest_length = 9
Config.HolidayLuckyDogData.data_quest = {
	[101] = {quest_id=101, condition={'evt_arena_fight_result',0,5,{}}, desc="竞技场胜利五次", jump_id=3},
	[102] = {quest_id=102, condition={'evt_high_recruit',0,2,{}}, desc="高级召唤两次", jump_id=1},
	[103] = {quest_id=103, condition={'evt_dungeon_fast_combat',0,2,{}}, desc="快速作战2次", jump_id=11},
	[104] = {quest_id=104, condition={'evt_dial',0,10,{}}, desc="幸运寻宝十次", jump_id=40},
	[105] = {quest_id=105, condition={'evt_dungeon_stone_fight',0,6,{}}, desc="日常副本6次", jump_id=17},
	[106] = {quest_id=106, condition={'evt_friend_present',0,5,{}}, desc="赠送好友友情点5次", jump_id=4},
	[107] = {quest_id=107, condition={'evt_arena_fight_result',0,5,{}}, desc="竞技场胜利五次", jump_id=3},
	[108] = {quest_id=108, condition={'evt_share_game',0,1,{}}, desc="分享一次游戏", jump_id=69},
	[109] = {quest_id=109, condition={'charge_rmb',0,6,{}}, desc="累充6元", jump_id=7}
}
Config.HolidayLuckyDogData.data_quest_fun = function(key)
	local data=Config.HolidayLuckyDogData.data_quest[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayLuckyDogData.data_quest['..key..'])not found') return
	end
	return data
end
-- -------------------quest_end---------------------


-- -------------------quest_award_start-------------------
Config.HolidayLuckyDogData.data_quest_award_length = 7
Config.HolidayLuckyDogData.data_quest_award = {
	[1] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=766},
		[2] = {award={{3,300},{10403,1}}, limit_number=52},
		[3] = {award={{3,100}}, limit_number=8},
		[4] = {award={{3,50}}, limit_number=0},
	},
	[2] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=958},
		[2] = {award={{3,300},{10403,1}}, limit_number=33},
		[3] = {award={{3,100}}, limit_number=2},
		[4] = {award={{3,50}}, limit_number=0},
	},
	[3] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=673},
		[2] = {award={{3,300},{10403,1}}, limit_number=21},
		[3] = {award={{3,100}}, limit_number=6},
		[4] = {award={{3,50}}, limit_number=0},
	},
	[4] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=649},
		[2] = {award={{3,300},{10403,1}}, limit_number=52},
		[3] = {award={{3,100}}, limit_number=3},
		[4] = {award={{3,50}}, limit_number=0},
	},
	[5] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=238},
		[2] = {award={{3,300},{10403,1}}, limit_number=79},
		[3] = {award={{3,100}}, limit_number=1},
		[4] = {award={{3,50}}, limit_number=0},
	},
	[6] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=309},
		[2] = {award={{3,300},{10403,1}}, limit_number=68},
		[3] = {award={{3,100}}, limit_number=5},
		[4] = {award={{3,50}}, limit_number=0},
	},
	[7] = {
		[1] = {award={{3,500},{14001,1}}, limit_number=202},
		[2] = {award={{3,300},{10403,1}}, limit_number=86},
		[3] = {award={{3,100}}, limit_number=9},
		[4] = {award={{3,50}}, limit_number=0},
	},
}
-- -------------------quest_award_end---------------------
