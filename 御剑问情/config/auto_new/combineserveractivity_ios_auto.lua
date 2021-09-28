-- H-合服活动-苹果.xls
return {
activity_time={
{end_day=2,},
{sub_type=2,name="幸运转盘",reward_desc="幸运转盘",},
{sub_type=3,name="城主争夺",reward_desc="城主争夺",},
{sub_type=4,name="盟主争霸",reward_desc="盟主争霸",},
{sub_type=5,end_day=4,name="充值排行",reward_desc="充值排行",},
{sub_type=6,begin_day=5,name="消费排行",reward_desc="消费排行",},
{sub_type=7,name="BOSS抢夺",reward_desc="BOSS抢夺",},
{sub_type=9,name="登录奖励",reward_desc="登录奖励",},
{sub_type=10,name="个人抢购",reward_desc="个人抢购",},
{sub_type=11,name="全服抢购",reward_desc="全服抢购",},
{sub_type=14,name="合服BOSS",reward_desc="合服BOSS",},
{sub_type=15,name="合服投资",reward_desc="投资计划",},
{sub_type=16,name="合服基金",reward_desc="成长基金",}},

rank_reward={
{rank_limit=30,},
{sub_type=5,reward_item_1={item_id=30644,num=1,is_bind=1},reward_item_2={item_id=30645,num=1,is_bind=1},reward_item_3={item_id=30646,num=1,is_bind=1},},
{sub_type=6,reward_item_1={item_id=30647,num=1,is_bind=1},reward_item_2={item_id=30648,num=1,is_bind=1},reward_item_3={item_id=30649,num=1,is_bind=1},},
{sub_type=14,rank_limit=1,reward_item_1={item_id=28794,num=1,is_bind=1},reward_item_2={item_id=28795,num=1,is_bind=1},reward_item_3={item_id=28796,num=1,is_bind=1},}},

other={
{}},

qianggou={
{},
{stuff_id=26301,stuff_item={item_id=28844,num=20,is_bind=1},},
{stuff_id=26302,stuff_item={item_id=28845,num=20,is_bind=1},}},

roll_cfg={
[0]={seq=0,},
[1]={seq=1,reward_item={item_id=28845,num=5,is_bind=1},},
[2]={seq=2,reward_item={item_id=26311,num=15,is_bind=1},},
[3]={seq=3,reward_item={item_id=26312,num=15,is_bind=1},},
[4]={seq=4,reward_item={item_id=26321,num=15,is_bind=1},},
[5]={seq=5,is_broadcast=1,reward_item={item_id=27354,num=1,is_bind=1},},
[6]={seq=6,is_broadcast=1,reward_item={item_id=27356,num=1,is_bind=1},},
[7]={seq=7,is_broadcast=1,reward_item={item_id=27350,num=1,is_bind=1},}},

single_charge={
[0]={seq=0,},
[1]={seq=1,charge_value=500,reward_item={item_id=28795,num=1,is_bind=1},},
[2]={seq=2,charge_value=1000,reward_item={item_id=28796,num=1,is_bind=1},},
[3]={seq=3,charge_value=2000,reward_item={item_id=28797,num=1,is_bind=1},},
[4]={seq=4,charge_value=5000,reward_item={item_id=28798,num=1,is_bind=1},}},

login_gift={
[0]={seq=0,},
[1]={seq=1,need_login_days=2,},
[2]={seq=2,need_login_days=3,},
[3]={seq=3,need_login_days=4,},
[4]={seq=4,need_login_days=5,},
[5]={seq=5,need_login_days=6,},
[6]={seq=6,need_login_days=7,},
[7]={seq=7,need_login_days=8,},
[8]={seq=8,need_login_days=9,},
[9]={seq=9,need_login_days=10,},
[10]={seq=10,need_login_days=11,},
[11]={seq=11,need_login_days=12,}},

personal_panic_buy={
[0]={seq=0,},
[1]={seq=1,reward_item={item_id=28844,num=30,is_bind=1},gold_price=630,limit_buy_count=4,},
[2]={seq=2,reward_item={item_id=28844,num=60,is_bind=1},gold_price=1440,limit_buy_count=2,},
[3]={seq=3,reward_item={item_id=28845,num=10,is_bind=1},},
[4]={seq=4,reward_item={item_id=28845,num=30,is_bind=1},gold_price=630,limit_buy_count=4,},
[5]={seq=5,reward_item={item_id=28845,num=60,is_bind=1},gold_price=1440,limit_buy_count=2,}},

server_panic_buy={
[0]={seq=0,gold_price=8000,},
[1]={seq=1,reward_item={item_id=27351,num=1,is_bind=1},},
[2]={seq=2,reward_item={item_id=27357,num=1,is_bind=1},},
[3]={seq=3,reward_item={item_id=27352,num=1,is_bind=1},}},

touzi_jihua={
{},
{login_day=2,reward_gold=200,},
{login_day=3,reward_gold=300,},
{login_day=4,reward_gold=400,},
{login_day=5,reward_gold=500,},
{login_day=6,reward_gold=600,},
{login_day=7,reward_gold=700,}},

foundation={
{},
{sub_index=1,need_up_level=6,reward_gold=330,},
{sub_index=2,need_up_level=9,reward_gold=410,},
{seq=1,rmb=99,gold=990,need_up_level=5,reward_gold=400,},
{seq=1,sub_index=1,rmb=99,gold=990,need_up_level=10,reward_gold=500,},
{seq=1,sub_index=2,rmb=99,gold=990,need_up_level=15,reward_gold=600,}},

activity_time_default_table={sub_type=1,is_open=1,begin_day=1,end_day=7,end_time=2400,name="抢购第一",reward_desc="抢购第一",},

rank_reward_default_table={sub_type=1,rank_limit=18888,reward_item_1={item_id=27349,num=1,is_bind=1},reward_item_2={item_id=28800,num=1,is_bind=1},reward_item_3={item_id=28800,num=1,is_bind=1},},

other_default_table={roll_cost=20000,gcz_chengzhu_reward={[0]={item_id=24771,num=1,is_bind=1},[1]={item_id=30650,num=1,is_bind=1}},gcz_camp_reward={[0]={item_id=30651,num=1,is_bind=1}},gcz_sepcial_attr_add=500,gcz_sepcial_attr_add_limit=5000,xmz_camp_reward={[0]={item_id=30656,num=1,is_bind=1}},xmz_mengzhu_reward={[0]={item_id=24770,num=1,is_bind=1},[1]={item_id=30655,num=1,is_bind=1}},kill_boss_reward={item_id=28848,num=1,is_bind=1},kill_boss_reward_cost=3,login_accumulate_reward={item_id=30643,num=1,is_bind=1},need_accumulate_days=5,boss_rank_member_reward_item={item_id=28796,num=1,is_bind=1},boss_rank_master_reward_item={item_id=28797,num=1,is_bind=1},touzi_jihua_buy_cost=1000,touzi_jihua_buy_reward_gold=1000,title_show=2060,},

qianggou_default_table={stuff_id=26300,limit_num=500,cost=480,stuff_item={item_id=28569,num=60,is_bind=1},},

roll_cfg_default_table={seq=0,is_broadcast=0,reward_item={item_id=28844,num=5,is_bind=1},},

single_charge_default_table={seq=0,charge_value=300,reward_item={item_id=28794,num=1,is_bind=1},},

login_gift_default_table={seq=0,need_login_days=1,reward_item={item_id=30641,num=1,is_bind=1},vip_reward_item={item_id=30642,num=1,is_bind=1},},

personal_panic_buy_default_table={seq=0,reward_item={item_id=28844,num=10,is_bind=1},gold_price=180,limit_buy_count=5,},

server_panic_buy_default_table={seq=0,reward_item={item_id=27353,num=1,is_bind=1},gold_price=6000,server_limit_buy_count=10,personal_limit_buy_count=1,},

touzi_jihua_default_table={login_day=1,reward_gold=100,},

foundation_default_table={seq=0,sub_index=0,rmb=66,gold=660,need_up_level=3,reward_gold=280,}

}

