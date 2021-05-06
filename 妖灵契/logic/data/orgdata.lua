module(...)
--auto generate data
DATA={
	[1]={
		active_point=4800,
		coin_need=0,
		exp_need=24000,
		id=1,
		masterkick=8,
		max_elite=6,
		max_member=100,
		max_sub_leader=1,
		moneyback=0,
		name=[[1级公会]],
		subkick=4,
	},
	[2]={
		active_point=6000,
		coin_need=0,
		exp_need=54000,
		id=2,
		masterkick=10,
		max_elite=8,
		max_member=125,
		max_sub_leader=1,
		moneyback=200,
		name=[[2级公会]],
		subkick=6,
	},
	[3]={
		active_point=7200,
		coin_need=0,
		exp_need=135000,
		id=3,
		masterkick=12,
		max_elite=10,
		max_member=150,
		max_sub_leader=1,
		moneyback=300,
		name=[[3级公会]],
		subkick=8,
	},
	[4]={
		active_point=8400,
		coin_need=0,
		exp_need=378000,
		id=4,
		masterkick=14,
		max_elite=12,
		max_member=175,
		max_sub_leader=2,
		moneyback=0,
		name=[[4级公会]],
		subkick=10,
	},
	[5]={
		active_point=9600,
		coin_need=0,
		exp_need=99999999,
		id=5,
		masterkick=16,
		max_elite=14,
		max_member=200,
		max_sub_leader=2,
		moneyback=0,
		name=[[5级公会]],
		subkick=12,
	},
}

MemberLimit={
	[1]={
		active_need=0,
		agree_reject_join=1,
		authorize_pos={[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,},
		auto_appoint=0,
		ban_chat=1,
		bg=[[bg_gonghui_huizhangdi]],
		broadcast=1,
		buy=1,
		del_pos={[1]=2,[2]=3,[3]=4,[4]=5,},
		edit_aim=1,
		edit_flag=1,
		exit_tips=1,
		invite=1,
		mail=1,
		pos=[[会长]],
		posid=1,
		rename=1,
		show_sort=1,
		target_pos={[1]=1,[2]=2,[3]=3,[4]=4,},
		text_color={b=0.15,g=0.28,r=0.73,},
		upgrade=1,
	},
	[2]={
		active_need=0,
		agree_reject_join=1,
		authorize_pos={[1]=3,[2]=4,[3]=5,},
		auto_appoint=0,
		ban_chat=0,
		bg=[[bg_gonghui_fuhuidi]],
		broadcast=1,
		buy=1,
		del_pos={[1]=3,[2]=4,[3]=5,},
		edit_aim=1,
		edit_flag=1,
		exit_tips=0,
		invite=1,
		mail=1,
		pos=[[副会]],
		posid=2,
		rename=0,
		show_sort=2,
		target_pos={[1]=3,[2]=4,},
		text_color={b=0.49,g=0.28,r=0.42,},
		upgrade=1,
	},
	[3]={
		active_need=0,
		agree_reject_join=0,
		authorize_pos={},
		auto_appoint=0,
		ban_chat=0,
		bg=[[bg_gonghui_jingyingdi]],
		broadcast=0,
		buy=0,
		del_pos={},
		edit_aim=0,
		edit_flag=0,
		exit_tips=0,
		invite=1,
		mail=0,
		pos=[[精英]],
		posid=3,
		rename=0,
		show_sort=3,
		target_pos={},
		text_color={b=0.52,g=0.36,r=0.16,},
		upgrade=0,
	},
	[4]={
		active_need=0,
		agree_reject_join=0,
		authorize_pos={},
		auto_appoint=0,
		ban_chat=0,
		bg=[[bg_gonghui_chengyuandi]],
		broadcast=0,
		buy=0,
		del_pos={},
		edit_aim=0,
		edit_flag=0,
		exit_tips=0,
		invite=1,
		mail=0,
		pos=[[成员]],
		posid=4,
		rename=0,
		show_sort=4,
		target_pos={},
		text_color={b=0.48,g=0.44,r=0.09,},
		upgrade=0,
	},
	[5]={
		active_need=0,
		agree_reject_join=0,
		authorize_pos={},
		auto_appoint=0,
		ban_chat=0,
		bg=[[bg_gonghui_xinrendi]],
		broadcast=0,
		buy=0,
		del_pos={},
		edit_aim=0,
		edit_flag=0,
		exit_tips=0,
		invite=1,
		mail=0,
		pos=[[新人]],
		posid=5,
		rename=0,
		show_sort=5,
		target_pos={},
		text_color={b=0.41,g=0.53,r=0.62,},
		upgrade=0,
	},
}

Contribute={
	[101]={
		cost=10000,
		currency=2,
		exp=10,
		id=101,
		name=[[金币贡献]],
		org_contribute=1,
		player_contribute=10,
	},
	[102]={
		cost=50,
		currency=1,
		exp=20,
		id=102,
		name=[[水晶贡献]],
		org_contribute=2,
		player_contribute=20,
	},
	[103]={
		cost=200,
		currency=1,
		exp=40,
		id=103,
		name=[[土豪贡献]],
		org_contribute=4,
		player_contribute=10,
	},
}

Flag={
	[10011]={icon=[[01]],id=10011,sort_id=1,},
	[10012]={icon=[[02]],id=10012,sort_id=2,},
	[10013]={icon=[[03]],id=10013,sort_id=3,},
	[10014]={icon=[[04]],id=10014,sort_id=4,},
	[10015]={icon=[[05]],id=10015,sort_id=5,},
	[10016]={icon=[[06]],id=10016,sort_id=6,},
	[10017]={icon=[[07]],id=10017,sort_id=7,},
	[10018]={icon=[[08]],id=10018,sort_id=8,},
	[10019]={icon=[[09]],id=10019,sort_id=9,},
	[10020]={icon=[[10]],id=10020,sort_id=10,},
	[10021]={icon=[[11]],id=10021,sort_id=11,},
	[10022]={icon=[[12]],id=10022,sort_id=12,},
}

Rule={
	[1]={
		change_flag_price=140,
		cost=500,
		give_wish_limit=5,
		mail_cnt=3,
		mail_len=50,
		max_aim_len=140,
		max_apply_num=3,
		max_flag_len=1,
		max_name_len=6,
		min_name_len=2,
		org_mem_offer=360,
		org_sign_cash=20,
		spread_cost=200,
	},
}
Build={
	[1]={
		build_name=[[普通建设]],
		build_type=1,
		cash=200,
		cost_coin=5000,
		cost_gold=0,
		exp=200,
		offer=200,
		sign_degree=1,
		start_cash=0,
		start_exp=0,
		start_offer=0,
		time=0,
	},
	[2]={
		build_name=[[高级建设]],
		build_type=2,
		cash=350,
		cost_coin=0,
		cost_gold=10,
		exp=350,
		offer=350,
		sign_degree=1,
		start_cash=0,
		start_exp=0,
		start_offer=0,
		time=0,
	},
	[3]={
		build_name=[[超级建设]],
		build_type=3,
		cash=1000,
		cost_coin=0,
		cost_gold=30,
		exp=1000,
		offer=1000,
		sign_degree=1,
		start_cash=0,
		start_exp=0,
		start_offer=0,
		time=0,
	},
}
OrgSignReward={
	[1]={
		id=1,
		item_list={[1]={amount=1,sid=[[1003(value=10)]],},},
		sign_degree=20,
	},
	[2]={
		id=2,
		item_list={[1]={amount=1,sid=[[1003(value=20)]],},},
		sign_degree=40,
	},
	[3]={
		id=3,
		item_list={[1]={amount=1,sid=[[1003(value=50)]],},},
		sign_degree=80,
	},
}

RedBag={
	[1]={amount=15,gold=150000,id=1,sign_degree=20,},
	[2]={amount=30,gold=400000,id=2,sign_degree=40,},
	[3]={amount=60,gold=900000,id=3,sign_degree=80,},
}

OrgFuBen={
	[1001]={
		fight=1001,
		id=1001,
		kill_reward={[1]=1,[2]=2,},
		level=1,
		minimum_offer=45,
		name=[[暴力系伪装者]],
		org_reward={
			[1]={amount=1,sid=[[1015(value=4000)]],},
			[2]={amount=1,sid=[[1019(value=4000)]],},
			[3]={amount=1,sid=[[1026(value=4000)]],},
		},
		shape=1102,
		total_offer=3000,
	},
	[1002]={
		fight=1002,
		id=1002,
		kill_reward={[1]=11,[2]=12,},
		level=2,
		minimum_offer=45,
		name=[[黑化系伪装者]],
		org_reward={
			[1]={amount=1,sid=[[1015(value=6000)]],},
			[2]={amount=1,sid=[[1019(value=6000)]],},
			[3]={amount=1,sid=[[1026(value=6000)]],},
		},
		shape=1009,
		total_offer=6000,
	},
	[1003]={
		fight=1003,
		id=1003,
		kill_reward={[1]=21,[2]=22,},
		level=3,
		minimum_offer=45,
		name=[[gay质伪装者]],
		org_reward={
			[1]={amount=1,sid=[[1015(value=8000)]],},
			[2]={amount=1,sid=[[1019(value=8000)]],},
			[3]={amount=1,sid=[[1026(value=8000)]],},
		},
		shape=1201,
		total_offer=9000,
	},
	[1004]={
		fight=1004,
		id=1004,
		kill_reward={[1]=31,[2]=32,},
		level=4,
		minimum_offer=45,
		name=[[女王范伪装者]],
		org_reward={
			[1]={amount=1,sid=[[1015(value=10000)]],},
			[2]={amount=1,sid=[[1019(value=10000)]],},
			[3]={amount=1,sid=[[1026(value=10000)]],},
		},
		shape=1014,
		total_offer=12000,
	},
}

RedBagRatio={
	[1]={online_cnt=1,ratio=2,},
	[2]={online_cnt=2,ratio=2,},
	[3]={online_cnt=3,ratio=2,},
	[4]={online_cnt=4,ratio=2,},
	[5]={online_cnt=5,ratio=2,},
	[6]={online_cnt=6,ratio=2,},
	[7]={online_cnt=7,ratio=2,},
	[8]={online_cnt=8,ratio=2,},
	[9]={online_cnt=9,ratio=2,},
	[10]={online_cnt=10,ratio=2,},
	[11]={online_cnt=11,ratio=5,},
	[12]={online_cnt=12,ratio=5,},
	[13]={online_cnt=13,ratio=5,},
	[14]={online_cnt=14,ratio=5,},
	[15]={online_cnt=15,ratio=5,},
	[16]={online_cnt=16,ratio=5,},
	[17]={online_cnt=17,ratio=5,},
	[18]={online_cnt=18,ratio=5,},
	[19]={online_cnt=19,ratio=5,},
	[20]={online_cnt=20,ratio=5,},
	[21]={online_cnt=21,ratio=5,},
	[22]={online_cnt=22,ratio=5,},
	[23]={online_cnt=23,ratio=5,},
	[24]={online_cnt=24,ratio=5,},
	[25]={online_cnt=25,ratio=5,},
	[26]={online_cnt=26,ratio=10,},
	[27]={online_cnt=27,ratio=10,},
	[28]={online_cnt=28,ratio=10,},
	[29]={online_cnt=29,ratio=10,},
	[30]={online_cnt=30,ratio=10,},
	[31]={online_cnt=31,ratio=10,},
	[32]={online_cnt=32,ratio=10,},
	[33]={online_cnt=33,ratio=10,},
	[34]={online_cnt=34,ratio=10,},
	[35]={online_cnt=35,ratio=10,},
	[36]={online_cnt=36,ratio=10,},
	[37]={online_cnt=37,ratio=10,},
	[38]={online_cnt=38,ratio=10,},
	[39]={online_cnt=39,ratio=10,},
	[40]={online_cnt=40,ratio=10,},
	[41]={online_cnt=41,ratio=10,},
	[42]={online_cnt=42,ratio=10,},
	[43]={online_cnt=43,ratio=10,},
	[44]={online_cnt=44,ratio=10,},
	[45]={online_cnt=45,ratio=10,},
	[46]={online_cnt=46,ratio=10,},
	[47]={online_cnt=47,ratio=10,},
	[48]={online_cnt=48,ratio=10,},
	[49]={online_cnt=49,ratio=10,},
	[50]={online_cnt=50,ratio=10,},
	[51]={online_cnt=51,ratio=10,},
	[52]={online_cnt=52,ratio=10,},
	[53]={online_cnt=53,ratio=10,},
	[54]={online_cnt=54,ratio=10,},
	[55]={online_cnt=55,ratio=10,},
	[56]={online_cnt=56,ratio=10,},
	[57]={online_cnt=57,ratio=10,},
	[58]={online_cnt=58,ratio=10,},
	[59]={online_cnt=59,ratio=10,},
	[60]={online_cnt=60,ratio=10,},
	[61]={online_cnt=61,ratio=10,},
	[62]={online_cnt=62,ratio=10,},
	[63]={online_cnt=63,ratio=10,},
	[64]={online_cnt=64,ratio=10,},
	[65]={online_cnt=65,ratio=10,},
	[66]={online_cnt=66,ratio=10,},
	[67]={online_cnt=67,ratio=10,},
	[68]={online_cnt=68,ratio=10,},
	[69]={online_cnt=69,ratio=10,},
	[70]={online_cnt=70,ratio=10,},
	[71]={online_cnt=71,ratio=10,},
	[72]={online_cnt=72,ratio=10,},
	[73]={online_cnt=73,ratio=10,},
	[74]={online_cnt=74,ratio=10,},
	[75]={online_cnt=75,ratio=10,},
	[76]={online_cnt=76,ratio=10,},
	[77]={online_cnt=77,ratio=10,},
	[78]={online_cnt=78,ratio=10,},
	[79]={online_cnt=79,ratio=10,},
	[80]={online_cnt=80,ratio=10,},
	[81]={online_cnt=81,ratio=10,},
	[82]={online_cnt=82,ratio=10,},
	[83]={online_cnt=83,ratio=10,},
	[84]={online_cnt=84,ratio=10,},
	[85]={online_cnt=85,ratio=10,},
	[86]={online_cnt=86,ratio=10,},
	[87]={online_cnt=87,ratio=10,},
	[88]={online_cnt=88,ratio=10,},
	[89]={online_cnt=89,ratio=10,},
	[90]={online_cnt=90,ratio=10,},
	[91]={online_cnt=91,ratio=10,},
	[92]={online_cnt=92,ratio=10,},
	[93]={online_cnt=93,ratio=10,},
	[94]={online_cnt=94,ratio=10,},
	[95]={online_cnt=95,ratio=10,},
	[96]={online_cnt=96,ratio=10,},
	[97]={online_cnt=97,ratio=10,},
	[98]={online_cnt=98,ratio=10,},
	[99]={online_cnt=99,ratio=10,},
	[100]={online_cnt=100,ratio=10,},
	[101]={online_cnt=101,ratio=10,},
	[102]={online_cnt=102,ratio=10,},
	[103]={online_cnt=103,ratio=10,},
	[104]={online_cnt=104,ratio=10,},
	[105]={online_cnt=105,ratio=10,},
	[106]={online_cnt=106,ratio=10,},
	[107]={online_cnt=107,ratio=10,},
	[108]={online_cnt=108,ratio=10,},
	[109]={online_cnt=109,ratio=10,},
	[110]={online_cnt=110,ratio=10,},
	[111]={online_cnt=111,ratio=10,},
	[112]={online_cnt=112,ratio=10,},
	[113]={online_cnt=113,ratio=10,},
	[114]={online_cnt=114,ratio=10,},
	[115]={online_cnt=115,ratio=10,},
	[116]={online_cnt=116,ratio=10,},
	[117]={online_cnt=117,ratio=10,},
	[118]={online_cnt=118,ratio=10,},
	[119]={online_cnt=119,ratio=10,},
	[120]={online_cnt=120,ratio=10,},
	[121]={online_cnt=121,ratio=10,},
	[122]={online_cnt=122,ratio=10,},
	[123]={online_cnt=123,ratio=10,},
	[124]={online_cnt=124,ratio=10,},
	[125]={online_cnt=125,ratio=10,},
	[126]={online_cnt=126,ratio=10,},
	[127]={online_cnt=127,ratio=10,},
	[128]={online_cnt=128,ratio=10,},
	[129]={online_cnt=129,ratio=10,},
	[130]={online_cnt=130,ratio=10,},
	[131]={online_cnt=131,ratio=10,},
	[132]={online_cnt=132,ratio=10,},
	[133]={online_cnt=133,ratio=10,},
	[134]={online_cnt=134,ratio=10,},
	[135]={online_cnt=135,ratio=10,},
	[136]={online_cnt=136,ratio=10,},
	[137]={online_cnt=137,ratio=10,},
	[138]={online_cnt=138,ratio=10,},
	[139]={online_cnt=139,ratio=10,},
	[140]={online_cnt=140,ratio=10,},
	[141]={online_cnt=141,ratio=10,},
	[142]={online_cnt=142,ratio=10,},
	[143]={online_cnt=143,ratio=10,},
	[144]={online_cnt=144,ratio=10,},
	[145]={online_cnt=145,ratio=10,},
	[146]={online_cnt=146,ratio=10,},
	[147]={online_cnt=147,ratio=10,},
	[148]={online_cnt=148,ratio=10,},
	[149]={online_cnt=149,ratio=10,},
	[150]={online_cnt=150,ratio=10,},
	[151]={online_cnt=151,ratio=10,},
	[152]={online_cnt=152,ratio=10,},
	[153]={online_cnt=153,ratio=10,},
	[154]={online_cnt=154,ratio=10,},
	[155]={online_cnt=155,ratio=10,},
	[156]={online_cnt=156,ratio=10,},
	[157]={online_cnt=157,ratio=10,},
	[158]={online_cnt=158,ratio=10,},
	[159]={online_cnt=159,ratio=10,},
	[160]={online_cnt=160,ratio=10,},
	[161]={online_cnt=161,ratio=10,},
	[162]={online_cnt=162,ratio=10,},
	[163]={online_cnt=163,ratio=10,},
	[164]={online_cnt=164,ratio=10,},
	[165]={online_cnt=165,ratio=10,},
	[166]={online_cnt=166,ratio=10,},
	[167]={online_cnt=167,ratio=10,},
	[168]={online_cnt=168,ratio=10,},
	[169]={online_cnt=169,ratio=10,},
	[170]={online_cnt=170,ratio=10,},
	[171]={online_cnt=171,ratio=10,},
	[172]={online_cnt=172,ratio=10,},
	[173]={online_cnt=173,ratio=10,},
	[174]={online_cnt=174,ratio=10,},
	[175]={online_cnt=175,ratio=10,},
	[176]={online_cnt=176,ratio=10,},
	[177]={online_cnt=177,ratio=10,},
	[178]={online_cnt=178,ratio=10,},
	[179]={online_cnt=179,ratio=10,},
	[180]={online_cnt=180,ratio=10,},
	[181]={online_cnt=181,ratio=10,},
	[182]={online_cnt=182,ratio=10,},
	[183]={online_cnt=183,ratio=10,},
	[184]={online_cnt=184,ratio=10,},
	[185]={online_cnt=185,ratio=10,},
	[186]={online_cnt=186,ratio=10,},
	[187]={online_cnt=187,ratio=10,},
	[188]={online_cnt=188,ratio=10,},
	[189]={online_cnt=189,ratio=10,},
	[190]={online_cnt=190,ratio=10,},
	[191]={online_cnt=191,ratio=10,},
	[192]={online_cnt=192,ratio=10,},
	[193]={online_cnt=193,ratio=10,},
	[194]={online_cnt=194,ratio=10,},
	[195]={online_cnt=195,ratio=10,},
	[196]={online_cnt=196,ratio=10,},
	[197]={online_cnt=197,ratio=10,},
	[198]={online_cnt=198,ratio=10,},
	[199]={online_cnt=199,ratio=10,},
	[200]={online_cnt=200,ratio=10,},
}

Wish={
	[1]={amount=2,desc=[[精英]],id=1,org_offer=400,},
	[2]={amount=1,desc=[[传说]],id=2,org_offer=600,},
}

FlagSort={
	[1]=10011,
	[2]=10012,
	[3]=10013,
	[4]=10014,
	[5]=10015,
	[6]=10016,
	[7]=10017,
	[8]=10018,
	[9]=10019,
	[10]=10020,
	[11]=10021,
	[12]=10022,
}

EquipWish={
	[11004]={amount=1,desc=[[11004]],id=11004,org_offer=500,sort_id=1,},
	[11005]={amount=1,desc=[[11005]],id=11005,org_offer=300,sort_id=2,},
	[11006]={amount=1,desc=[[11006]],id=11006,org_offer=300,sort_id=3,},
	[11007]={amount=1,desc=[[11007]],id=11007,org_offer=300,sort_id=4,},
	[11008]={amount=1,desc=[[11008]],id=11008,org_offer=300,sort_id=5,},
	[11009]={amount=1,desc=[[11009]],id=11009,org_offer=300,sort_id=6,},
	[11010]={amount=2,desc=[[11010]],id=11010,org_offer=200,sort_id=7,},
	[11016]={amount=5,desc=[[11016]],id=11016,org_offer=50,sort_id=13,},
}

EquipWishSort={
	[1]=11004,
	[2]=11005,
	[3]=11006,
	[4]=11007,
	[5]=11008,
	[6]=11009,
	[7]=11010,
	[8]=11016,
}

Hint={
	active_point={
		hint=[[公会成员参与活动获得的活跃度将被计入到公会活跃中
每周的活跃度需求根据公会等级而改变，公会等级达到1/2/3/4/5级时，每周活跃要求为4800/6000/7200/8400/9600
当本周公会活跃未达到要求时，则下周公会降级处理]],
		key=[[active_point]],
		title=[[公会活跃]],
	},
	cash={
		hint=[[可用于购买公会祈坛福利以及重置赏金进度
可通过建设、据点战、击杀赏金头领、公会战获取公会资金]],
		key=[[cash]],
		title=[[公会资金]],
	},
	memcnt={
		hint=[[公会人数上限根据公会等级而改变，当前人数达到或超过上限人数时，则无法添加公会成员
公会等级达到1/2/3/4/5级时，公会上限人数为100/125/150/175/200]],
		key=[[memcnt]],
		title=[[公会成员]],
	},
	prestige={
		hint=[[公会排名的重要依据
可通过据点战、击杀赏金头领、公会战获取公会声望]],
		key=[[prestige]],
		title=[[公会声望]],
	},
	rank={
		hint=[[公会排名根据公会声望的多少进行排序，相同的公会声望情况下，优先达到该声望的公会排名优先。排名每小时进行一次更新]],
		key=[[rank]],
		title=[[公会排名]],
	},
}
