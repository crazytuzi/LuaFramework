-- H-活跃度奖励.xls
return {
degree={
{max_times=10,once_add_degree=2,title=0,goto_panel="DailyTask",open_level=1,},
{type=1,add_degree=30,once_add_degree=15,goto_panel="FuBen#fb_exp",pic_id="pic_1",act_name="经验副本",open_level=65,show_seq=2,},
{type=2,add_degree=10,pic_id="pic_2",act_name="坐骑-翅膀副本",open_level=36,show_seq=7,},
{type=3,add_degree=10,pic_id="pic_3",act_name="战斗坐骑副本",open_level=90,show_seq=8,},
{type=4,add_degree=10,pic_id="pic_4",act_name="神兵副本",open_level=110,show_seq=9,},
{type=5,add_degree=10,pic_id="pic_5",act_name="宝甲副本",open_level=110,show_seq=10,},
{type=6,add_degree=10,pic_id="pic_6",act_name="人物环绕光环副本",open_level=110,show_seq=11,},
{type=7,add_degree=10,pic_id="pic_7",act_name="法宝副本",open_level=140,show_seq=12,},
{type=8,add_degree=10,pic_id="pic_8",act_name="美人环绕光环副本",open_level=150,show_seq=13,},
{type=9,add_degree=10,pic_id="pic_9",act_name="披风副本",open_level=160,show_seq=14,},
{type=10,add_degree=10,pic_id="pic_10",act_name="足迹副本",open_level=162,show_seq=15,},
{type=11,once_add_degree=10,goto_panel="HuSong",pic_id="pic_11",act_name="运镖",open_level=75,show_seq=6,},
{type=12,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_rescue",pic_id="pic_12",act_name="营救",open_level=51,show_seq=3,},
{type=13,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_spy",pic_id="pic_13",act_name="刺探",open_level=65,show_seq=4,},
{type=14,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_brick",pic_id="pic_14",act_name="搬砖",open_level=75,show_seq=5,},
{type=15,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_minister",pic_id="pic_15",act_name="击杀大臣",open_level=75,show_seq=16,},
{type=16,max_times=1,add_degree=10,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_minister",pic_id="pic_16",act_name="防守大臣",open_level=75,show_seq=18,},
{type=17,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_flag",pic_id="pic_17",act_name="砍倒军旗",open_level=75,show_seq=17,},
{type=18,max_times=1,add_degree=10,once_add_degree=10,goto_panel="NationalWarfare#national_warfare_flag",pic_id="pic_18",act_name="守卫军旗",open_level=75,show_seq=19,},
{type=19,max_times=20,once_add_degree=1,title=0,goto_panel="TaskKillView",pic_id="pic_19",act_name="击杀或助攻20个玩家",show_seq=20,},
{type=20,max_times=1,once_add_degree=20,title=0,goto_panel="Activity#KF_MINING",pic_id="pic_20",act_name="参加一次挖矿",show_seq=21,},
{type=21,max_times=1,once_add_degree=20,title=0,goto_panel="Activity#KF_FISHING",pic_id="pic_21",act_name="参加一次钓鱼",show_seq=22,},
{type=22,max_times=1,once_add_degree=20,title=0,goto_panel="Activity#BIG_RICH",pic_id="pic_22",act_name="参加一次大富豪",show_seq=23,},
{type=23,max_times=1,once_add_degree=20,title=0,goto_panel="Activity#QUNXIANLUANDOU",pic_id="pic_23",act_name="参加一次元素战场",show_seq=24,},
{type=24,max_times=1,once_add_degree=20,title=0,goto_panel="Activity#GUILDBATTLE",pic_id="pic_24",act_name="参加一次抢国王",show_seq=25,},
{type=25,max_times=1,once_add_degree=20,title=0,goto_panel="Activity#GONGCHENGZHAN",pic_id="pic_25",act_name="参加一次抢皇帝",show_seq=26,},
{type=29,max_times=5,add_degree=25,title=0,goto_panel="DiMai#dimai_renmai",pic_id="pic_27",act_name="参加五次抢龙脉",open_level=80,show_seq=30,},
{type=30,max_times=1,add_degree=30,once_add_degree=30,title=0,goto_panel="Marriage#marriage_shengdi",pic_id="pic_28",act_name="完成情缘圣地任务",open_level=100,show_seq=31,}},

reward={
{},
{reward_index=1,degree_limit=10,},
{reward_index=2,degree_limit=30,},
{reward_index=3,degree_limit=50,},
{reward_index=4,degree_limit=70,},
{reward_index=5,degree_limit=90,},
{reward_index=6,degree_limit=120,}},

other={
{}},

ratio={
{},
{min_level=131,max_level=200,exp_ratio=1.2,},
{min_level=201,max_level=300,exp_ratio=1.5,},
{min_level=301,max_level=400,exp_ratio=2,},
{min_level=401,max_level=500,exp_ratio=2.5,},
{min_level=501,max_level=600,exp_ratio=3,},
{min_level=601,max_level=700,exp_ratio=3.5,},
{min_level=701,max_level=800,exp_ratio=4,},
{min_level=801,max_level=900,exp_ratio=4.5,},
{min_level=901,max_level=1000,exp_ratio=5,}},

degree_default_table={type=0,max_times=2,add_degree=20,once_add_degree=5,once_add_huoli=1,add_exp=0,title=1,goto_panel="FuBen#fb_phase",pic_id="pic_0",act_name="完成次日常任务",is_show_in_task=1,act_id="",open_level=70,show_seq=1,name="open",},

reward_default_table={reward_index=0,degree_limit=200,item={item_id=26000,num=1,is_bind=1},is_notice=0,},

other_default_table={vitality_limit=150,task_kill_assists_num=20,one_key_complete_need_gold=500,},

ratio_default_table={min_level=1,max_level=130,exp_ratio=1,}

}

