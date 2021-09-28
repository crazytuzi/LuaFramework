-- K-跨服钓鱼.xls
return {
other={
{}},

activity_open_time={
{},
{},
{}},

fish={
{},
{type=2,name="海虾",score=200,},
{type=3,name="大黄鱼",score=300,},
{type=4,name="毛蟹",score=500,},
{type=5,name="金枪鱼",score=800,}},

combination={
[0]={index=0,fish_type_3=0,},
[1]={index=1,reward_item={item_id=40026,num=1,is_bind=1},reward_score=400,},
[2]={index=2,fish_type_4=1,reward_item={item_id=40024,num=1,is_bind=1},reward_score=800,},
[3]={index=3,fish_type_4=1,fish_type_5=1,reward_item={item_id=40025,num=1,is_bind=1},reward_score=1200,}},

fish_bait={
{item_num=5,},
{type=1,name="特级鱼饵",item_id=27815,gold_price=10,},
{type=2,name="黄金鱼饵",item_id=27816,gold_price=100,}},

event={
{},
{type=1,name="破旧宝箱",},
{type=2,name="渔网",},
{type=3,name="鱼叉",},
{type=4,name="香油",},
{type=5,name="盗贼",},
{type=6,name="传说中大鱼",}},

treasure={
{}},

steal_count_buy={
{},
{buy_count=1,need_gold=60,},
{buy_count=2,need_gold=70,},
{buy_count=3,need_gold=80,},
{buy_count=4,need_gold=90,}},

score_reward={
{exp_reward=500,},
{stage=1,need_score=3000,reward_item={[0]={item_id=26502,num=3,is_bind=1},[1]={item_id=26901,num=3,is_bind=1}},reward_score=400,exp_reward=500,},
{stage=2,need_score=5000,reward_item={[0]={item_id=26502,num=3,is_bind=1},[1]={item_id=26100,num=2,is_bind=1}},reward_score=800,},
{stage=3,need_score=7000,reward_item={[0]={item_id=26502,num=4,is_bind=1},[1]={item_id=26901,num=4,is_bind=1}},reward_score=1200,},
{stage=4,need_score=9000,reward_item={[0]={item_id=26502,num=7,is_bind=1},[1]={item_id=26100,num=4,is_bind=1}},reward_score=1800,}},

location={
[1]={index=1,x=135,y=142,},
[2]={index=2,x=126,y=138,},
[3]={index=3,x=122,},
[4]={index=4,x=114,},
[5]={index=5,x=108,},
[6]={index=6,x=98,},
[7]={index=7,x=95,y=128,},
[8]={index=8,x=95,y=118,},
[9]={index=9,x=133,y=122,},
[10]={index=10,x=123,y=121,},
[11]={index=11,x=113,y=121,},
[12]={index=12,x=104,y=118,},
[13]={index=13,x=104,y=111,},
[14]={index=14,x=146,y=83,},
[15]={index=15,x=154,y=81,},
[16]={index=16,x=162,y=80,},
[17]={index=17,x=146,y=68,},
[18]={index=18,x=151,y=69,},
[19]={index=19,x=158,y=72,},
[20]={index=20,x=163,y=71,},
[21]={index=21,x=179,y=71,},
[22]={index=22,x=183,y=75,},
[23]={index=23,x=195,y=81,},
[24]={index=24,x=207,y=81,},
[25]={index=25,x=212,y=83,},
[26]={index=26,x=241,y=93,},
[27]={index=27,x=193,y=88,},
[28]={index=28,x=203,y=88,},
[29]={index=29,x=217,y=92,},
[30]={index=30,x=213,y=99,},
[31]={index=31,x=213,y=105,},
[32]={index=32,x=212,y=113,},
[33]={index=33,y=101,},
[34]={index=34,x=241,y=110,},
[35]={index=35,y=120,},
[36]={index=36,x=234,y=141,},
[37]={index=37,x=237,y=147,},
[38]={index=38,y=154,},
[39]={index=39,x=244,y=162,},
[40]={index=40,y=137,},
[41]={index=41,x=244,y=144,},
[42]={index=42,x=248,y=152,}},

ratio={
{},
{min_level=131,max_level=220,level_ratio=2,},
{min_level=221,max_level=300,level_ratio=3,},
{min_level=301,max_level=400,level_ratio=4,},
{min_level=401,max_level=500,level_ratio=5,},
{min_level=501,max_level=600,level_ratio=6,},
{min_level=601,max_level=700,level_ratio=7,},
{min_level=701,max_level=800,level_ratio=8,},
{min_level=801,max_level=900,level_ratio=9,},
{min_level=901,max_level=999,level_ratio=10,}},

broadcast_cfg={
{},
{},
{},
{},
{}},

other_default_table={is_open=1,open_level=365,sceneid=9240,enter_pos_x=108,enter_pos_y=80,pull_count_down_s=5,give_bait_count=50,oil_special_status_duration=30,auto_fishing_need_gold=50,steal_count=10,be_stealed_count=10,steal_succ_rate=50,steal_buy_count=5,resource_id_0=3046001,resource_id_1=3045001,creeltime=30,fisher_text="老夫看你年纪轻轻钓术了得，这些奖励便赠与你把！",robber_text="小子，竟敢在我的地盘钓鱼，这几条鱼我就笑纳了！",},

activity_open_time_default_table={},

fish_default_table={type=1,name="秋刀鱼",score=100,be_stealed_rate=15,},

combination_default_table={index=0,fish_type_1=1,fish_type_2=1,fish_type_3=1,fish_type_4=0,fish_type_5=0,reward_item={item_id=26100,num=2,is_bind=1},reward_score=200,},

fish_bait_default_table={type=0,name="鱼饵",item_id=27786,gold_price=38,item_num=100,},

event_default_table={type=0,name="鱼类上钩",},

treasure_default_table={seq=0,reward_item={item_id=40024,num=1,is_bind=1},weight=3500,},

steal_count_buy_default_table={buy_count=0,need_gold=50,},

score_reward_default_table={stage=0,need_score=1000,reward_item={[0]={item_id=26502,num=3,is_bind=1},[1]={item_id=26100,num=1,is_bind=1}},reward_score=200,show_icon="90050:1:1",exp_reward=1000,},

location_default_table={index=1,x=240,y=132,},

ratio_default_table={min_level=0,max_level=130,level_ratio=1,},

broadcast_cfg_default_table={}

}

