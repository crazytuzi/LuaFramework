----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--holiday_dial_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayDialData = Config.HolidayDialData or {}

-- -------------------dial_const_start-------------------
Config.HolidayDialData.data_dial_const_length = 8
Config.HolidayDialData.data_dial_const = {
	["cost_once"] = {key="cost_once", val=100, desc="抽取一次消耗钻石"},
	["cost_ten"] = {key="cost_ten", val=1000, desc="抽取十次消耗钻石"},
	["lottery_ticket"] = {key="lottery_ticket", val=37003, desc="抽奖券ID"},
	["holiday_rule"] = {key="holiday_rule", val=1, desc="<div fontcolor=#fca000>玩法说明：</div><div fontcolor=#e7d499>\n1.活动期间消耗</div><div fontcolor=#00ff00>星辰钥匙</div><div fontcolor=#e7d499>可进行转盘抽奖，每次抽奖可获得</div><div fontcolor=#00ff00>1</div><div fontcolor=#e7d499>积分，积分达到要求可获得</div><div fontcolor=#00ff00>相应奖励</div><div fontcolor=#e7d499>\n2.全服玩家每次抽奖会有</div><div fontcolor=#00ff00>10</div><div fontcolor=#e7d499>钻石归入奖池中，若喜中</div><div fontcolor=#00ff00>一、二、三等奖</div><div fontcolor=#e7d499>后，将获得当前奖池</div><div fontcolor=#00ff00>50%、20%、10%</div><div fontcolor=#e7d499>比例钻石</div><div fontcolor=#fca000>\n概率公示：</div><div fontcolor=#e7d499>\n强力英雄整卡:</div><div fontcolor=#00ff00>2.85%</div><div fontcolor=#e7d499>\n钻石奖励:</div><div fontcolor=#00ff00>6.75%</div><div fontcolor=#e7d499>\n高级召唤券:</div><div fontcolor=#00ff00>5.0%</div><div fontcolor=#e7d499>\n符文精华:</div><div fontcolor=#00ff00>41.15%</div><div fontcolor=#e7d499>\n炼神石:</div><div fontcolor=#00ff00>12.10%</div><div fontcolor=#e7d499>\n5星随机碎片*1:</div><div fontcolor=#00ff00>33.0%</div>"},
	["continue_time"] = {key="continue_time", val=10, desc="连抽次数"},
	["min_reward"] = {key="min_reward", val=1000, desc="保底奖池钻石"},
	["bouns_add"] = {key="bouns_add", val=10, desc="单抽奖池增加钻石"},
	["item_price"] = {key="item_price", val=100, desc="抽奖道具兑换价值"}
}
Config.HolidayDialData.data_dial_const_fun = function(key)
	local data=Config.HolidayDialData.data_dial_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayDialData.data_dial_const['..key..'])not found') return
	end
	return data
end
-- -------------------dial_const_end---------------------


-- -------------------score_award_start-------------------
Config.HolidayDialData.data_score_award_length = 8
Config.HolidayDialData.data_score_award = {
	[8] = {{id=8, num=1200, award_list={{72109,1}}, limit_lev_min=0, limit_lev_max=999}
	},
	[7] = {{id=7, num=800, award_list={{10450,5000}}, limit_lev_min=0, limit_lev_max=999}
	},
	[6] = {{id=6, num=500, award_list={{27907,50}}, limit_lev_min=0, limit_lev_max=999}
	},
	[5] = {{id=5, num=200, award_list={{10450,2000}}, limit_lev_min=0, limit_lev_max=999}
	},
	[4] = {{id=4, num=100, award_list={{29905,50}}, limit_lev_min=0, limit_lev_max=999}
	},
	[3] = {{id=3, num=50, award_list={{10450,1000}}, limit_lev_min=0, limit_lev_max=999}
	},
	[2] = {{id=2, num=30, award_list={{38080,1}}, limit_lev_min=0, limit_lev_max=999}
	},
	[1] = {{id=1, num=10, award_list={{10450,100}}, limit_lev_min=0, limit_lev_max=999}
	},
}
-- -------------------score_award_end---------------------


-- -------------------dial_item_start-------------------
Config.HolidayDialData.data_dial_item_length = 12
Config.HolidayDialData.data_dial_item = {
	[12] = {{order=12, id=25907, other_type=0, limit_lev_min=0, limit_lev_max=999, num=50, percent=0}
	},
	[11] = {{order=11, id=29905, other_type=0, limit_lev_min=0, limit_lev_max=999, num=50, percent=0}
	},
	[10] = {{order=10, id=3, other_type=3, limit_lev_min=0, limit_lev_max=999, num=0, percent=100}
	},
	[9] = {{order=9, id=72001, other_type=0, limit_lev_min=0, limit_lev_max=999, num=10, percent=0}
	},
	[8] = {{order=8, id=29905, other_type=0, limit_lev_min=0, limit_lev_max=999, num=1, percent=0}
	},
	[7] = {{order=7, id=3, other_type=2, limit_lev_min=0, limit_lev_max=999, num=0, percent=200}
	},
	[6] = {{order=6, id=10450, other_type=0, limit_lev_min=0, limit_lev_max=999, num=100, percent=0}
	},
	[5] = {{order=5, id=10450, other_type=0, limit_lev_min=0, limit_lev_max=999, num=200, percent=0}
	},
	[4] = {{order=4, id=3, other_type=1, limit_lev_min=0, limit_lev_max=999, num=0, percent=500}
	},
	[3] = {{order=3, id=10450, other_type=0, limit_lev_min=0, limit_lev_max=999, num=500, percent=0}
	},
	[2] = {{order=2, id=10403, other_type=0, limit_lev_min=0, limit_lev_max=999, num=1, percent=0}
	},
	[1] = {{order=1, id=27907, other_type=9, limit_lev_min=0, limit_lev_max=999, num=50, percent=0}
	},
}
-- -------------------dial_item_end---------------------
