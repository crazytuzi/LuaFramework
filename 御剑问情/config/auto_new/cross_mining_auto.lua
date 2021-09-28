-- K-跨服挖矿.xls
return {
other={
{}},

activity_open_time={
{},
{},
{},
{}},

gather_cfg={
{},
{gather_id=1014,gather_num=40,extra_reward_times=0,box_reward_item={item_id=40026,num=1,is_bind=1},}},

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
{}},

area_score_cfg={
{},
{area_index=1,area_score=200,auto_mining_weight=1500,},
{area_index=2,area_score=300,auto_mining_weight=500,}},

mining_reward_cfg={
{area_index=0,event_param1=0,weight=3300,},
{area_index=0,seq=1,event_param1=1,weight=3300,},
{area_index=0,seq=2,weight=2000,},
{area_index=0,seq=3,weight=1000,},
{area_index=0,seq=4,event_param1=4,weight=400,},
{area_index=1,event_param1=0,weight=3036,},
{area_index=1,seq=1,event_param1=1,weight=3036,},
{area_index=1,seq=2,weight=1840,},
{area_index=1,seq=3,event_param1=3,weight=920,},
{area_index=1,seq=4,event_param1=4,weight=368,},
{area_index=1,seq=5,event_type=2,event_param1=26100,event_param2=2,event_param3=1,weight=500,},
{area_index=1,seq=6,event_type=4,event_param2=0,},
{event_param1=0,weight=2937,},
{seq=1,event_param1=1,weight=2937,},
{seq=2,weight=1780,},
{seq=3,event_param1=3,weight=890,},
{seq=4,event_param1=4,weight=356,},
{seq=5,event_type=2,event_param1=26100,event_param2=5,event_param3=1,weight=500,},
{seq=6,event_type=3,event_param1=404,event_param2=0,},
{seq=7,event_type=5,event_param2=0,}},

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
{},
{mine_type=1,name="黄铜矿石",score=200,weight=4000,mine_icon=2,},
{mine_type=2,name="银矿石",score=300,weight=2000,mine_icon=3,},
{mine_type=3,name="紫晶矿石",score=500,weight=2000,mine_icon=4,},
{mine_type=4,name="金矿石",score=800,mine_icon=5,}},

score_reward={
{exp=500,},
{seq=1,need_score=3000,reward_item={[0]={item_id=26502,num=3,is_bind=1},[1]={item_id=26901,num=3,is_bind=1}},exp=500,},
{seq=2,need_score=5000,reward_item={[0]={item_id=26502,num=3,is_bind=1},[1]={item_id=26100,num=2,is_bind=1}},},
{seq=3,need_score=8000,reward_item={[0]={item_id=26502,num=4,is_bind=1},[1]={item_id=26901,num=4,is_bind=1}},},
{seq=4,need_score=11000,reward_item={[0]={item_id=26502,num=7,is_bind=1},[1]={item_id=26100,num=4,is_bind=1}},}},

exchange={
{mine_type_2=0,},
{seq=1,reward_item={item_id=40026,num=2,is_bind=1},},
{seq=2,mine_type_3=1,reward_item={item_id=40024,num=2,is_bind=1},},
{seq=3,mine_type_3=1,mine_type_4=1,reward_item={item_id=40025,num=1,is_bind=1},}},

client_guaji={
{},
{seq=2,area="黄色",weight=30,},
{seq=3,area="绿色",weight=60,}},

broadcast_cfg={
{},
{},
{},
{},
{}},

other_default_table={is_open=1,scene_id=9241,relive_pos_x=179,relive_pos_y=163,auto_mining_need_gold=10,role_activity_interval_s=600,role_waiting_time_s=15,per_turn_interval_s=15,client_per_turn_interval_s=15,per_turn_wait_time_s=0,mining_times=30,can_buy_mining_times=50,buy_times_gold=3,onekey_buy_times=10,skill_limit_times=5,skill_cd=10,buy_buff_cost=100,buy_buff_limit=5,buff_duration_time=60,close=3,bandit_text="这块<color=#0000f1>%s</color>我就收下啦！",bandit_text_1="这次算你走运，下次别让我再见到你！",},

activity_open_time_default_table={},

gather_cfg_default_table={gather_id=1015,gather_refresh_interval=30,gather_num=5,gather_time=10,gather_disappear=1,extra_reward_times=1,monster_id=4148,box_reward_item={item_id=40026,num=2,is_bind=1},},

gather_pos_default_table={},

area_score_cfg_default_table={area_index=0,area_score=100,auto_mining_weight=8000,},

mining_reward_cfg_default_table={area_index=2,seq=0,event_type=1,event_param1=2,event_param2=1,event_param3=0,weight=300,},

combo_reward_cfg_default_table={seq=0,combo_times=3,reward_score=1000,reward_item={item_id=0,num=0,is_bind=1},},

mine_cfg_default_table={mine_type=0,name="劣质矿石",score=100,weight=1000,mine_icon=1,},

score_reward_default_table={seq=0,need_score=1000,reward_item={[0]={item_id=26502,num=3,is_bind=1},[1]={item_id=26100,num=1,is_bind=1}},exp=1000,},

exchange_default_table={seq=0,mine_type_0=1,mine_type_1=1,mine_type_2=1,mine_type_3=0,mine_type_4=0,reward_score=0,reward_item={item_id=26100,num=4,is_bind=1},},

client_guaji_default_table={seq=1,area="红色",weight=10,},

broadcast_cfg_default_table={}

}

