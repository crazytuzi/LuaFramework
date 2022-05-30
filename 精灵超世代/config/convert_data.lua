----------------------------------------------------
-- 此文件由数据工具生成
-- 兑换配置--convert_data.xml
--------------------------------------

Config = Config or {} 
Config.ConvertData = Config.ConvertData or {}

-- -------------------gold_exchange_start-------------------
Config.ConvertData.data_gold_exchange_length = 6
Config.ConvertData.data_gold_exchange = {
	[1] = {price=60, coin=6000},
	[2] = {price=300, coin=30000},
	[3] = {price=1280, coin=128000},
	[4] = {price=1980, coin=198000},
	[5] = {price=3280, coin=328000},
	[6] = {price=6480, coin=648000}
}
Config.ConvertData.data_gold_exchange_fun = function(key)
	local data=Config.ConvertData.data_gold_exchange[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ConvertData.data_gold_exchange['..key..'])not found') return
	end
	return data
end
-- -------------------gold_exchange_end---------------------


-- -------------------sliver_exchange_start-------------------
Config.ConvertData.data_sliver_exchange_length = 6
Config.ConvertData.data_sliver_exchange = {
	[1] = {price=60, silver_coin=600000},
	[2] = {price=300, silver_coin=3000000},
	[3] = {price=1280, silver_coin=12800000},
	[4] = {price=1980, silver_coin=19800000},
	[5] = {price=3280, silver_coin=32800000},
	[6] = {price=6480, silver_coin=64800000}
}
Config.ConvertData.data_sliver_exchange_fun = function(key)
	local data=Config.ConvertData.data_sliver_exchange[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ConvertData.data_sliver_exchange['..key..'])not found') return
	end
	return data
end
-- -------------------sliver_exchange_end---------------------


-- -------------------wish_reward_start-------------------
Config.ConvertData.data_wish_reward_length = 10
Config.ConvertData.data_wish_reward = {
	[1] = {max_count=1, min_count=1, price={{4,0}}, reward={{11,400}}, rate=50, vip=0},
	[2] = {max_count=2, min_count=2, price={{4,20}}, reward={{11,400}}, rate=50, vip=2},
	[3] = {max_count=3, min_count=3, price={{4,30}}, reward={{11,400}}, rate=50, vip=2},
	[4] = {max_count=4, min_count=4, price={{4,40}}, reward={{11,400}}, rate=55, vip=2},
	[5] = {max_count=6, min_count=5, price={{4,40}}, reward={{11,400}}, rate=60, vip=4},
	[7] = {max_count=8, min_count=7, price={{4,50}}, reward={{11,400}}, rate=65, vip=6},
	[9] = {max_count=10, min_count=9, price={{4,50}}, reward={{11,400}}, rate=70, vip=8},
	[11] = {max_count=12, min_count=11, price={{4,60}}, reward={{11,400}}, rate=75, vip=10},
	[13] = {max_count=14, min_count=13, price={{4,60}}, reward={{11,400}}, rate=80, vip=12},
	[15] = {max_count=16, min_count=15, price={{4,60}}, reward={{11,400}}, rate=90, vip=14}
}
Config.ConvertData.data_wish_reward_fun = function(key)
	local data=Config.ConvertData.data_wish_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ConvertData.data_wish_reward['..key..'])not found') return
	end
	return data
end
-- -------------------wish_reward_end---------------------


-- -------------------trade_cost_start-------------------
Config.ConvertData.data_trade_cost_length = 5
Config.ConvertData.data_trade_cost = {
	["reward_num"] = {key="reward_num", val=10, desc="X次进行循环奖励"},
	["times_reward"] = {key="times_reward", val={{11,500}}, desc="奖励内容"},
	["pray_rules"] = {key="pray_rules", val=0, desc="1、每天首次许愿免费。\n2、可消耗红蓝钻进行许愿，许愿有概率<div fontsize=24 fontcolor=#289b14>暴击</div>，使下一次获取奖励翻倍。\n3、提升VIP等级可增加许愿次数。\n4、许愿次数在5点刷新"},
	["point_gold_refresh"] = {key="point_gold_refresh", val={{0,0,0},{9,0,0},{19,0,0}}, desc="点金刷新时间（秒）"},
	["red_lev_min"] = {key="red_lev_min", val=6, desc="点金红点显示等级限制"}
}
Config.ConvertData.data_trade_cost_fun = function(key)
	local data=Config.ConvertData.data_trade_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ConvertData.data_trade_cost['..key..'])not found') return
	end
	return data
end
-- -------------------trade_cost_end---------------------


-- -------------------exchange_start-------------------
Config.ConvertData.data_exchange_length = 2
Config.ConvertData.data_exchange = {
	[0] = {
		[1] = {type=0, id=1, price=0, time=60, coin=10000, num=1},
		[2] = {type=0, id=2, price=20, time=120, coin=20000, num=1},
		[3] = {type=0, id=3, price=50, time=300, coin=50000, num=1},
	},
	[1] = {
		[1] = {type=1, id=1, price=0, time=60, coin=10000, num=3},
		[2] = {type=1, id=2, price=20, time=120, coin=20000, num=10},
		[3] = {type=1, id=3, price=50, time=300, coin=50000, num=10},
	},
}
-- -------------------exchange_end---------------------
