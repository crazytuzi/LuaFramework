-- this file is generated by program!
-- don't change it manaully.
-- source file: guild_war_data.xls

Config = Config or {} 
Config.GuildWarData = Config.GuildWarData or {}
Config.GuildWarData.data_const_key_depth = 1
Config.GuildWarData.data_const_length = 36
Config.GuildWarData.data_const_lan = "zh"
Config.GuildWarData.data_const = {
	["active_member_condition"] = {key="active_member_condition",val=5,desc="联盟战离线X天及以上的玩家不能参与"},
	["active_member_num"] = {key="active_member_num",val=1,desc="参赛所需活跃人数要求"},
	["battle_duration"] = {key="battle_duration",val=132,desc="联盟战持续时间，单位：小时"},
	["box_rule"] = {key="box_rule",val=1,desc="1.宝箱在联盟战结束后产生，只有参与了联盟战的联盟才可获得\n2.宝箱共两种：胜利方的<div fontcolor=289b14>黄金宝箱</div>、失败方的<div fontcolor=289b14>青铜宝箱</div>\n3.宝箱数量根据本联盟活跃人数产生（1比1），只有活跃成员才可开启宝箱，且每人只可开启1次\n4.玩家开启宝箱后可获得一定量<div fontcolor=289b14>联盟贡献</div>，且有概率开启获得大量联盟贡献。"},
	["box_time_limit"] = {key="box_time_limit",val=28800,desc="宝箱持续时间，单位：秒"},
	["challange_time_limit"] = {key="challange_time_limit",val=2,desc="挑战次数上限"},
	["clear_time"] = {key="clear_time",val={0,0,0},desc="完全结束时间节点"},
	["easy_diff_addition"] = {key="easy_diff_addition",val=900,desc="简单难度属性修正系数"},
	["easy_difficulty"] = {key="easy_difficulty",val=900,desc="战绩计算难度系数（简单）"},
	["end_time"] = {key="end_time",val={20,0,0},desc="结束时间节点"},
	["guard_id"] = {key="guard_id",val=81001,desc="中立守卫怪物ID"},
	["guild_lose_reward"] = {key="guild_lose_reward",val={{10,400},{1,30000}},desc="失败方全盟邮件奖励"},
	["guild_win_reward"] = {key="guild_win_reward",val={{10,666},{1,50000}},desc="胜利方全盟邮件奖励"},
	["hard_diff_addition"] = {key="hard_diff_addition",val=1100,desc="困难难度属性修正系数"},
	["hard_difficulty"] = {key="hard_difficulty",val=1100,desc="战绩计算难度系数（困难）"},
	["limit_lev"] = {key="limit_lev",val=1,desc="联盟3级开启"},
	["limit_open_time"] = {key="limit_open_time",val=1,desc="开服满3天后开放"},
	["lose_guard_record"] = {key="lose_guard_record",val=1,desc="挑战据点失败获得的战绩"},
	["lose_ruins_record"] = {key="lose_ruins_record",val=1,desc="挑战废墟失败获得的战绩"},
	["lose_strongholds_reward_easy"] = {key="lose_strongholds_reward_easy",val={{1,5000}},desc="挑战据点失败奖励_简单"},
	["lose_strongholds_reward_hard"] = {key="lose_strongholds_reward_hard",val={{1,15000}},desc="挑战据点失败奖励_困难"},
	["lose_strongholds_reward_normal"] = {key="lose_strongholds_reward_normal",val={{1,9000}},desc="挑战据点失败奖励_普通"},
	["marketplace_rule"] = {key="marketplace_rule",val=1,desc="1.联盟宝库奖励：在联盟战中取得胜利的一方将会获得联盟宝库奖励，这部分奖励物品不会直接放入玩家的背包，而是放入联盟宝库中成为可供玩家兑换的商品。联盟宝库奖励分为固定掉落奖励和随机掉落奖励，固定掉落奖励为必定掉落，随机掉落奖励为从奖励池中随机抽取<div fontcolor=289b14>1</div>件物品掉落。\n2.战绩奖励：取决于成员在联盟内的战绩排行，排名越高奖励越丰厚，奖励在联盟战结束后结算并通过邮件形式发放"},
	["matching_time"] = {key="matching_time",val={{1,4,0},{3,4,0},{5,4,0}},desc="每周几几点匹配{周几,时,分}"},
	["normal_diff_addition"] = {key="normal_diff_addition",val=1000,desc="普通难度属性修正系数"},
	["normal_difficulty"] = {key="normal_difficulty",val=1000,desc="战绩计算难度系数（普通）"},
	["operation_coefficient_1"] = {key="operation_coefficient_1",val=1000,desc="战绩计算变量1"},
	["operation_coefficient_2"] = {key="operation_coefficient_2",val=1000,desc="战绩计算变量2"},
	["ruins_challange_limit"] = {key="ruins_challange_limit",val=5,desc="废墟被挑战次数上限"},
	["start_time"] = {key="start_time",val={12,0,0},desc="开战时间节点"},
	["time_desc"] = {key="time_desc",val=0,desc="每周一、周三、周五12:00-20:00进行"},
	["treasure_item_amount"] = {key="treasure_item_amount",val=1,desc="宝库随机掉落奖励的数量"},
	["win_ruins_record"] = {key="win_ruins_record",val=5,desc="挑战废墟成功获得的战绩"},
	["win_strongholds_reward_easy"] = {key="win_strongholds_reward_easy",val={{10,50},{1,20000}},desc="挑战据点胜利奖励_简单"},
	["win_strongholds_reward_hard"] = {key="win_strongholds_reward_hard",val={{10,120},{1,50000}},desc="挑战据点胜利奖励_困难"},
	["win_strongholds_reward_normal"] = {key="win_strongholds_reward_normal",val={{10,80},{1,30000}},desc="挑战据点胜利奖励_普通"},
}
