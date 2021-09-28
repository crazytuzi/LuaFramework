local Items = {
	{q_id = 40002,q_name = '赠送他人玫瑰花',q_desc = '赠人玫瑰手有余香！今日行会发布任务：赠送他人玫瑰花50次',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = '17_50',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40004,q_name = '发布悬赏任务',q_desc = '幽影阁需要你的支持！今日行会发布任务：发布悬赏任务200次',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = '34_200',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40005,q_name = '完成悬赏任务',q_desc = '幽影阁需要你的支持！今日行会发布任务：完成悬赏任务200次',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = '36_200',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40006,q_name = '护送镖车',q_desc = '守护与责任也是一种力量！今日行会发布任务：护送镖车50次',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = '46_50',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40009,q_name = '沙漠行动',q_desc = '为了保护热砂荒漠旅人安全！今日行会发布任务：在热砂荒漠击杀怪物2000个',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = 0,q_end_need_killmonster = '@5251,5254,5265,5255,5264_2000_3100_18_159',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40010,q_name = '勇闯将军坟',q_desc = '为了维护将军坟安宁！今日行会发布任务：在将军坟击杀怪物2000个',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = 0,q_end_need_killmonster = '@1017,5266,5253,5252_2000_2110_42_40',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40011,q_name = '清剿机关洞',q_desc = '为了维护机关洞安宁！今日行会发布任务：在机关洞击杀怪物2000个',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = 0,q_end_need_killmonster = '@10001,6008,620,10017,621,1028,1033,1031,10015,1036,1037,1038,1035,10016,10018_2000_2130_88_60',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40012,q_name = '清剿矿区',q_desc = '为了维护矿区安宁！今日行会发布任务：在矿区和尸王殿击杀怪物2000个',q_recieveLeveMin = 1,q_recieveLeveMax = 3,q_done_event = 0,q_end_need_killmonster = '@356,358,359,312,315,313,354,355,357_2000_2126_41_101',q_rewards_facMoney = 1000,q_rewards_facCon = 30,},
	{q_id = 40014,q_name = '赠送他人玫瑰花',q_desc = '赠人玫瑰手有余香！今日行会发布任务：赠送他人玫瑰花80次',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = '17_80',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40016,q_name = '发布悬赏任务',q_desc = '幽影阁需要你的支持！今日行会发布任务：发布悬赏任务300次',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = '34_300',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40017,q_name = '完成悬赏任务',q_desc = '幽影阁需要你的支持！今日行会发布任务：完成悬赏任务300次',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = '36_300',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40018,q_name = '护送镖车',q_desc = '守护与责任也是一种力量！今日行会发布任务：护送镖车80次',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = '46_80',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40021,q_name = '沙漠行动',q_desc = '为了保护热砂荒漠旅人安全！今日行会发布任务：在热砂荒漠击杀怪物5000个',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = 0,q_end_need_killmonster = '@5251,5254,5265,5255,5264_5000_3100_18_159',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40022,q_name = '勇闯将军坟',q_desc = '为了维护将军坟安宁！今日行会发布任务：在将军坟击杀怪物5000个',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = 0,q_end_need_killmonster = '@1017,5266,5253,5252_5000_2110_42_40',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40023,q_name = '清剿机关洞',q_desc = '为了维护机关洞安宁！今日行会发布任务：在机关洞击杀怪物5000个',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = 0,q_end_need_killmonster = '@10001,6008,620,10017,621,1028,1033,1031,10015,1036,1037,1038,1035,10016,10018_5000_2130_88_60',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40024,q_name = '清剿矿区',q_desc = '为了维护矿区安宁！今日行会发布任务：在矿区和尸王殿击杀怪物5000个',q_recieveLeveMin = 4,q_recieveLeveMax = 6,q_done_event = 0,q_end_need_killmonster = '@356,358,359,312,315,313,354,355,357_5000_2126_41_101',q_rewards_facMoney = 1500,q_rewards_facCon = 60,},
	{q_id = 40026,q_name = '赠送他人玫瑰花',q_desc = '赠人玫瑰手有余香！今日行会发布任务：赠送他人玫瑰花120次',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = '17_120',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40028,q_name = '发布悬赏任务',q_desc = '幽影阁需要你的支持！今日行会发布任务：发布悬赏任务400次',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = '34_400',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40029,q_name = '完成悬赏任务',q_desc = '幽影阁需要你的支持！今日行会发布任务：完成悬赏任务400次',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = '36_400',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40030,q_name = '护送镖车',q_desc = '守护与责任也是一种力量！今日行会发布任务：护送镖车120次',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = '46_120',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40033,q_name = '沙漠行动',q_desc = '为了保护热砂荒漠旅人安全！今日行会发布任务：在热砂荒漠击杀怪物10000个',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = 0,q_end_need_killmonster = '@5251,5254,5265,5255,5264_10000_3100_18_159',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40034,q_name = '勇闯将军坟',q_desc = '为了维护将军坟安宁！今日行会发布任务：在将军坟击杀怪物10000个',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = 0,q_end_need_killmonster = '@1017,5266,5253,5252_10000_2110_42_40',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40035,q_name = '清剿机关洞',q_desc = '为了维护机关洞安宁！今日行会发布任务：在机关洞击杀怪物10000个',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = 0,q_end_need_killmonster = '@10001,6008,620,10017,621,1028,1033,1031,10015,1036,1037,1038,1035,10016,10018_10000_2130_88_60',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
	{q_id = 40036,q_name = '清剿矿区',q_desc = '为了维护矿区安宁！今日行会发布任务：在矿区和尸王殿击杀怪物10000个',q_recieveLeveMin = 7,q_recieveLeveMax = 9,q_done_event = 0,q_end_need_killmonster = '@356,358,359,312,315,313,354,355,357_10000_2126_41_101',q_rewards_facMoney = 2000,q_rewards_facCon = 90,},
};
return Items
