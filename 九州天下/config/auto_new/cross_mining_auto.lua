-- K-跨服挖矿.xls
return {
other={
{}},

activity_open_time={
{},
{},
{},
{},
{},
{},
{}},

gather_pos={
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{},
{}},

area_score_cfg={
{},
{area_index=1,area_score=200,auto_mining_weight=1500,},
{area_index=2,area_score=300,auto_mining_weight=500,}},

mining_reward_cfg={
{area_index=0,event_param1=0,weight=2900,},
{area_index=0,seq=1,event_param1=1,weight=2900,},
{area_index=0,seq=2,},
{area_index=0,seq=3,weight=1500,},
{area_index=0,seq=4,event_param1=4,weight=700,},
{area_index=1,event_param1=0,weight=2500,},
{area_index=1,seq=1,event_param1=1,weight=2500,},
{area_index=1,seq=2,},
{area_index=1,seq=3,event_param1=3,weight=1500,},
{area_index=1,seq=4,event_param1=4,weight=700,},
{area_index=1,seq=5,event_type=2,event_param1=26100,event_param2=2,event_param3=1,weight=500,},
{area_index=1,seq=6,event_type=4,event_param2=0,weight=300,},
{event_param1=0,weight=2250,},
{seq=1,event_param1=1,weight=2250,},
{seq=2,},
{seq=3,event_param1=3,weight=1500,},
{seq=4,event_param1=4,weight=700,},
{seq=5,event_type=2,event_param1=26100,event_param2=5,event_param3=1,weight=300,},
{seq=6,event_type=3,event_param1=404,event_param2=0,weight=500,},
{seq=7,event_type=5,event_param2=0,weight=500,}},

combo_reward_cfg={
{reward_score=500,},
{seq=1,combo_times=6,reward_score=500,},
{seq=2,combo_times=12,},
{seq=3,combo_times=24,},
{seq=4,combo_times=25,},
{seq=5,combo_times=26,},
{seq=6,combo_times=27,},
{seq=7,combo_times=28,},
{seq=8,combo_times=29,},
{seq=9,combo_times=30,}},

mine_cfg={
{weight=0,},
{mine_type=1,name="黄铜矿石",score=200,weight=4000,mine_icon=2,},
{mine_type=2,name="银矿石",score=300,mine_icon=3,},
{mine_type=3,name="紫晶矿石",score=500,mine_icon=4,},
{mine_type=4,name="金矿石",score=800,weight=1000,mine_icon=5,}},

score_reward={
{},
{seq=1,need_score=3000,reward_item={item_id=22000,num=3,is_bind=1},},
{seq=2,need_score=5000,reward_item={item_id=22000,num=4,is_bind=1},},
{seq=3,need_score=8000,reward_item={item_id=22000,num=5,is_bind=1},},
{seq=4,need_score=15000,reward_item={item_id=22000,num=6,is_bind=1},}},

exchange={
{mine_type_2=0,mine_type_3=0,reward_item={item_id=26500,num=2,is_bind=1},},
{seq=1,mine_type_3=0,reward_score=400,},
{seq=2,mine_type_2=0,reward_score=800,},
{seq=3,reward_score=1500,reward_item={item_id=26500,num=6,is_bind=1},},
{seq=4,mine_type_4=1,reward_score=3000,reward_item={item_id=26500,num=10,is_bind=1},}},

client_guaji={
{},
{seq=2,area="黄色",weight=30,},
{seq=3,area="绿色",weight=60,}},

monster_drop={
{}},

other_default_table={is_open=1,room_max_role=150,scene_id=3003,relive_pos_x=86,relive_pos_y=78,gather_refresh_interval=30,gather_id=1379,gather_num=70,gather_times=15,gather_disappear=1,auto_mining_need_gold=10,role_activity_interval_s=600,role_waiting_time_s=15,per_turn_interval_s=15,client_per_turn_interval_s=15,per_turn_wait_time_s=0,mining_times=30,can_buy_mining_times=50,buy_times_gold=3,onekey_buy_times=10,close=3,},

activity_open_time_default_table={},

gather_pos_default_table={},

area_score_cfg_default_table={area_index=0,area_score=100,auto_mining_weight=8000,},

mining_reward_cfg_default_table={area_index=2,seq=0,event_type=1,event_param1=2,event_param2=1,event_param3=0,weight=2000,},

combo_reward_cfg_default_table={seq=0,combo_times=3,reward_score=1000,reward_item={item_id=0,num=0,is_bind=1},},

mine_cfg_default_table={mine_type=0,name="劣质矿石",score=100,weight=2000,mine_icon=1,},

score_reward_default_table={seq=0,need_score=1000,reward_item={item_id=22000,num=2,is_bind=1},},

exchange_default_table={seq=0,mine_type_0=1,mine_type_1=1,mine_type_2=1,mine_type_3=1,mine_type_4=0,reward_score=200,reward_item={item_id=26500,num=4,is_bind=1},},

client_guaji_default_table={seq=1,area="红色",weight=10,},

monster_drop_default_table={monster_id=404,mine_0_type=0,mine_0_num=1,mine_1_type=1,mine_1_num=1,mine_2_type=2,mine_2_num=1,mine_3_type=3,mine_3_num=1,mine_4_type=4,mine_4_num=1,}

}

