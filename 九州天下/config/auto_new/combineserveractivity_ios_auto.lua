-- H-合服活动-苹果.xls
return {
activity_time={
{},
{sub_type=7,name="boss抢夺",reward_desc="boss抢夺",},
{sub_type=9,name="登录奖励",reward_desc="登录奖励",},
{sub_type=11,name="全服抢购",reward_desc="全服抢购",},
{sub_type=14,name="三日狂欢",reward_desc="三日狂欢",},
{sub_type=15,name="天天累充",reward_desc="天天累充",},
{sub_type=16,name="群雄争霸",reward_desc="群雄争霸",}},

rank_reward={
{rank_limit=5,},
{sub_type=5,reward_item_1={item_id=31152,num=1,is_bind=1},reward_item_2={item_id=31153,num=1,is_bind=1},reward_item_3={item_id=31154,num=1,is_bind=1},},
{sub_type=6,}},

other={
{}},

qianggou={
{},
{},
{}},

roll_cfg={
[0]={seq=0,},
[1]={seq=1,},
[2]={seq=2,},
[3]={seq=3,},
[4]={seq=4,},
[5]={seq=5,},
[6]={seq=6,},
[7]={seq=7,}},

single_charge={
[0]={seq=0,},
[1]={seq=1,charge_value=1980,},
[2]={seq=2,charge_value=3280,},
[3]={seq=3,charge_value=4880,},
[4]={seq=4,charge_value=6480,}},

login_gift={
[0]={seq=0,},
[1]={seq=1,need_login_days=2,},
[2]={seq=2,need_login_days=3,}},

personal_panic_buy={
[0]={seq=0,},
[1]={seq=1,},
[2]={seq=2,},
[3]={seq=3,},
[4]={seq=4,gold_price=388,},
[5]={seq=5,gold_price=388,},
[6]={seq=6,gold_price=388,},
[7]={seq=7,gold_price=388,}},

server_panic_buy={
[0]={seq=0,gold_price=50,server_limit_buy_count=200,personal_limit_buy_count=10,},
[1]={seq=1,reward_item={item_id=23897,num=1,is_bind=1},},
[2]={seq=2,reward_item={item_id=23917,num=1,is_bind=1},},
[3]={seq=3,reward_item={item_id=23530,num=1,is_bind=1},},
[4]={seq=4,reward_item={item_id=23820,num=1,is_bind=1},},
[5]={seq=5,reward_item={item_id=23879,num=1,is_bind=1},},
[6]={seq=6,reward_item={item_id=23529,num=1,is_bind=1},},
[7]={seq=7,reward_item={item_id=23822,num=1,is_bind=1},}},

pvpactivity={
[0]={seq=0,},
[1]={seq=1,reward_item={[0]={item_id=23575,num=1,is_bind=1},[1]={item_id=23655,num=1,is_bind=1},[2]={item_id=26501,num=1,is_bind=1}},activityname="抢国王",describe="集合家族智慧,选出最强家族族长成为国王!",open_param=21,},
[2]={seq=2,reward_item={[0]={item_id=23576,num=1,is_bind=1},[1]={item_id=23656,num=1,is_bind=1},[2]={item_id=26501,num=1,is_bind=1}},activityname="抢皇帝",describe="英勇杀敌攻破城门,砍落城旗成为皇帝!",open_param=6,}},

ttlc={
{},
{combine_days=1,reward_item={item_id=31150,num=1,is_bind=1},},
{combine_days=2,reward_item={item_id=31151,num=1,is_bind=1},}},

activity_time_default_table={sub_type=5,is_open=1,begin_day=1,end_day=3,end_time=2400,name="充值排行",reward_desc="充值排行",},

rank_reward_default_table={sub_type=1,rank_limit=8888,reward_item_1={item_id=26000,num=1,is_bind=1},reward_item_2={item_id=26000,num=1,is_bind=1},reward_item_3={item_id=26000,num=1,is_bind=1},},

other_default_table={roll_cost=500,gcz_chengzhu_reward={item_id=26000,num=1,is_bind=1},gcz_camp_reward={item_id=26000,num=1,is_bind=1},xmz_camp_reward={item_id=26000,num=1,is_bind=1},xmz_mengzhu_reward={item_id=26000,num=1,is_bind=1},kill_boss_reward={item_id=31148,num=1,is_bind=1},kill_boss_reward_cost=1,kill_boss_fetch_reward_max_times=10,login_accumulate_reward={item_id=31156,num=1,is_bind=1},need_accumulate_days=3,srkh_fetch_reward_need_chongzhi=3000,srkh_reward={item_id=31147,num=1,is_bind=1},show_respath="actors/wing/8130_prefab",show_resid=8130001,},

qianggou_default_table={stuff_id=26000,limit_num=500,cost=218,},

roll_cfg_default_table={seq=0,is_broadcast=1,reward_item={item_id=26000,num=1,is_bind=1},},

single_charge_default_table={seq=0,charge_value=1080,reward_item={item_id=26000,num=1,is_bind=1},},

login_gift_default_table={seq=0,need_login_days=1,reward_item={item_id=31155,num=1,is_bind=1},vip_reward_item={item_id=31157,num=1,is_bind=1},},

personal_panic_buy_default_table={seq=0,reward_item={item_id=26000,num=1,is_bind=1},gold_price=188,limit_buy_count=5,},

server_panic_buy_default_table={seq=0,reward_item={item_id=27808,num=1,is_bind=1},gold_price=4800,server_limit_buy_count=60,personal_limit_buy_count=3,},

pvpactivity_default_table={seq=0,reward_item={[0]={item_id=22202,num=1,is_bind=1},[1]={item_id=26501,num=1,is_bind=1},[2]={item_id=22000,num=1,is_bind=1}},activityname="三国混战",describe="疯狂杀戮,成为本国杀神!",open_param=5,},

ttlc_default_table={combine_days=0,need_chongzhi_gold_num=980,reward_item={item_id=31149,num=1,is_bind=1},}

}

