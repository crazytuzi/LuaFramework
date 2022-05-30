----------------------------------------------------
-- 此文件由数据工具生成
-- 情人节大作战--holiday_valentines_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayValentinesData = Config.HolidayValentinesData or {}

-- -------------------const_start-------------------
Config.HolidayValentinesData.data_const_length = 11
Config.HolidayValentinesData.data_const = {
	["base_max_score"] = {val=100000, desc="基础积分上限"},
	["score_item_id"] = {val=81001, desc="积分道具id"},
	["holiday_item1"] = {val=81002, desc="奶油道具id"},
	["holiday_item2"] = {val=81003, desc="糖果道具id"},
	["holiday_item3"] = {val=81004, desc="心形巧克力id"},
	["holiday_score1"] = {val=1, desc="奶油对应贡献积分"},
	["holiday_score2"] = {val=5, desc="糖果对应贡献积分"},
	["holiday_score3"] = {val=10, desc="心形巧克力对应贡献积分"},
	["holiday_quester"] = {val=93018, desc="情人节任务活动id"},
	["item_gain"] = {val=991048, desc="情人节道具获取id"},
	["holiday_rule"] = {val=1, desc="<div fontcolor=#fca000>活动时间：</div>2月13日至2月19日24点\n<div fontcolor=#fca000>玩法说明：</div>\n1.活动期间，通过完成情人节任务（巧克力猎人）获取道具，向巧克力蛋糕捐献道具（奶油/糖果/巧克力），可增加蛋糕经验从而提升蛋糕等级，同时也能获得<div fontcolor=#00ff00>个人积分</div>与<div fontcolor=#00ff00>积分币</div>\n2.蛋糕每提升一级，解锁的等级奖励就会更丰厚，全服可领，全民一起努力更容易获得奖励哦！\n3.捐献越多的冒险者排名越高，甜蜜积分排行榜在活动结束后会结算排行奖励，请在邮件查收哦\n4.积分币可在情人节<div fontcolor=#00ff00>积分币商城</div>兑换奖励，积分币的使用不会减少排行榜个人积分，<div fontcolor=#00ff00>2月19日24点活动结束后积分币会清零</div>，请及时使用！\n5.积分计算规则：1奶油=1积分，1糖果=5积分，1巧克力=10积分，1积分=1甜蜜积分币"}
}
Config.HolidayValentinesData.data_const_fun = function(key)
	local data=Config.HolidayValentinesData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayValentinesData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------award_start-------------------
Config.HolidayValentinesData.data_award_length = 7
Config.HolidayValentinesData.data_award = {
	[1] = {id=1, count=160, award={{37001,5}}},
	[2] = {id=2, count=300, award={{10403,2}}},
	[3] = {id=3, count=440, award={{37002,1}}},
	[4] = {id=4, count=580, award={{10403,3}}},
	[5] = {id=5, count=720, award={{37002,1}}},
	[6] = {id=6, count=860, award={{3,500}}},
	[7] = {id=7, count=1000, award={{29905,50}}}
}
Config.HolidayValentinesData.data_award_fun = function(key)
	local data=Config.HolidayValentinesData.data_award[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayValentinesData.data_award['..key..'])not found') return
	end
	return data
end
-- -------------------award_end---------------------


-- -------------------rank_award_start-------------------
Config.HolidayValentinesData.data_rank_award_length = 6
Config.HolidayValentinesData.data_rank_award = {
{rank1=1, rank2=1, award={{50033,1},{10,5000}}},
{rank1=2, rank2=2, award={{50033,1},{10,4000}}},
{rank1=3, rank2=3, award={{50033,1},{10,3000}}},
{rank1=4, rank2=5, award={{50033,1},{10,2000}}},
{rank1=6, rank2=10, award={{50033,1},{10,1500}}},
{rank1=11, rank2=25, award={{50033,1},{10,1000}}}
}
-- -------------------rank_award_end---------------------
