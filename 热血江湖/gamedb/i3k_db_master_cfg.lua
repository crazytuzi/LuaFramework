i3k_db_master_cfg =
{
	cfg =
	{
		 master_min_lvl = 65,
		 apptc_min_lvl = 30,
		 apptc_max_lvl = 64,
		 graduate_lvl = 65,
		 max_apptc_num = 3,
		 dismiss_cooltime = 14400,
		 rebel_cooltime = 7200,
		 apply_grad_cooltime = 86400,
		 grad_auto_done_time = 172800,
		 max_msg_num = 3,
		 msg_rebel_lifetime = 259200,
		 msg_recruit_lifetime = 259200,
		 page_size = 6,
		 announce_max_length = 40,
		 apply_cooltime = 30,
		 icon_show_level = 25,
		 open_level = 30,
		 modify_announce = { id = 1, count = 50},
		 likeConsume = { id = 65820, count = 1},
	},
	grad_apptc_rwd =
	{
		[1] = {score = 60, rwd_num = 2, rwd = { { id=2, num=150000 },  { id=65734, num=15 }, }, },
		[2] = {score = 80, rwd_num = 2, rwd = { { id=2, num=200000 },  { id=66415, num=1 }, }, },
		[3] = {score = 100, rwd_num = 2, rwd = { { id=1, num=100 },  { id=66415, num=1 }, }, },
	},
	grad_master_rwd =
	{
		[1] = {score = 0, rwd_num = 3, rwd = { { id=66006, num=3 },  { id=65818, num=15 },  { id=9, num=200 }, }, },
	},
	grad_conds =
	{
		[1] = {desc = '累積活躍度', target = 1600, score = 20, },
		[2] = {desc = '競技場', target = 18, score = 20, },
		[3] = {desc = '會武', target = 5, score = 20, },
		[4] = {desc = '勢力戰', target = 2, score = 20, },
		[5] = {desc = '師徒副本', target = 10, score = 20, },
	},
};
