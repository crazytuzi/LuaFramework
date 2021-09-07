local config = {
other={
{}},

relive_pos={
{},
{side=1,pos_x=188,pos_y=61,},
{side=2,pos_x=242,pos_y=262,}},

reward={
{},
{need_score_min=4000,need_score_max=7999,reward_index=2,need_score=4000,reward_item={[0]={item_id=22000,num=6,is_bind=1},[1]={item_id=26100,num=2,is_bind=1},[2]={item_id=22805,num=1,is_bind=1}},},
{need_score_min=8000,need_score_max=11999,reward_index=3,need_score=8000,reward_item={[0]={item_id=22000,num=8,is_bind=1},[1]={item_id=26100,num=2,is_bind=1},[2]={item_id=22805,num=1,is_bind=1}},},
{need_score_min=12000,need_score_max=15999,reward_index=4,need_score=12000,reward_item={[0]={item_id=22000,num=10,is_bind=1},[1]={item_id=26100,num=2,is_bind=1},[2]={item_id=22805,num=1,is_bind=1}},},
{need_score_min=16000,need_score_max=-1,reward_index=5,need_score=16000,reward_item={[0]={item_id=22000,num=12,is_bind=1},[1]={item_id=26100,num=2,is_bind=1},[2]={item_id=22805,num=1,is_bind=1}},}},

side_reward={
{fetch_dailyscore=1000,win_item={[0]={item_id=29927,num=1,is_bind=1},[1]={item_id=90003,num=1000,is_bind=1}},lose_item={[0]={item_id=29928,num=1,is_bind=1},[1]={item_id=90003,num=500,is_bind=1}},},
{camp_rank=2,fetch_item={item_id=22015,num=1,is_bind=1},},
{camp_rank=3,fetch_item={item_id=22014,num=1,is_bind=1},}},

defender_pos_list={
{},
{side=1,pos_x=229,pos_y=204,},
{side=2,pos_x=20,pos_y=203,}},

shenshi={
{}},

role_rank_reward={
{},
{min_rank=2,max_rank=3,rank_reward_item={[0]={item_id=26501,num=25,is_bind=1},[1]={item_id=22806,num=2,is_bind=1}},},
{min_rank=4,max_rank=10,rank_reward_item={[0]={item_id=26501,num=20,is_bind=1},[1]={item_id=22806,num=1,is_bind=1}},},
{min_rank=11,max_rank=20,rank_reward_item={[0]={item_id=26501,num=18,is_bind=1},[1]={item_id=22806,num=1,is_bind=1}},},
{min_rank=20,max_rank=9999,rank_reward_item={[0]={item_id=26501,num=16,is_bind=1},[1]={item_id=22806,num=1,is_bind=1}},}},

open_server_reward={
{}},

daily_nation_war_reward={
{},
{rank=10,rank_mix=4,rank_max=10,reward_item={item_id=30047,num=1,is_bind=1},},
{rank=999,rank_mix=11,rank_max=999,reward_item={item_id=30048,num=1,is_bind=1},}},

daily_nation_war_explain={
{},
{date=4,explain="在开服第4日，参加群雄逐鹿，根据活动积分排名发放奖励，每位参与活动的玩家都可获得对应奖励！",},
{date=7,explain="在开服第7日，参加群雄逐鹿，根据活动积分排名发放奖励，每位参与活动的玩家都可获得对应奖励！",}},

other_default_table={role_level=50,scene_id=3001,town_direction_x=124,town_direction_y=143,guaji_x=157,guaji_y=178,lucky_interval=180,lucky_item={item_id=28728,num=1,is_bind=1},luck_people=3,time=300,},

relive_pos_default_table={side=0,pos_x=41,pos_y=209,},

reward_default_table={need_score_min=2000,need_score_max=3999,reward_index=1,need_score=2000,reward_honor=100,reward_item={[0]={item_id=22000,num=4,is_bind=1},[1]={item_id=26100,num=2,is_bind=1},[2]={item_id=22805,num=1,is_bind=1}},},

side_reward_default_table={camp_rank=1,fetch_exp=0,fetch_dailyscore=500,fetch_item={item_id=22015,num=2,is_bind=1},win_item={},lose_item={},},

defender_pos_list_default_table={side=0,pos_x=124,pos_y=21,monster_id=1101,},

shenshi_default_table={shenshi_hp=50,pos_x=109,pos_y=82,},

role_rank_reward_default_table={min_rank=1,max_rank=1,rank_reward_item={[0]={item_id=26501,num=30,is_bind=1},[1]={item_id=22806,num=3,is_bind=1}},},

open_server_reward_default_table={first_reward_list={[0]={item_id=22202,num=1,is_bind=1}},},

daily_nation_war_reward_default_table={rank=3,rank_mix=1,rank_max=3,reward_item={item_id=30046,num=1,is_bind=1},},

daily_nation_war_explain_default_table={date=1,name="群雄逐鹿",explain="在开服第1日，参加群雄逐鹿，根据活动积分排名发放奖励，每位参与活动的玩家都可获得对应奖励！",}

}

---------------------------索引表分割线-----------------------

local db = nil 
db = nil
return config

