-- J-决斗场系列.xls
return {
other={
{}},

mining_reward={
{consume_gold=20,rob_get_item_count=0,},
{quality=1,consume_gold=30,reward_exp=14000,reward_item={[0]={item_id=28751,num=3,is_bind=1}},name="洛书河图",},
{quality=2,reward_exp=21000,reward_item={[0]={item_id=28752,num=3,is_bind=1}},name="太古纪渊",},
{quality=3,reward_exp=28000,reward_item={[0]={item_id=28753,num=3,is_bind=1}},name="天地宝鉴",}},

sailing_reward={
{consume_gold=20,},
{quality=1,consume_gold=30,reward_exp=28000,name="蓝丹炉",rob_get_item_count=1,},
{quality=2,reward_exp=42000,name="紫丹炉",rob_get_item_count=2,},
{quality=3,reward_exp=56000,name="红丹炉",rob_get_item_count=3,}},

challenge_rank_reward={
{},
{rank=2,reward_item={[0]={item_id=26100,num=7,is_bind=1}},},
{rank=3,reward_item={[0]={item_id=26100,num=5,is_bind=1}},},
{rank=11,reward_item={[0]={item_id=26100,num=3,is_bind=1}},}},

skip_cfg={
{quality=0,},
{quality=1,consume=15,},
{quality=2,consume=20,},
{quality=3,limit_level=310,consume=25,},
{type=1,quality=0,},
{type=1,quality=1,consume=15,},
{type=1,quality=2,consume=20,},
{type=1,quality=3,limit_level=310,consume=25,},
{type=2,limit_level=400,},
{type=3,limit_level=400,},
{type=4,limit_level=400,}},

other_default_table={dm_scene_id=5003,dm_sponsor_pos_x=56,dm_sponsor_pos_y=90,dm_opponent_pos_x=73,dm_opponent_pos_y=74,dm_day_times=3,dm_buy_time_need_gold=30,dm_cost_time_m=30,dm_rob_times=3,dm_been_rob_times=2,dm_rob_reward_rate=30,sl_scene_id=5004,sl_sponsor_pos_x=41,sl_sponsor_pos_y=42,sl_opponent_pos_x=34,sl_opponent_pos_y=24,sl_day_times=3,sl_buy_time_need_gold=30,sl_cost_time_m=30,sl_rob_times=3,sl_been_rob_times=2,sl_rob_reward_rate=30,cf_scene_id=5003,cf_default_join_times=6,cf_buy_time_need_gold=10,cf_restore_join_times_need_time_m=60,cf_auto_reflush_interval_s=600,cf_reflush_need_bind_gold=5,cf_win_add_jifen=10,cf_win_add_mojing=0,cf_win_add_exp=1400000,cf_win_item={[0]={item_id=0,num=1,is_bind=1}},cf_stop_level=240,},

mining_reward_default_table={quality=0,consume_gold=40,upgrade_rate=100,reward_exp=7000,reward_item={[0]={item_id=28750,num=1,is_bind=1}},name="苍龙秘记",rob_get_item_count=1,},

sailing_reward_default_table={quality=0,consume_gold=40,upgrade_rate=100,reward_exp=14000,reward_item={[0]={item_id=26000,num=2,is_bind=1}},name="绿丹炉",rob_get_item_count=0,},

challenge_rank_reward_default_table={rank=1,reward_item={[0]={item_id=26100,num=10,is_bind=1}},},

skip_cfg_default_table={type=0,quality=-1,limit_level=300,consume=10,}

}

